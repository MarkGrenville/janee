<script lang="ts">
	import { onMount } from 'svelte';
	import { api } from '$lib/firebase/api';

	let apps = $state<any[]>([]);
	let decisions = $state<any[]>([]);
	let loading = $state(true);
	let error = $state('');

	let filterApp = $state('all');
	let filterDecision = $state('all');

	let filteredDecisions = $derived(
		decisions.filter((d: any) => {
			if (filterApp !== 'all' && d.appId !== filterApp) return false;
			if (filterDecision !== 'all' && d.decision !== filterDecision) return false;
			return true;
		})
	);

	onMount(async () => {
		await loadData();
	});

	async function loadData() {
		loading = true;
		error = '';
		try {
			apps = await api.apps.list();
			const allDecisions: any[] = [];
			for (const app of apps) {
				try {
					const appDecisions = await api.decisions.list(app.id);
					allDecisions.push(...appDecisions.map((d: any) => ({ ...d, appId: app.id, appName: app.name, appIcon: app.icon })));
				} catch {
					// skip apps where we can't list decisions
				}
			}
			allDecisions.sort((a: any, b: any) => {
				const aTime = a.createdAt?.toDate?.() || new Date(a.createdAt || 0);
				const bTime = b.createdAt?.toDate?.() || new Date(b.createdAt || 0);
				return bTime.getTime() - aTime.getTime();
			});
			decisions = allDecisions;
		} catch (e: any) {
			error = e.message;
			console.log('[decisions] Error loading decisions:', e.message);
		} finally {
			loading = false;
		}
	}

	function formatDate(ts: any): string {
		if (!ts) return '—';
		const d = ts.toDate ? ts.toDate() : new Date(ts);
		return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
	}

	function formatDuration(ms: number): string {
		if (!ms) return '—';
		if (ms < 1000) return `${ms}ms`;
		return `${(ms / 1000).toFixed(1)}s`;
	}

	function decisionColor(d: string): string {
		if (d === 'yes') return 'bg-swipe-yes/10 text-swipe-yes';
		if (d === 'no') return 'bg-swipe-no/10 text-swipe-no';
		return 'bg-swipe-skip/10 text-swipe-skip';
	}

	function decisionLabel(d: string): string {
		if (d === 'yes') return 'Yes';
		if (d === 'no') return 'No';
		return 'Skip';
	}
</script>

<div class="px-6 py-6 md:px-8 md:py-8">
	<div class="mx-auto max-w-3xl">
		<h1 class="font-serif text-2xl md:text-3xl text-jet dark:text-ivory mb-6">Decisions</h1>

		<!-- Filters -->
		<div class="flex flex-wrap gap-3 mb-6">
			<select
				bind:value={filterApp}
				class="rounded-xl border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-4 py-2 text-sm text-jet dark:text-ivory outline-none focus:border-amber transition-colors"
			>
				<option value="all">All Apps</option>
				{#each apps as app}
					<option value={app.id}>{app.icon || ''} {app.name}</option>
				{/each}
			</select>

			<select
				bind:value={filterDecision}
				class="rounded-xl border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-4 py-2 text-sm text-jet dark:text-ivory outline-none focus:border-amber transition-colors"
			>
				<option value="all">All Decisions</option>
				<option value="yes">Yes</option>
				<option value="no">No</option>
				<option value="skip">Skip</option>
			</select>
		</div>

		{#if loading}
			<div class="flex items-center justify-center py-20">
				<div class="h-8 w-8 animate-spin rounded-full border-2 border-amber border-t-transparent"></div>
			</div>
		{:else if error}
			<div class="rounded-2xl glass dark:glass p-8 text-center">
				<p class="text-rose mb-3">{error}</p>
			</div>
		{:else if filteredDecisions.length === 0}
			<div class="rounded-2xl glass dark:glass p-12 text-center">
				<div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-amber/10">
					<svg class="h-8 w-8 text-amber" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
						<path stroke-linecap="round" stroke-linejoin="round" d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15a2.25 2.25 0 012.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25z" />
					</svg>
				</div>
				<h2 class="font-serif text-lg text-jet dark:text-ivory mb-2">No decisions yet</h2>
				<p class="text-sm text-jet/60 dark:text-ivory/60">Start swiping on some cards to see your decisions here.</p>
			</div>
		{:else}
			<!-- Decision count -->
			<p class="text-xs text-jet/40 dark:text-ivory/40 mb-4">{filteredDecisions.length} decisions</p>

			<!-- Decision list -->
			<div class="space-y-2">
				{#each filteredDecisions as decision}
					<div class="flex items-center gap-4 rounded-xl border border-jet/5 dark:border-ivory/5 bg-white/50 dark:bg-jet-light/50 px-4 py-3">
						<span class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-xs font-bold {decisionColor(decision.decision)}">
							{decision.decision === 'yes' ? '✓' : decision.decision === 'no' ? '✕' : '→'}
						</span>
						<div class="flex-1 min-w-0">
							<p class="text-sm font-medium text-jet dark:text-ivory truncate">{decision.cardTitle || decision.cardId}</p>
							<div class="flex items-center gap-2 mt-0.5">
								{#if decision.appIcon}
									<span class="text-xs">{decision.appIcon}</span>
								{/if}
								<span class="text-xs text-jet/40 dark:text-ivory/40">{decision.appName}</span>
							</div>
						</div>
						<div class="text-right shrink-0">
							<span class="inline-block rounded-full px-2 py-0.5 text-[10px] font-medium uppercase tracking-wider {decisionColor(decision.decision)}">
								{decisionLabel(decision.decision)}
							</span>
							<p class="text-[10px] text-jet/30 dark:text-ivory/30 mt-1">{formatDate(decision.createdAt)}</p>
						</div>
						{#if decision.timeToDecision}
							<span class="hidden sm:block text-xs text-jet/30 dark:text-ivory/30 tabular-nums shrink-0">{formatDuration(decision.timeToDecision)}</span>
						{/if}
					</div>
				{/each}
			</div>
		{/if}
	</div>
</div>
