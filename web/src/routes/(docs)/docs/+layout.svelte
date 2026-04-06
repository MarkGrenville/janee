<script lang="ts">
	import { page } from '$app/stores';

	let { children } = $props();

	const navSections = [
		{
			title: 'Getting Started',
			links: [
				{ href: '/docs', label: 'Overview' },
				{ href: '/docs/api', label: 'API Reference' },
				{ href: '/docs/cli', label: 'CLI Guide' }
			]
		},
		{
			title: 'Guides',
			links: [
				{ href: '/docs/guides', label: 'All Guides' },
				{ href: '/docs/guides/create-app', label: 'Creating an App' },
				{ href: '/docs/guides/webhooks', label: 'Webhooks' }
			]
		}
	];

	let sidebarOpen = $state(false);

	const breadcrumbs = $derived(() => {
		const path = $page.url.pathname;
		const segments = path.split('/').filter(Boolean);
		const crumbs: { label: string; href: string }[] = [];
		let accumulated = '';
		const labelMap: Record<string, string> = {
			docs: 'Documentation',
			api: 'API Reference',
			cli: 'CLI Guide',
			guides: 'Guides',
			'create-app': 'Creating an App',
			webhooks: 'Webhooks'
		};
		for (const seg of segments) {
			accumulated += '/' + seg;
			crumbs.push({
				label: labelMap[seg] || seg,
				href: accumulated
			});
		}
		return crumbs;
	});
</script>

<div class="min-h-screen bg-ivory dark:bg-jet">
	<!-- Mobile sidebar toggle -->
	<button
		onclick={() => (sidebarOpen = !sidebarOpen)}
		class="fixed top-4 left-4 z-50 rounded-lg bg-ivory-dark p-2 shadow-md lg:hidden dark:bg-jet-light"
		aria-label="Toggle navigation"
	>
		<svg class="h-5 w-5 text-jet dark:text-ivory" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
			{#if sidebarOpen}
				<path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
			{:else}
				<path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
			{/if}
		</svg>
	</button>

	<!-- Sidebar backdrop -->
	{#if sidebarOpen}
		<button
			class="fixed inset-0 z-30 bg-black/40 lg:hidden"
			onclick={() => (sidebarOpen = false)}
			aria-label="Close navigation"
		></button>
	{/if}

	<!-- Sidebar -->
	<aside
		class="fixed top-0 left-0 z-40 h-full w-64 transform overflow-y-auto border-r border-jet/5 bg-ivory p-6 transition-transform duration-200 lg:translate-x-0 dark:border-ivory/5 dark:bg-jet {sidebarOpen ? 'translate-x-0' : '-translate-x-full'}"
	>
		<div class="mb-8">
			<a href="/" class="group flex items-center gap-2 text-sm text-jet/50 transition-colors hover:text-amber dark:text-ivory/50 dark:hover:text-amber">
				<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
					<path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
				</svg>
				Back to JaNee
			</a>
		</div>

		<a href="/docs" class="mb-8 block font-serif text-xl font-bold tracking-tight text-jet dark:text-ivory">
			Docs
		</a>

		<nav class="space-y-6">
			{#each navSections as section}
				<div>
					<h3 class="mb-2 text-xs font-semibold tracking-widest text-jet/40 uppercase dark:text-ivory/40">
						{section.title}
					</h3>
					<ul class="space-y-1">
						{#each section.links as link}
							<li>
								<a
									href={link.href}
									class="block rounded-md px-3 py-1.5 text-sm transition-colors {$page.url.pathname === link.href
										? 'bg-amber/10 font-medium text-amber'
										: 'text-jet/70 hover:bg-jet/5 hover:text-jet dark:text-ivory/70 dark:hover:bg-ivory/5 dark:hover:text-ivory'}"
								>
									{link.label}
								</a>
							</li>
						{/each}
					</ul>
				</div>
			{/each}
		</nav>
	</aside>

	<!-- Main content -->
	<main class="lg:pl-64">
		<div class="mx-auto max-w-4xl px-6 py-12 sm:px-8 lg:px-12">
			<!-- Breadcrumb -->
			<nav class="mb-8 flex items-center gap-1.5 text-sm text-jet/40 dark:text-ivory/40" aria-label="Breadcrumb">
				{#each breadcrumbs() as crumb, i}
					{#if i > 0}
						<svg class="h-3.5 w-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
							<path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
						</svg>
					{/if}
					{#if i === breadcrumbs().length - 1}
						<span class="text-jet dark:text-ivory">{crumb.label}</span>
					{:else}
						<a href={crumb.href} class="transition-colors hover:text-amber">{crumb.label}</a>
					{/if}
				{/each}
			</nav>

			{@render children()}
		</div>
	</main>
</div>
