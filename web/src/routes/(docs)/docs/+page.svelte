<svelte:head>
	<title>Documentation — JaNee</title>
</svelte:head>

<header class="mb-12">
	<h1 class="font-serif text-4xl font-bold tracking-tight text-jet sm:text-5xl dark:text-ivory">Documentation</h1>
	<p class="mt-4 max-w-2xl text-lg text-jet/60 dark:text-ivory/60">
		Everything you need to integrate with JaNee — from REST APIs and CLI tools to guides for building your first app.
	</p>
</header>

<div class="grid gap-6 sm:grid-cols-2">
	{#each [
		{
			href: '/docs/api',
			title: 'API Reference',
			description: 'Complete REST API documentation with endpoints, authentication, request and response examples.',
			icon: 'M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4'
		},
		{
			href: '/docs/cli',
			title: 'CLI Guide',
			description: 'Install and use the JaNee command-line tool to manage apps, cards, and decisions from your terminal.',
			icon: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z'
		},
		{
			href: '/docs/guides/create-app',
			title: 'Creating an App',
			description: 'Step-by-step walkthrough for creating your first JaNee app via the web UI, CLI, or API.',
			icon: 'M12 4v16m8-8H4'
		},
		{
			href: '/docs/guides/webhooks',
			title: 'Webhooks',
			description: 'Set up real-time notifications when decisions are made. Integrate with Slack, Zapier, and more.',
			icon: 'M13 10V3L4 14h7v7l9-11h-7z'
		},
		{
			href: '/docs/guides',
			title: 'All Guides',
			description: 'Browse all tutorials and how-to guides for getting the most out of JaNee.',
			icon: 'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253'
		}
	] as card}
		<a
			href={card.href}
			class="group rounded-xl border border-jet/5 bg-white p-6 transition-all hover:border-amber/30 hover:shadow-lg dark:border-ivory/5 dark:bg-jet-light dark:hover:border-amber/30"
		>
			<div class="mb-4 flex h-10 w-10 items-center justify-center rounded-lg bg-amber/10">
				<svg class="h-5 w-5 text-amber" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
					<path stroke-linecap="round" stroke-linejoin="round" d={card.icon} />
				</svg>
			</div>
			<h2 class="font-serif text-lg font-semibold text-jet group-hover:text-amber dark:text-ivory dark:group-hover:text-amber">
				{card.title}
			</h2>
			<p class="mt-2 text-sm leading-relaxed text-jet/60 dark:text-ivory/60">
				{card.description}
			</p>
		</a>
	{/each}
</div>
