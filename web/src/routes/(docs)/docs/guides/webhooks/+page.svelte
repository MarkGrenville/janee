<svelte:head>
	<title>Webhooks — JaNee Docs</title>
</svelte:head>

<header class="mb-12">
	<h1 class="font-serif text-4xl font-bold tracking-tight text-jet sm:text-5xl dark:text-ivory">Webhooks</h1>
	<p class="mt-4 max-w-2xl text-lg text-jet/60 dark:text-ivory/60">
		Receive real-time HTTP callbacks when decisions are made in your JaNee app.
	</p>
</header>

<!-- Table of contents -->
<nav class="mb-12 rounded-xl border border-jet/5 bg-white p-6 dark:border-ivory/5 dark:bg-jet-light">
	<h2 class="mb-3 text-sm font-semibold tracking-widest text-jet/40 uppercase dark:text-ivory/40">On this page</h2>
	<ul class="space-y-1 text-sm">
		{#each [
			['#overview', 'Overview'],
			['#app-webhooks', 'App-Level Webhooks'],
			['#card-webhooks', 'Card-Level Webhooks'],
			['#payload', 'Payload Format'],
			['#responses', 'Handling Responses'],
			['#integrations', 'Integration Examples']
		] as [href, label]}
			<li>
				<a href={href} class="text-jet/60 transition-colors hover:text-amber dark:text-ivory/60 dark:hover:text-amber">{label}</a>
			</li>
		{/each}
	</ul>
</nav>

<!-- Overview -->
<section id="overview" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Overview</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>
			Webhooks let you react to decisions in real time. When a user swipes yes, no, or skip on a card,
			JaNee sends a <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">POST</code> request
			to your configured URL with the decision details.
		</p>
		<p>Common use cases:</p>
		<ul class="space-y-1">
			<li>• Notify a Slack channel when a card is approved</li>
			<li>• Trigger a Zapier automation on each decision</li>
			<li>• Update an external database with approval status</li>
			<li>• Send email confirmations for important decisions</li>
		</ul>
	</div>
</section>

<!-- App-Level Webhooks -->
<section id="app-webhooks" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">App-Level Webhooks</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>
			An app-level webhook fires for <strong>every</strong> decision made on any card in the app. Set it when creating the app or update it later.
		</p>

		<h3 class="font-serif text-lg font-medium text-jet dark:text-ivory">When creating an app</h3>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">{`curl -X POST https://janee.app/api/apps \\
  -H "Authorization: Bearer <your-token>" \\
  -H "Content-Type: application/json" \\
  -d '{
    "name": "Approval Queue",
    "webhookUrl": "https://example.com/hooks/janee"
  }'`}</code></pre>

		<h3 class="font-serif text-lg font-medium text-jet dark:text-ivory">Updating an existing app</h3>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">{`curl -X PUT https://janee.app/api/apps/abc123 \\
  -H "Authorization: Bearer <your-token>" \\
  -H "Content-Type: application/json" \\
  -d '{
    "webhookUrl": "https://example.com/hooks/janee"
  }'`}</code></pre>

		<p>Set <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">webhookUrl</code> to <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">null</code> to disable.</p>
	</div>
</section>

<!-- Card-Level Webhooks -->
<section id="card-webhooks" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Card-Level Webhooks</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>
			Card-level webhooks fire only when a decision is made on a specific card. Useful when individual cards need different handling.
		</p>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter"><code class="text-sm text-ivory">{`curl -X PUT https://janee.app/api/apps/abc123/cards/card_042 \\
  -H "x-api-key: jn_live_a1b2c3..." \\
  -H "Content-Type: application/json" \\
  -d '{
    "webhookUrl": "https://example.com/hooks/card-042"
  }'`}</code></pre>
		<div class="rounded-lg border border-amber/20 bg-amber/5 p-4">
			<p class="text-sm text-jet/80 dark:text-ivory/80">
				<strong>Note:</strong> If both an app-level and card-level webhook are configured, both will fire. The card-level webhook fires first.
			</p>
		</div>
	</div>
</section>

<!-- Payload Format -->
<section id="payload" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Payload Format</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>
			JaNee sends a <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">POST</code> request with a JSON body:
		</p>
		<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 text-xs leading-relaxed text-ivory dark:bg-jet-lighter"><code>{`{
  "event": "decision.created",
  "timestamp": "2025-01-15T10:30:00.000Z",
  "data": {
    "decisionId": "dec_789",
    "appId": "abc123",
    "appName": "Movie Watchlist",
    "cardId": "card_042",
    "cardTitle": "Inception",
    "userId": "user_456",
    "decision": "yes",
    "createdAt": "2025-01-15T10:30:00.000Z"
  }
}`}</code></pre>

		<h3 class="font-serif text-lg font-medium text-jet dark:text-ivory">Headers</h3>
		<div class="overflow-x-auto">
			<table class="w-full text-sm">
				<thead>
					<tr class="border-b border-jet/10 dark:border-ivory/10">
						<th class="py-2 pr-4 text-left font-medium text-jet dark:text-ivory">Header</th>
						<th class="py-2 text-left font-medium text-jet dark:text-ivory">Value</th>
					</tr>
				</thead>
				<tbody class="text-jet/60 dark:text-ivory/60">
					<tr class="border-b border-jet/5 dark:border-ivory/5">
						<td class="py-2 pr-4"><code class="text-xs">Content-Type</code></td>
						<td class="py-2"><code class="text-xs">application/json</code></td>
					</tr>
					<tr class="border-b border-jet/5 dark:border-ivory/5">
						<td class="py-2 pr-4"><code class="text-xs">X-JaNee-Event</code></td>
						<td class="py-2"><code class="text-xs">decision.created</code></td>
					</tr>
					<tr>
						<td class="py-2 pr-4"><code class="text-xs">X-JaNee-Signature</code></td>
						<td class="py-2"><code class="text-xs">sha256=&lt;hmac-signature&gt;</code></td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</section>

<!-- Handling Responses -->
<section id="responses" class="mb-12">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Handling Responses</h2>
	<div class="space-y-4 text-sm leading-relaxed text-jet/70 dark:text-ivory/70">
		<p>Your endpoint should return a <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">2xx</code> status code to acknowledge receipt.</p>

		<div class="overflow-x-auto">
			<table class="w-full text-sm">
				<thead>
					<tr class="border-b border-jet/10 dark:border-ivory/10">
						<th class="py-2 pr-4 text-left font-medium text-jet dark:text-ivory">Status</th>
						<th class="py-2 text-left font-medium text-jet dark:text-ivory">Behavior</th>
					</tr>
				</thead>
				<tbody class="text-jet/60 dark:text-ivory/60">
					<tr class="border-b border-jet/5 dark:border-ivory/5">
						<td class="py-2 pr-4"><code class="text-xs">200–299</code></td>
						<td class="py-2">Delivery confirmed. No retry.</td>
					</tr>
					<tr class="border-b border-jet/5 dark:border-ivory/5">
						<td class="py-2 pr-4"><code class="text-xs">4xx</code></td>
						<td class="py-2">Client error. No retry. Logged in webhook history.</td>
					</tr>
					<tr>
						<td class="py-2 pr-4"><code class="text-xs">5xx / timeout</code></td>
						<td class="py-2">Retried up to 3 times with exponential backoff (5s, 30s, 120s).</td>
					</tr>
				</tbody>
			</table>
		</div>

		<div class="rounded-lg border border-amber/20 bg-amber/5 p-4">
			<p class="text-sm text-jet/80 dark:text-ivory/80">
				<strong>Tip:</strong> Respond quickly (under 5 seconds). Process heavy logic asynchronously after acknowledging receipt.
			</p>
		</div>
	</div>
</section>

<!-- Integration Examples -->
<section id="integrations" class="mb-12">
	<h2 class="mb-6 font-serif text-2xl font-semibold text-jet dark:text-ivory">Integration Examples</h2>

	<div class="space-y-8">
		<!-- Slack -->
		<div class="rounded-xl border border-jet/5 bg-white p-6 dark:border-ivory/5 dark:bg-jet-light">
			<h3 class="mb-3 font-serif text-lg font-semibold text-jet dark:text-ivory">Slack</h3>
			<div class="space-y-3 text-sm text-jet/70 dark:text-ivory/70">
				<p>Forward decisions to a Slack channel using an Incoming Webhook.</p>
				<ol class="list-inside list-decimal space-y-2 marker:text-amber marker:font-semibold">
					<li>Create a <a href="https://api.slack.com/messaging/webhooks" class="font-medium text-amber underline decoration-amber/30 hover:decoration-amber" target="_blank" rel="noopener">Slack Incoming Webhook</a></li>
					<li>Set the Slack webhook URL as your JaNee app's webhook URL</li>
					<li>Or use a proxy that transforms the JaNee payload into Slack's block format:</li>
				</ol>
				<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 text-xs leading-relaxed text-ivory dark:bg-jet-lighter"><code>{`// Express handler example
app.post('/janee-to-slack', async (req, res) => {
  const { data } = req.body;
  await fetch(SLACK_WEBHOOK_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      text: \`\${data.decision === 'yes' ? '✅' : '❌'} *\${data.cardTitle}* — \${data.decision} by user \${data.userId}\`
    })
  });
  res.sendStatus(200);
});`}</code></pre>
			</div>
		</div>

		<!-- Zapier -->
		<div class="rounded-xl border border-jet/5 bg-white p-6 dark:border-ivory/5 dark:bg-jet-light">
			<h3 class="mb-3 font-serif text-lg font-semibold text-jet dark:text-ivory">Zapier</h3>
			<div class="space-y-3 text-sm text-jet/70 dark:text-ivory/70">
				<p>Connect JaNee decisions to 5,000+ apps through Zapier.</p>
				<ol class="list-inside list-decimal space-y-2 marker:text-amber marker:font-semibold">
					<li>Create a new Zap with the <strong>Webhooks by Zapier</strong> trigger (Catch Hook)</li>
					<li>Copy the generated webhook URL</li>
					<li>Set it as your JaNee app's webhook URL</li>
					<li>Make a test decision to send a sample payload</li>
					<li>Add actions — e.g., create a Google Sheet row, send an email, post to Slack</li>
				</ol>
			</div>
		</div>

		<!-- n8n -->
		<div class="rounded-xl border border-jet/5 bg-white p-6 dark:border-ivory/5 dark:bg-jet-light">
			<h3 class="mb-3 font-serif text-lg font-semibold text-jet dark:text-ivory">n8n</h3>
			<div class="space-y-3 text-sm text-jet/70 dark:text-ivory/70">
				<p>Self-hosted alternative to Zapier. Great for complex, multi-step automations.</p>
				<ol class="list-inside list-decimal space-y-2 marker:text-amber marker:font-semibold">
					<li>Add a <strong>Webhook</strong> node as the trigger in your n8n workflow</li>
					<li>Set HTTP Method to <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">POST</code> and copy the production URL</li>
					<li>Set the n8n webhook URL as your JaNee app's webhook URL</li>
					<li>The payload fields (<code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">data.decision</code>, <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">data.cardTitle</code>, etc.) are available in subsequent nodes</li>
				</ol>
			</div>
		</div>
	</div>
</section>
