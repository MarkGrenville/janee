<svelte:head>
	<title>CLI Guide — JaNee Docs</title>
</svelte:head>

<header class="mb-12">
	<h1 class="font-serif text-4xl font-bold tracking-tight text-jet sm:text-5xl dark:text-ivory">CLI Guide</h1>
	<p class="mt-4 max-w-2xl text-lg text-jet/60 dark:text-ivory/60">
		Manage JaNee apps, cards, and decisions from your terminal.
	</p>
</header>

<!-- Installation -->
<section class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Installation</h2>
	<p class="mb-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		Run commands directly with <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">npx</code> or install globally:
	</p>
	<div class="space-y-3">
		<div>
			<p class="mb-1 text-xs font-medium text-jet/40 dark:text-ivory/40">Run without installing</p>
			<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">npx janee-cli &lt;command&gt; [options]</code></pre>
		</div>
		<div>
			<p class="mb-1 text-xs font-medium text-jet/40 dark:text-ivory/40">Install globally</p>
			<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">npm install -g janee-cli</code></pre>
		</div>
	</div>
</section>

<!-- Authentication -->
<section class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Authentication</h2>
	<p class="mb-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		All CLI commands require an API key. Generate one from the JaNee web app under
		<strong>Settings → API Keys</strong>, or via the API:
	</p>
	<pre class="mb-4 overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">{`curl -X POST https://janee.app/api/keys \\
  -H "Authorization: Bearer <your-token>" \\
  -H "Content-Type: application/json" \\
  -d '{"appId": "abc123", "name": "CLI Key"}'`}</code></pre>
	<p class="text-sm text-jet/70 dark:text-ivory/70">
		Pass the key as the first argument to any command, or set the <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">JANEE_API_KEY</code> environment variable.
	</p>
</section>

<!-- Commands -->
<section class="mb-12">
	<h2 class="mb-6 font-serif text-2xl font-semibold text-jet dark:text-ivory">Commands</h2>

	<div class="space-y-8">
		{#each [
			{
				name: 'health',
				syntax: 'janee-cli health',
				description: 'Check if the JaNee API is reachable and responding.',
				example: `$ janee-cli health
✓ API is healthy
  Status: ok
  Timestamp: 2025-01-15T10:30:00.000Z`
			},
			{
				name: 'seed',
				syntax: 'janee-cli seed <api-key>',
				description: 'Populate an app with sample cards for testing.',
				example: `$ janee-cli seed jn_live_a1b2c3...
✓ Seeded 10 sample cards into "Movie Watchlist"
  Cards: The Godfather, Pulp Fiction, Inception, ...`
			},
			{
				name: 'list-apps',
				syntax: 'janee-cli list-apps <api-key>',
				description: 'List all apps accessible with the given API key.',
				example: `$ janee-cli list-apps jn_live_a1b2c3...
┌──────────┬──────────────────┬────────┬───────┐
│ ID       │ Name             │ Public │ Cards │
├──────────┼──────────────────┼────────┼───────┤
│ abc123   │ Movie Watchlist  │ Yes    │ 24    │
│ def456   │ Date Night Ideas │ No     │ 12    │
└──────────┴──────────────────┴────────┴───────┘`
			},
			{
				name: 'create-app',
				syntax: 'janee-cli create-app <api-key> "<name>" [--public] [--description "<desc>"]',
				description: 'Create a new app. Optionally set it as public and add a description.',
				example: `$ janee-cli create-app jn_live_a1b2c3... "Book Club Picks" --public
✓ App created successfully
  ID: ghi789
  Name: Book Club Picks
  Public: Yes`
			},
			{
				name: 'add-card',
				syntax: 'janee-cli add-card <api-key> <app-id> "<title>" [--description "<desc>"] [--image "<url>"]',
				description: 'Add a new card to an app.',
				example: `$ janee-cli add-card jn_live_a1b2c3... abc123 "Dune" --description "Sci-fi epic"
✓ Card added
  ID: card_099
  Title: Dune
  App: Movie Watchlist`
			},
			{
				name: 'list-cards',
				syntax: 'janee-cli list-cards <api-key> <app-id> [--undecided]',
				description: 'List all cards in an app. Use --undecided to show only cards without a decision.',
				example: `$ janee-cli list-cards jn_live_a1b2c3... abc123 --undecided
┌──────────┬─────────────┬──────────────────┐
│ ID       │ Title       │ Description      │
├──────────┼─────────────┼──────────────────┤
│ card_005 │ Parasite    │ 2019 thriller    │
│ card_012 │ Arrival     │ Sci-fi drama     │
└──────────┴─────────────┴──────────────────┘`
			},
			{
				name: 'decide',
				syntax: 'janee-cli decide <api-key> <app-id> <card-id> <yes|no|skip>',
				description: 'Submit a decision on a specific card.',
				example: `$ janee-cli decide jn_live_a1b2c3... abc123 card_005 yes
✓ Decision recorded
  Card: Parasite
  Decision: yes`
			},
			{
				name: 'create-key',
				syntax: 'janee-cli create-key <bearer-token> <app-id> "<name>"',
				description: 'Generate a new API key for an app. Requires a Bearer token (not an API key).',
				example: `$ janee-cli create-key eyJhbG... abc123 "Deploy Key"
✓ API key created
  ID: key_042
  Key: jn_live_x9y8z7...
  ⚠ Save this key — it won't be shown again.`
			}
		] as cmd}
			<div class="rounded-xl border border-jet/5 bg-white p-6 dark:border-ivory/5 dark:bg-jet-light">
				<h3 class="font-serif text-lg font-semibold text-jet dark:text-ivory">{cmd.name}</h3>
				<p class="mt-1 text-sm text-jet/60 dark:text-ivory/60">{cmd.description}</p>
				<div class="mt-3">
					<p class="mb-1 text-xs font-medium text-jet/40 dark:text-ivory/40">Syntax</p>
					<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-2 dark:bg-jet-lighter"><code class="text-sm text-amber">{cmd.syntax}</code></pre>
				</div>
				<div class="mt-3">
					<p class="mb-1 text-xs font-medium text-jet/40 dark:text-ivory/40">Example</p>
					<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 text-xs leading-relaxed text-ivory dark:bg-jet-lighter"><code>{cmd.example}</code></pre>
				</div>
			</div>
		{/each}
	</div>
</section>
