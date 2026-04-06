<svelte:head>
	<title>Guides — JaNee Docs</title>
</svelte:head>

<header class="mb-12">
	<h1 class="font-serif text-4xl font-bold tracking-tight text-jet sm:text-5xl dark:text-ivory">Guides</h1>
	<p class="mt-4 max-w-2xl text-lg text-jet/60 dark:text-ivory/60">
		Step-by-step tutorials for common tasks in JaNee.
	</p>
</header>

<div class="grid gap-6 sm:grid-cols-2">
	{#each [
		{
			href: '/docs/guides/create-app',
			title: 'Creating an App',
			description: 'Build your first JaNee app from scratch — via the web UI, CLI, or REST API. Add cards, configure privacy, and set up webhooks.',
			icon: 'M12 4v16m8-8H4'
		},
		{
			href: '/docs/guides/webhooks',
			title: 'Webhooks',
			description: 'Receive real-time HTTP callbacks when decisions are made. Connect JaNee to Slack, Zapier, n8n, and custom backends.',
			icon: 'M13 10V3L4 14h7v7l9-11h-7z'
		}
	] as guide}
		<a
			href={guide.href}
			class="group rounded-xl border border-jet/5 bg-white p-6 transition-all hover:border-amber/30 hover:shadow-lg dark:border-ivory/5 dark:bg-jet-light dark:hover:border-amber/30"
		>
			<div class="mb-4 flex h-10 w-10 items-center justify-center rounded-lg bg-amber/10">
				<svg class="h-5 w-5 text-amber" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
					<path stroke-linecap="round" stroke-linejoin="round" d={guide.icon} />
				</svg>
			</div>
			<h2 class="font-serif text-lg font-semibold text-jet group-hover:text-amber dark:text-ivory dark:group-hover:text-amber">
				{guide.title}
			</h2>
			<p class="mt-2 text-sm leading-relaxed text-jet/60 dark:text-ivory/60">
				{guide.description}
			</p>
		</a>
	{/each}
</div>
