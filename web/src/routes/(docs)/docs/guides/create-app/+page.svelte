<svelte:head>
	<title>Creating an App — JaNee Docs</title>
</svelte:head>

<header class="mb-12">
	<h1 class="font-serif text-4xl font-bold tracking-tight text-jet sm:text-5xl dark:text-ivory">Creating an App</h1>
	<p class="mt-4 max-w-2xl text-lg text-jet/60 dark:text-ivory/60">
		A JaNee app is a collection of cards for users to swipe on. Create one via the web UI, CLI, or API.
	</p>
</header>

<!-- Table of contents -->
<nav class="mb-12 rounded-xl border border-jet/5 bg-white p-6 dark:border-ivory/5 dark:bg-jet-light">
	<h2 class="mb-3 text-sm font-semibold tracking-widest text-jet/40 uppercase dark:text-ivory/40">On this page</h2>
	<ul class="space-y-1 text-sm">
		{#each [
			['#web-ui', 'Via the Web UI'],
			['#cli', 'Via the CLI'],
			['#api', 'Via the API'],
			['#adding-cards', 'Adding Cards'],
			['#public-vs-private', 'Public vs Private'],
			['#webhooks', 'Setting Up Webhooks']
		] as [href, label]}
			<li>
				<a href={href} class="text-jet/60 transition-colors hover:text-amber dark:text-ivory/60 dark:hover:text-amber">{label}</a>
			</li>
		{/each}
	</ul>
</nav>

<!-- Via Web UI -->
<section id="web-ui" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Via the Web UI</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>The quickest way to get started is through the JaNee web app.</p>
		<ol class="list-inside list-decimal space-y-3 marker:text-amber marker:font-semibold">
			<li>
				<strong class="text-jet dark:text-ivory">Navigate to Apps.</strong>
				Sign in and click <strong>Apps</strong> in the sidebar, then click <strong>New App</strong>.
			</li>
			<li>
				<strong class="text-jet dark:text-ivory">Fill in the details.</strong>
				Give your app a name and optional description. Choose whether it should be public or private.
			</li>
			<li>
				<strong class="text-jet dark:text-ivory">Save.</strong>
				Click <strong>Create</strong> to save your app. You'll be taken to the app's card management page where you can start adding cards.
			</li>
		</ol>
	</div>
</section>

<!-- Via CLI -->
<section id="cli" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Via the CLI</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>If you prefer the command line, use the JaNee CLI:</p>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">npx janee-cli create-app &lt;api-key&gt; "Movie Watchlist" --public --description "Films to watch"</code></pre>
		<p>This creates a public app named "Movie Watchlist" and outputs the new app ID.</p>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 text-xs leading-relaxed text-ivory dark:bg-jet-lighter"><code>✓ App created successfully
  ID: abc123
  Name: Movie Watchlist
  Public: Yes</code></pre>
	</div>
</section>

<!-- Via API -->
<section id="api" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Via the API</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>Send a <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">POST</code> request to <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">/api/apps</code>:</p>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">{`curl -X POST https://janee.app/api/apps \\
  -H "Authorization: Bearer <your-token>" \\
  -H "Content-Type: application/json" \\
  -d '{
    "name": "Movie Watchlist",
    "description": "Films to watch this year",
    "isPublic": true
  }'`}</code></pre>
		<p>The response includes the new app object with its generated ID:</p>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 text-xs leading-relaxed text-ivory dark:bg-jet-lighter"><code>{`{
  "id": "abc123",
  "name": "Movie Watchlist",
  "description": "Films to watch this year",
  "isPublic": true,
  "ownerId": "user_456",
  "createdAt": "2025-01-15T10:30:00.000Z"
}`}</code></pre>
	</div>
</section>

<!-- Adding Cards -->
<section id="adding-cards" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Adding Cards</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>Once your app is created, add cards for users to swipe on. Each card has a title and optional description, image, and link.</p>

		<h3 class="font-serif text-lg font-medium text-jet dark:text-ivory">Web UI</h3>
		<p>Navigate to your app and click <strong>Add Card</strong>. Fill in the title, description, and optional image URL.</p>

		<h3 class="font-serif text-lg font-medium text-jet dark:text-ivory">CLI</h3>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">npx janee-cli add-card &lt;api-key&gt; abc123 "The Godfather" \
  --description "1972 crime drama" \
  --image "https://example.com/godfather.jpg"</code></pre>

		<h3 class="font-serif text-lg font-medium text-jet dark:text-ivory">API</h3>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">{`curl -X POST https://janee.app/api/apps/abc123/cards \\
  -H "x-api-key: jn_live_a1b2c3..." \\
  -H "Content-Type: application/json" \\
  -d '{
    "title": "The Godfather",
    "description": "1972 crime drama",
    "imageUrl": "https://example.com/godfather.jpg"
  }'`}</code></pre>
	</div>
</section>

<!-- Public vs Private -->
<section id="public-vs-private" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Public vs Private</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<div class="grid gap-4 sm:grid-cols-2">
			<div class="rounded-lg border border-jet/5 p-4 dark:border-ivory/5">
				<h3 class="mb-2 font-medium text-jet dark:text-ivory">Public Apps</h3>
				<ul class="space-y-1 text-jet/60 dark:text-ivory/60">
					<li>• Discoverable by all authenticated users</li>
					<li>• Anyone can subscribe and swipe</li>
					<li>• Only the owner can add/edit cards</li>
					<li>• Great for polls, surveys, community lists</li>
				</ul>
			</div>
			<div class="rounded-lg border border-jet/5 p-4 dark:border-ivory/5">
				<h3 class="mb-2 font-medium text-jet dark:text-ivory">Private Apps</h3>
				<ul class="space-y-1 text-jet/60 dark:text-ivory/60">
					<li>• Only visible to the owner</li>
					<li>• Can be shared via direct subscription</li>
					<li>• Ideal for personal lists, approvals</li>
					<li>• API key access still works</li>
				</ul>
			</div>
		</div>
		<p>
			Toggle privacy any time by updating the app via the web UI or by sending a
			<code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">PUT /api/apps/:appId</code>
			request with <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">{`{"isPublic": true}`}</code>.
		</p>
	</div>
</section>

<!-- Webhooks -->
<section id="webhooks" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Setting Up Webhooks</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>
			Webhooks notify an external URL whenever a decision is made in your app. Set a webhook URL when creating your app, or update it later.
		</p>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">{`curl -X PUT https://janee.app/api/apps/abc123 \\
  -H "Authorization: Bearer <your-token>" \\
  -H "Content-Type: application/json" \\
  -d '{"webhookUrl": "https://example.com/janee-webhook"}'`}</code></pre>
		<p>
			For a deeper dive, see the <a href="/docs/guides/webhooks" class="font-medium text-amber underline decoration-amber/30 hover:decoration-amber">Webhooks guide</a>.
		</p>
	</div>
</section>
