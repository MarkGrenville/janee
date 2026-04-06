<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { api } from '$lib/firebase/api';

	let apps = $state<any[]>([]);
	let loading = $state(true);
	let error = $state('');

	onMount(async () => {
		try {
			apps = await api.apps.list();
		} catch (e: any) {
			error = e.message;
			console.log('[apps] Error loading apps:', e.message);
		} finally {
			loading = false;
		}
	});
</script>

<div class="px-6 py-6 md:px-8 md:py-8">
	<div class="mx-auto max-w-4xl">
		<!-- Header -->
		<div class="flex items-center justify-between mb-8">
			<h1 class="font-serif text-2xl md:text-3xl text-jet dark:text-ivory">Apps</h1>
			<button
				onclick={() => goto('/apps/new')}
				class="inline-flex items-center gap-2 rounded-xl bg-amber px-5 py-2.5 text-sm font-medium text-jet hover:bg-amber-light transition-colors active:scale-[0.98]"
			>
				<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
					<path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
				</svg>
				Create App
			</button>
		</div>

		{#if loading}
			<div class="flex items-center justify-center py-20">
				<div class="h-8 w-8 animate-spin rounded-full border-2 border-amber border-t-transparent"></div>
			</div>
		{:else if error}
			<div class="rounded-2xl glass dark:glass p-8 text-center">
				<p class="text-rose mb-3">{error}</p>
				<button onclick={() => location.reload()} class="text-sm text-amber hover:text-amber-light transition-colors">Try again</button>
			</div>
		{:else if apps.length === 0}
			<div class="rounded-2xl glass dark:glass p-12 text-center">
				<div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-amber/10">
					<svg class="h-8 w-8 text-amber" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
						<path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6zM3.75 15.75A2.25 2.25 0 016 13.5h2.25a2.25 2.25 0 012.25 2.25V18a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18v-2.25zM13.5 6a2.25 2.25 0 012.25-2.25H18A2.25 2.25 0 0120.25 6v2.25A2.25 2.25 0 0118 10.5h-2.25a2.25 2.25 0 01-2.25-2.25V6zM13.5 15.75a2.25 2.25 0 012.25-2.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-2.25A2.25 2.25 0 0113.5 18v-2.25z" />
					</svg>
				</div>
				<h2 class="font-serif text-lg text-jet dark:text-ivory mb-2">No apps yet</h2>
				<p class="text-sm text-jet/60 dark:text-ivory/60 mb-6">Create your first app to start making decisions.</p>
				<button
					onclick={() => goto('/apps/new')}
					class="inline-flex items-center gap-2 rounded-xl bg-amber px-5 py-2.5 text-sm font-medium text-jet hover:bg-amber-light transition-colors"
				>
					Create your first app
				</button>
			</div>
		{:else}
			<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
				{#each apps as app}
					<button
						onclick={() => goto(`/apps/${app.id}`)}
						class="group rounded-2xl glass dark:glass p-6 text-left hover:bg-white/10 dark:hover:bg-ivory/5 transition-all duration-200 hover:shadow-lg"
					>
						<div class="flex items-start gap-3 mb-3">
							{#if app.icon}
								<span class="text-3xl">{app.icon}</span>
							{:else}
								<div class="flex h-10 w-10 items-center justify-center rounded-xl bg-amber/10 text-amber">
									<svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
										<path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6z" />
									</svg>
								</div>
							{/if}
							<div class="flex-1 min-w-0">
								<h3 class="font-serif text-lg text-jet dark:text-ivory group-hover:text-amber transition-colors truncate">{app.name}</h3>
								{#if app.isPublic}
									<span class="text-[10px] uppercase tracking-wider text-sage">Public</span>
								{:else}
									<span class="text-[10px] uppercase tracking-wider text-jet/40 dark:text-ivory/40">Private</span>
								{/if}
							</div>
						</div>
						{#if app.description}
							<p class="text-sm text-jet/60 dark:text-ivory/60 line-clamp-2 mb-4">{app.description}</p>
						{/if}
						<div class="flex items-center gap-4 text-xs text-jet/40 dark:text-ivory/40">
							{#if app.cardCount !== undefined}
								<span>{app.cardCount} cards</span>
							{/if}
							{#if app.subscriberCount !== undefined}
								<span>{app.subscriberCount} subscribers</span>
							{/if}
						</div>
					</button>
				{/each}
			</div>
		{/if}
	</div>
</div>
