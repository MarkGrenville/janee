<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { api } from '$lib/firebase/api';

	let app = $state<any>(null);
	let cards = $state<any[]>([]);
	let decisions = $state<any[]>([]);
	let apiKeys = $state<any[]>([]);
	let loading = $state(true);
	let activeTab = $state<'cards' | 'decisions' | 'settings'>('cards');
	let error = $state('');

	let showAddCards = $state(false);
	let newCardTitle = $state('');
	let newCardDescription = $state('');
	let newCardIcon = $state('');
	let addingCard = $state(false);

	let creatingKey = $state(false);
	let newKeyLabel = $state('');

	let appId = $derived($page.params.appId ?? '');

	onMount(async () => {
		await loadApp();
	});

	async function loadApp() {
		loading = true;
		try {
			app = await api.apps.get(appId);
			await loadCards();
		} catch (e: any) {
			error = e.message;
			console.log('[app-detail] Error loading app:', e.message);
		} finally {
			loading = false;
		}
	}

	async function loadCards() {
		try {
			cards = await api.cards.list(appId);
		} catch (e: any) {
			console.log('[app-detail] Error loading cards:', e.message);
		}
	}

	async function loadDecisions() {
		try {
			decisions = await api.decisions.list(appId);
		} catch (e: any) {
			console.log('[app-detail] Error loading decisions:', e.message);
		}
	}

	async function loadApiKeys() {
		try {
			const allKeys = await api.keys.list();
			apiKeys = allKeys.filter((k: any) => k.appId === appId);
		} catch (e: any) {
			console.log('[app-detail] Error loading API keys:', e.message);
		}
	}

	async function handleTabChange(tab: 'cards' | 'decisions' | 'settings') {
		activeTab = tab;
		if (tab === 'decisions' && decisions.length === 0) await loadDecisions();
		if (tab === 'settings' && apiKeys.length === 0) await loadApiKeys();
	}

	async function addCard(e: Event) {
		e.preventDefault();
		if (!newCardTitle.trim()) return;
		addingCard = true;
		try {
			await api.cards.create(appId, [
				{ title: newCardTitle.trim(), description: newCardDescription.trim() || undefined, icon: newCardIcon.trim() || undefined },
			]);
			newCardTitle = '';
			newCardDescription = '';
			newCardIcon = '';
			showAddCards = false;
			await loadCards();
		} catch (e: any) {
			console.log('[app-detail] Error adding card:', e.message);
		} finally {
			addingCard = false;
		}
	}

	async function createApiKey() {
		creatingKey = true;
		try {
			await api.keys.create(appId, newKeyLabel.trim() || undefined);
			newKeyLabel = '';
			await loadApiKeys();
		} catch (e: any) {
			console.log('[app-detail] Error creating API key:', e.message);
		} finally {
			creatingKey = false;
		}
	}

	async function deleteApiKey(keyId: string) {
		try {
			await api.keys.delete(keyId);
			apiKeys = apiKeys.filter((k: any) => k.id !== keyId);
		} catch (e: any) {
			console.log('[app-detail] Error deleting API key:', e.message);
		}
	}

	async function handleSubscribe() {
		try {
			await api.apps.subscribe(appId);
			app = { ...app, isSubscribed: true };
		} catch (e: any) {
			console.log('[app-detail] Error subscribing:', e.message);
		}
	}

	function formatDate(ts: any): string {
		if (!ts) return '—';
		const d = ts.toDate ? ts.toDate() : new Date(ts);
		return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' });
	}

	function formatDuration(ms: number): string {
		if (!ms) return '—';
		if (ms < 1000) return `${ms}ms`;
		return `${(ms / 1000).toFixed(1)}s`;
	}
</script>

<div class="px-6 py-6 md:px-8 md:py-8">
	<div class="mx-auto max-w-3xl">
		{#if loading}
			<div class="flex items-center justify-center py-20">
				<div class="h-8 w-8 animate-spin rounded-full border-2 border-amber border-t-transparent"></div>
			</div>
		{:else if error}
			<div class="text-center py-20">
				<p class="text-rose mb-3">{error}</p>
				<button onclick={() => goto('/apps')} class="text-sm text-amber hover:text-amber-light transition-colors">Back to Apps</button>
			</div>
		{:else if app}
			<!-- Back -->
			<button
				onclick={() => goto('/apps')}
				class="mb-6 inline-flex items-center gap-1.5 text-sm text-jet/60 dark:text-ivory/60 hover:text-amber transition-colors"
			>
				<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
					<path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
				</svg>
				Back to Apps
			</button>

			<!-- App Header -->
			<div class="mb-8 flex items-start gap-4">
				{#if app.icon}
					<span class="text-5xl">{app.icon}</span>
				{:else}
					<div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-amber/10 text-amber">
						<svg class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
							<path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6z" />
						</svg>
					</div>
				{/if}
				<div class="flex-1">
					<h1 class="font-serif text-2xl md:text-3xl text-jet dark:text-ivory">{app.name}</h1>
					{#if app.description}
						<p class="mt-1 text-sm text-jet/60 dark:text-ivory/60">{app.description}</p>
					{/if}
					<div class="mt-2 flex items-center gap-3 text-xs text-jet/40 dark:text-ivory/40">
						<span>{app.isPublic ? 'Public' : 'Private'}</span>
						{#if app.cardCount !== undefined}
							<span>{app.cardCount} cards</span>
						{/if}
					</div>
				</div>
				{#if !app.isOwner && !app.isSubscribed}
					<button
						onclick={handleSubscribe}
						class="rounded-xl bg-amber px-5 py-2 text-sm font-medium text-jet hover:bg-amber-light transition-colors"
					>
						Subscribe
					</button>
				{/if}
			</div>

			<!-- Tabs -->
			<div class="mb-6 flex gap-1 border-b border-jet/10 dark:border-ivory/10">
				{#each ['cards', 'decisions', 'settings'] as tab}
					<button
						onclick={() => handleTabChange(tab as any)}
						class="relative px-4 py-2.5 text-sm font-medium transition-colors {activeTab === tab
							? 'text-amber'
							: 'text-jet/50 dark:text-ivory/50 hover:text-jet dark:hover:text-ivory'}"
					>
						{tab.charAt(0).toUpperCase() + tab.slice(1)}
						{#if activeTab === tab}
							<span class="absolute bottom-0 left-0 right-0 h-0.5 bg-amber rounded-full"></span>
						{/if}
					</button>
				{/each}
			</div>

			<!-- Cards Tab -->
			{#if activeTab === 'cards'}
				<div class="space-y-3">
					<div class="flex items-center justify-between mb-4">
						<p class="text-sm text-jet/60 dark:text-ivory/60">{cards.length} cards</p>
						<button
							onclick={() => showAddCards = !showAddCards}
							class="inline-flex items-center gap-1.5 rounded-lg bg-amber/10 px-3 py-1.5 text-xs font-medium text-amber hover:bg-amber/20 transition-colors"
						>
							<svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
							</svg>
							Add Card
						</button>
					</div>

					{#if showAddCards}
						<form onsubmit={addCard} class="rounded-xl border border-jet/10 dark:border-ivory/10 p-4 mb-4 space-y-3">
							<input
								type="text"
								bind:value={newCardIcon}
								placeholder="Icon (emoji)"
								class="w-20 rounded-lg border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-3 py-2 text-xl text-jet dark:text-ivory outline-none focus:border-amber transition-colors"
							/>
							<input
								type="text"
								bind:value={newCardTitle}
								placeholder="Card title"
								required
								class="w-full rounded-lg border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-3 py-2 text-sm text-jet dark:text-ivory outline-none focus:border-amber transition-colors"
							/>
							<textarea
								bind:value={newCardDescription}
								placeholder="Description (optional)"
								rows={2}
								class="w-full rounded-lg border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-3 py-2 text-sm text-jet dark:text-ivory outline-none focus:border-amber transition-colors resize-none"
							></textarea>
							<div class="flex gap-2">
								<button
									type="submit"
									disabled={addingCard || !newCardTitle.trim()}
									class="rounded-lg bg-amber px-4 py-2 text-xs font-medium text-jet hover:bg-amber-light disabled:opacity-50 transition-colors"
								>
									{addingCard ? 'Adding...' : 'Add'}
								</button>
								<button
									type="button"
									onclick={() => showAddCards = false}
									class="rounded-lg px-4 py-2 text-xs text-jet/60 dark:text-ivory/60 hover:bg-jet/5 dark:hover:bg-ivory/5 transition-colors"
								>
									Cancel
								</button>
							</div>
						</form>
					{/if}

					{#each cards as card}
						<div class="rounded-xl border border-jet/5 dark:border-ivory/5 bg-white/50 dark:bg-jet-light/50 px-4 py-3">
							<div class="flex items-center gap-3">
								{#if card.icon}
									<span class="text-xl">{card.icon}</span>
								{/if}
								<div class="flex-1 min-w-0">
									<p class="text-sm font-medium text-jet dark:text-ivory truncate">{card.title}</p>
									{#if card.description}
										<p class="text-xs text-jet/50 dark:text-ivory/50 truncate">{card.description}</p>
									{/if}
								</div>
								{#if card.status}
									<span class="text-[10px] uppercase tracking-wider {card.status === 'decided' ? 'text-sage' : 'text-amber'}">{card.status}</span>
								{/if}
							</div>
						</div>
					{/each}

					{#if cards.length === 0}
						<p class="text-center text-sm text-jet/40 dark:text-ivory/40 py-8">No cards yet. Add some to get started.</p>
					{/if}
				</div>

			<!-- Decisions Tab -->
			{:else if activeTab === 'decisions'}
				<div class="space-y-2">
					{#if decisions.length === 0}
						<p class="text-center text-sm text-jet/40 dark:text-ivory/40 py-8">No decisions yet.</p>
					{:else}
						{#each decisions as decision}
							<div class="flex items-center gap-4 rounded-xl border border-jet/5 dark:border-ivory/5 bg-white/50 dark:bg-jet-light/50 px-4 py-3">
								<span class="flex h-8 w-8 items-center justify-center rounded-full text-sm font-bold
									{decision.decision === 'yes' ? 'bg-swipe-yes/10 text-swipe-yes' : decision.decision === 'no' ? 'bg-swipe-no/10 text-swipe-no' : 'bg-swipe-skip/10 text-swipe-skip'}">
									{decision.decision === 'yes' ? '✓' : decision.decision === 'no' ? '✕' : '→'}
								</span>
								<div class="flex-1 min-w-0">
									<p class="text-sm font-medium text-jet dark:text-ivory truncate">{decision.cardTitle || decision.cardId}</p>
									<p class="text-xs text-jet/40 dark:text-ivory/40">{formatDate(decision.createdAt)}</p>
								</div>
								{#if decision.timeToDecision}
									<span class="text-xs text-jet/40 dark:text-ivory/40">{formatDuration(decision.timeToDecision)}</span>
								{/if}
							</div>
						{/each}
					{/if}
				</div>

			<!-- Settings Tab -->
			{:else if activeTab === 'settings'}
				<div class="space-y-8">
					<!-- Webhook -->
					<div>
						<h3 class="font-serif text-lg text-jet dark:text-ivory mb-3">Webhook</h3>
						<div class="rounded-xl border border-jet/10 dark:border-ivory/10 px-4 py-3">
							<p class="text-xs text-jet/50 dark:text-ivory/50 mb-1">Webhook URL</p>
							<p class="text-sm text-jet dark:text-ivory break-all">{app.webhookUrl || 'Not configured'}</p>
						</div>
					</div>

					<!-- API Keys -->
					<div>
						<div class="flex items-center justify-between mb-3">
							<h3 class="font-serif text-lg text-jet dark:text-ivory">API Keys</h3>
						</div>
						<div class="space-y-2 mb-4">
							{#each apiKeys as key}
								<div class="flex items-center justify-between rounded-xl border border-jet/10 dark:border-ivory/10 px-4 py-3">
									<div>
										<p class="text-sm font-medium text-jet dark:text-ivory">{key.label || 'Unnamed key'}</p>
										<p class="text-xs text-jet/40 dark:text-ivory/40 font-mono">{key.prefix}•••</p>
									</div>
									<button
										onclick={() => deleteApiKey(key.id)}
										class="text-xs text-rose hover:text-rose-light transition-colors"
									>
										Revoke
									</button>
								</div>
							{/each}
							{#if apiKeys.length === 0}
								<p class="text-sm text-jet/40 dark:text-ivory/40">No API keys.</p>
							{/if}
						</div>
						<div class="flex gap-2">
							<input
								type="text"
								bind:value={newKeyLabel}
								placeholder="Key label (optional)"
								class="flex-1 rounded-lg border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-3 py-2 text-sm text-jet dark:text-ivory outline-none focus:border-amber transition-colors"
							/>
							<button
								onclick={createApiKey}
								disabled={creatingKey}
								class="rounded-lg bg-amber px-4 py-2 text-xs font-medium text-jet hover:bg-amber-light disabled:opacity-50 transition-colors"
							>
								{creatingKey ? 'Creating...' : 'Create Key'}
							</button>
						</div>
					</div>
				</div>
			{/if}
		{/if}
	</div>
</div>
