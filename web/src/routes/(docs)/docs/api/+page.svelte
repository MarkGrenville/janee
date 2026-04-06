<script lang="ts">
	type Endpoint = {
		method: 'GET' | 'POST' | 'PUT' | 'DELETE';
		path: string;
		summary: string;
		auth: string;
		body?: string;
		response?: string;
	};

	type EndpointGroup = {
		name: string;
		endpoints: Endpoint[];
	};

	let expandedId = $state<string | null>(null);

	function toggle(id: string) {
		expandedId = expandedId === id ? null : id;
	}

	const methodColors: Record<string, string> = {
		GET: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400',
		POST: 'bg-blue-500/10 text-blue-600 dark:text-blue-400',
		PUT: 'bg-yellow-500/10 text-yellow-600 dark:text-yellow-400',
		DELETE: 'bg-red-500/10 text-red-600 dark:text-red-400'
	};

	const groups: EndpointGroup[] = [
		{
			name: 'Health',
			endpoints: [
				{
					method: 'GET',
					path: '/api/health',
					summary: 'Check API health status',
					auth: 'None',
					response: `{
  "status": "ok",
  "timestamp": "2025-01-15T10:30:00.000Z"
}`
				}
			]
		},
		{
			name: 'Apps',
			endpoints: [
				{
					method: 'POST',
					path: '/api/apps',
					summary: 'Create a new app',
					auth: 'Bearer token',
					body: `{
  "name": "Movie Watchlist",
  "description": "Movies to watch this year",
  "isPublic": true,
  "webhookUrl": "https://example.com/webhook"
}`,
					response: `{
  "id": "abc123",
  "name": "Movie Watchlist",
  "description": "Movies to watch this year",
  "isPublic": true,
  "ownerId": "user_456",
  "createdAt": "2025-01-15T10:30:00.000Z"
}`
				},
				{
					method: 'GET',
					path: '/api/apps',
					summary: 'List all apps accessible to the current user',
					auth: 'Bearer token or x-api-key',
					response: `{
  "apps": [
    {
      "id": "abc123",
      "name": "Movie Watchlist",
      "isPublic": true,
      "cardCount": 24
    }
  ]
}`
				},
				{
					method: 'GET',
					path: '/api/apps/:appId',
					summary: 'Get a single app by ID',
					auth: 'Bearer token or x-api-key',
					response: `{
  "id": "abc123",
  "name": "Movie Watchlist",
  "description": "Movies to watch this year",
  "isPublic": true,
  "ownerId": "user_456",
  "cardCount": 24,
  "createdAt": "2025-01-15T10:30:00.000Z"
}`
				},
				{
					method: 'PUT',
					path: '/api/apps/:appId',
					summary: 'Update an app (owner only)',
					auth: 'Bearer token',
					body: `{
  "name": "Updated Name",
  "description": "Updated description",
  "isPublic": false
}`,
					response: `{
  "id": "abc123",
  "name": "Updated Name",
  "description": "Updated description",
  "isPublic": false
}`
				},
				{
					method: 'DELETE',
					path: '/api/apps/:appId',
					summary: 'Delete an app and all its cards (owner only)',
					auth: 'Bearer token',
					response: `{
  "message": "App deleted successfully"
}`
				}
			]
		},
		{
			name: 'Subscriptions',
			endpoints: [
				{
					method: 'POST',
					path: '/api/apps/:appId/subscribe',
					summary: 'Subscribe to a public app',
					auth: 'Bearer token',
					response: `{
  "message": "Subscribed successfully"
}`
				},
				{
					method: 'DELETE',
					path: '/api/apps/:appId/subscribe',
					summary: 'Unsubscribe from an app',
					auth: 'Bearer token',
					response: `{
  "message": "Unsubscribed successfully"
}`
				}
			]
		},
		{
			name: 'Cards',
			endpoints: [
				{
					method: 'GET',
					path: '/api/apps/:appId/cards',
					summary: 'List all cards in an app',
					auth: 'Bearer token or x-api-key',
					response: `{
  "cards": [
    {
      "id": "card_001",
      "title": "The Godfather",
      "description": "1972 crime drama",
      "imageUrl": "https://example.com/godfather.jpg",
      "linkUrl": "https://imdb.com/title/tt0068646"
    }
  ]
}`
				},
				{
					method: 'GET',
					path: '/api/apps/:appId/cards/undecided',
					summary: 'List cards the user has not yet decided on',
					auth: 'Bearer token or x-api-key',
					response: `{
  "cards": [
    {
      "id": "card_005",
      "title": "Parasite",
      "description": "2019 thriller"
    }
  ]
}`
				},
				{
					method: 'POST',
					path: '/api/apps/:appId/cards',
					summary: 'Add a new card to an app (owner only)',
					auth: 'Bearer token or x-api-key',
					body: `{
  "title": "Inception",
  "description": "Mind-bending sci-fi thriller",
  "imageUrl": "https://example.com/inception.jpg",
  "linkUrl": "https://imdb.com/title/tt1375666"
}`,
					response: `{
  "id": "card_042",
  "title": "Inception",
  "description": "Mind-bending sci-fi thriller",
  "createdAt": "2025-01-15T10:30:00.000Z"
}`
				},
				{
					method: 'PUT',
					path: '/api/apps/:appId/cards/:cardId',
					summary: 'Update an existing card (owner only)',
					auth: 'Bearer token or x-api-key',
					body: `{
  "title": "Inception (2010)",
  "description": "Updated description"
}`,
					response: `{
  "id": "card_042",
  "title": "Inception (2010)",
  "description": "Updated description"
}`
				}
			]
		},
		{
			name: 'Decisions',
			endpoints: [
				{
					method: 'POST',
					path: '/api/apps/:appId/decisions',
					summary: 'Submit a decision on a card',
					auth: 'Bearer token or x-api-key',
					body: `{
  "cardId": "card_042",
  "decision": "yes"
}`,
					response: `{
  "id": "dec_789",
  "cardId": "card_042",
  "decision": "yes",
  "createdAt": "2025-01-15T10:30:00.000Z"
}`
				},
				{
					method: 'GET',
					path: '/api/apps/:appId/decisions',
					summary: "Get current user's decisions for an app",
					auth: 'Bearer token or x-api-key',
					response: `{
  "decisions": [
    {
      "id": "dec_789",
      "cardId": "card_042",
      "decision": "yes",
      "createdAt": "2025-01-15T10:30:00.000Z"
    }
  ]
}`
				}
			]
		},
		{
			name: 'API Keys',
			endpoints: [
				{
					method: 'POST',
					path: '/api/keys',
					summary: 'Generate a new API key scoped to an app',
					auth: 'Bearer token',
					body: `{
  "appId": "abc123",
  "name": "CI Pipeline Key"
}`,
					response: `{
  "id": "key_001",
  "key": "jn_live_a1b2c3d4e5f6...",
  "name": "CI Pipeline Key",
  "appId": "abc123",
  "createdAt": "2025-01-15T10:30:00.000Z"
}`
				},
				{
					method: 'GET',
					path: '/api/keys',
					summary: "List all API keys for the current user",
					auth: 'Bearer token',
					response: `{
  "keys": [
    {
      "id": "key_001",
      "name": "CI Pipeline Key",
      "appId": "abc123",
      "lastUsed": "2025-01-15T10:30:00.000Z"
    }
  ]
}`
				},
				{
					method: 'DELETE',
					path: '/api/keys/:keyId',
					summary: 'Revoke an API key',
					auth: 'Bearer token',
					response: `{
  "message": "API key revoked"
}`
				}
			]
		},
		{
			name: 'Users',
			endpoints: [
				{
					method: 'GET',
					path: '/api/users/me',
					summary: 'Get current user profile',
					auth: 'Bearer token',
					response: `{
  "id": "user_456",
  "email": "alice@example.com",
  "displayName": "Alice",
  "photoURL": "https://example.com/avatar.jpg",
  "createdAt": "2025-01-01T00:00:00.000Z"
}`
				},
				{
					method: 'PUT',
					path: '/api/users/me',
					summary: 'Update current user profile',
					auth: 'Bearer token',
					body: `{
  "displayName": "Alice B.",
  "photoURL": "https://example.com/new-avatar.jpg"
}`,
					response: `{
  "id": "user_456",
  "displayName": "Alice B.",
  "photoURL": "https://example.com/new-avatar.jpg"
}`
				},
				{
					method: 'GET',
					path: '/api/users/:userId',
					summary: 'Get a public user profile',
					auth: 'Bearer token',
					response: `{
  "id": "user_789",
  "displayName": "Bob",
  "photoURL": "https://example.com/bob.jpg"
}`
				},
				{
					method: 'POST',
					path: '/api/users/friends/:friendId',
					summary: 'Send a friend request',
					auth: 'Bearer token',
					response: `{
  "message": "Friend request sent"
}`
				},
				{
					method: 'PUT',
					path: '/api/users/friends/:friendId/accept',
					summary: 'Accept a friend request',
					auth: 'Bearer token',
					response: `{
  "message": "Friend request accepted"
}`
				}
			]
		}
	];
</script>

<svelte:head>
	<title>API Reference — JaNee Docs</title>
</svelte:head>

<header class="mb-12">
	<h1 class="font-serif text-4xl font-bold tracking-tight text-jet sm:text-5xl dark:text-ivory">API Reference</h1>
	<p class="mt-4 max-w-2xl text-lg text-jet/60 dark:text-ivory/60">
		The JaNee REST API lets you manage apps, cards, and decisions programmatically.
	</p>
</header>

<!-- Auth info -->
<section class="mb-12 rounded-xl border border-jet/5 bg-white p-6 dark:border-ivory/5 dark:bg-jet-light">
	<h2 class="font-serif text-xl font-semibold text-jet dark:text-ivory">Authentication</h2>
	<p class="mt-2 text-sm leading-relaxed text-jet/60 dark:text-ivory/60">
		All endpoints (except <code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">/api/health</code>) require authentication via one of:
	</p>
	<div class="mt-4 space-y-3">
		<div class="rounded-lg bg-jet/[0.02] p-4 dark:bg-ivory/[0.02]">
			<p class="text-sm font-medium text-jet dark:text-ivory">Bearer Token</p>
			<pre class="mt-1 overflow-x-auto text-xs text-jet/60 dark:text-ivory/60"><code>Authorization: Bearer &lt;firebase-id-token&gt;</code></pre>
		</div>
		<div class="rounded-lg bg-jet/[0.02] p-4 dark:bg-ivory/[0.02]">
			<p class="text-sm font-medium text-jet dark:text-ivory">API Key</p>
			<pre class="mt-1 overflow-x-auto text-xs text-jet/60 dark:text-ivory/60"><code>x-api-key: jn_live_a1b2c3d4e5f6...</code></pre>
			<p class="mt-2 text-xs text-jet/40 dark:text-ivory/40">API keys are scoped to a specific app and only grant access to that app's resources.</p>
		</div>
	</div>
</section>

<!-- Base URL -->
<section class="mb-12">
	<div class="rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter">
		<p class="text-xs text-ivory/50">Base URL</p>
		<code class="text-sm text-amber">https://janee.app/api</code>
	</div>
</section>

<!-- Endpoint groups -->
{#each groups as group}
	<section class="mb-10">
		<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">{group.name}</h2>
		<div class="space-y-2">
			{#each group.endpoints as ep}
				{@const id = `${ep.method}-${ep.path}`}
				{@const isOpen = expandedId === id}
				<div class="rounded-xl border border-jet/5 bg-white transition-colors dark:border-ivory/5 dark:bg-jet-light">
					<button
						onclick={() => toggle(id)}
						class="flex w-full items-center gap-3 px-4 py-3 text-left"
					>
						<span class="inline-flex w-16 shrink-0 items-center justify-center rounded-md px-2 py-0.5 text-xs font-bold tracking-wide {methodColors[ep.method]}">
							{ep.method}
						</span>
						<code class="text-sm text-jet dark:text-ivory">{ep.path}</code>
						<span class="ml-auto hidden text-xs text-jet/40 sm:inline dark:text-ivory/40">{ep.summary}</span>
						<svg
							class="h-4 w-4 shrink-0 text-jet/30 transition-transform dark:text-ivory/30 {isOpen ? 'rotate-180' : ''}"
							fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"
						>
							<path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
						</svg>
					</button>

					{#if isOpen}
						<div class="border-t border-jet/5 px-4 py-4 dark:border-ivory/5">
							<p class="mb-3 text-sm text-jet/70 dark:text-ivory/70">{ep.summary}</p>

							<div class="mb-3 flex items-center gap-2">
								<span class="text-xs font-medium text-jet/40 dark:text-ivory/40">Auth:</span>
								<span class="rounded-full bg-jet/5 px-2 py-0.5 text-xs text-jet/60 dark:bg-ivory/5 dark:text-ivory/60">{ep.auth}</span>
							</div>

							{#if ep.body}
								<div class="mb-3">
									<p class="mb-1 text-xs font-medium text-jet/40 dark:text-ivory/40">Request Body</p>
									<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 text-xs leading-relaxed text-ivory dark:bg-jet-lighter"><code>{ep.body}</code></pre>
								</div>
							{/if}

							{#if ep.response}
								<div>
									<p class="mb-1 text-xs font-medium text-jet/40 dark:text-ivory/40">Response</p>
									<pre class="overflow-x-auto rounded-lg bg-jet px-4 py-3 text-xs leading-relaxed text-ivory dark:bg-jet-lighter"><code>{ep.response}</code></pre>
								</div>
							{/if}
						</div>
					{/if}
				</div>
			{/each}
		</div>
	</section>
{/each}
