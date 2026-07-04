<script lang="ts">
	type Lang = 'curl' | 'javascript' | 'python' | 'cli';
	type Method = 'GET' | 'POST' | 'PUT' | 'DELETE';
	type AuthType = 'bearer' | 'apikey' | 'both' | 'none';

	type EndpointDef = {
		method: Method;
		path: string;
		summary: string;
		auth: AuthType;
		queryNote?: string;
		bodyJson?: string;
		response?: string;
		cliExample?: string;
	};

	type EndpointGroup = {
		name: string;
		id: string;
		description: string;
		endpoints: EndpointDef[];
	};

	let selectedLang: Lang = $state('curl');
	let copiedId: string | null = $state(null);

	const languages: { id: Lang; label: string }[] = [
		{ id: 'curl', label: 'cURL' },
		{ id: 'javascript', label: 'JavaScript' },
		{ id: 'python', label: 'Python' },
		{ id: 'cli', label: 'CLI' }
	];

	const methodColors: Record<Method, string> = {
		GET: 'bg-emerald-500/20 text-emerald-400',
		POST: 'bg-blue-500/20 text-blue-400',
		PUT: 'bg-amber/20 text-amber',
		DELETE: 'bg-red-500/20 text-red-400'
	};

	const authLabels: Record<AuthType, string> = {
		bearer: 'Bearer token',
		apikey: 'API key',
		both: 'Bearer token or API key',
		none: 'None'
	};

	async function copyToClipboard(text: string, id: string) {
		try {
			await navigator.clipboard.writeText(text);
			copiedId = id;
			setTimeout(() => {
				if (copiedId === id) copiedId = null;
			}, 2000);
		} catch {
			/* clipboard unavailable */
		}
	}

	function fmtPath(path: string): string {
		return path
			.replace(':appId', 'APP_ID')
			.replace(':cardId', 'CARD_ID')
			.replace(':keyId', 'KEY_ID')
			.replace(':userId', 'USER_ID')
			.replace(':friendId', 'FRIEND_ID');
	}

	function indentAfterFirst(str: string, prefix: string): string {
		return str
			.split('\n')
			.map((l, i) => (i === 0 ? l : prefix + l))
			.join('\n');
	}

	function genCurl(ep: EndpointDef): string {
		const url = `https://janee.app${fmtPath(ep.path)}`;
		const parts = [`curl -X ${ep.method} "${url}"`];
		if (ep.auth === 'bearer' || ep.auth === 'both')
			parts.push('  -H "Authorization: Bearer YOUR_TOKEN"');
		else if (ep.auth === 'apikey') parts.push('  -H "x-api-key: YOUR_API_KEY"');
		if (ep.bodyJson) {
			parts.push('  -H "Content-Type: application/json"');
			parts.push(`  -d '${indentAfterFirst(ep.bodyJson, '  ')}'`);
		}
		return parts.join(' \\\n');
	}

	function genJs(ep: EndpointDef): string {
		const url = `https://janee.app${fmtPath(ep.path)}`;
		const hdrs: string[] = [];
		if (ep.auth === 'bearer' || ep.auth === 'both')
			hdrs.push('    "Authorization": "Bearer YOUR_TOKEN"');
		else if (ep.auth === 'apikey') hdrs.push('    "x-api-key": "YOUR_API_KEY"');
		if (ep.bodyJson) hdrs.push('    "Content-Type": "application/json"');

		if (!hdrs.length && !ep.bodyJson && ep.method === 'GET') {
			return `const response = await fetch("${url}");\n\nconst data = await response.json();`;
		}

		let c = `const response = await fetch("${url}", {\n  method: "${ep.method}"`;
		if (hdrs.length) c += `,\n  headers: {\n${hdrs.join(',\n')}\n  }`;
		if (ep.bodyJson) c += `,\n  body: JSON.stringify(${indentAfterFirst(ep.bodyJson, '  ')})`;
		c += '\n});\n\nconst data = await response.json();';
		return c;
	}

	function genPython(ep: EndpointDef): string {
		const url = `https://janee.app${fmtPath(ep.path)}`;
		const m = ep.method.toLowerCase();
		let c = 'import requests\n\n';

		const hdrs: string[] = [];
		if (ep.auth === 'bearer' || ep.auth === 'both')
			hdrs.push('    "Authorization": "Bearer YOUR_TOKEN"');
		else if (ep.auth === 'apikey') hdrs.push('    "x-api-key": "YOUR_API_KEY"');

		if (hdrs.length) c += `headers = {\n${hdrs.join(',\n')}\n}\n\n`;

		if (ep.bodyJson) {
			const py = ep.bodyJson
				.replace(/: true/g, ': True')
				.replace(/: false/g, ': False')
				.replace(/: null/g, ': None')
				.replace(/^ {2}/gm, '    ');
			c += `payload = ${py}\n\n`;
		}

		if (!hdrs.length && !ep.bodyJson) {
			c += `response = requests.${m}("${url}")\n\ndata = response.json()`;
		} else {
			c += `response = requests.${m}(\n    "${url}"`;
			if (hdrs.length) c += ',\n    headers=headers';
			if (ep.bodyJson) c += ',\n    json=payload';
			c += '\n)\n\ndata = response.json()';
		}
		return c;
	}

	function getExample(ep: EndpointDef): string {
		switch (selectedLang) {
			case 'curl':
				return genCurl(ep);
			case 'javascript':
				return genJs(ep);
			case 'python':
				return genPython(ep);
			case 'cli':
				return ep.cliExample || '# No CLI equivalent available\n# Use cURL, JavaScript, or Python instead';
		}
	}

	const quickStart: Record<Lang, string> = {
		curl: `# Step 1: Create an app
curl -X POST "https://janee.app/api/apps" \\
  -H "Authorization: Bearer YOUR_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{"name": "Movie Watchlist", "isPublic": true}'

# Response: {"id": "abc123", "name": "Movie Watchlist", ...}

# Step 2: Add a card
curl -X POST "https://janee.app/api/apps/abc123/cards" \\
  -H "Authorization: Bearer YOUR_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{"title": "Inception", "description": "Mind-bending sci-fi thriller"}'

# Response: {"id": "card_042", "title": "Inception", ...}

# Step 3: Make a decision
curl -X POST "https://janee.app/api/apps/abc123/decisions" \\
  -H "Authorization: Bearer YOUR_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{"cardId": "card_042", "decision": "yes"}'`,
		javascript: `// Step 1: Create an app
const app = await fetch("https://janee.app/api/apps", {
  method: "POST",
  headers: {
    "Authorization": "Bearer YOUR_TOKEN",
    "Content-Type": "application/json"
  },
  body: JSON.stringify({ name: "Movie Watchlist", isPublic: true })
}).then(r => r.json());

// Step 2: Add a card
const card = await fetch(
  "https://janee.app/api/apps/" + app.id + "/cards",
  {
    method: "POST",
    headers: {
      "Authorization": "Bearer YOUR_TOKEN",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      title: "Inception",
      description: "Mind-bending sci-fi thriller"
    })
  }
).then(r => r.json());

// Step 3: Make a decision
const decision = await fetch(
  "https://janee.app/api/apps/" + app.id + "/decisions",
  {
    method: "POST",
    headers: {
      "Authorization": "Bearer YOUR_TOKEN",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ cardId: card.id, decision: "yes" })
  }
).then(r => r.json());`,
		python: `import requests

headers = {
    "Authorization": "Bearer YOUR_TOKEN",
    "Content-Type": "application/json"
}

# Step 1: Create an app
app = requests.post(
    "https://janee.app/api/apps",
    headers=headers,
    json={"name": "Movie Watchlist", "isPublic": True}
).json()

# Step 2: Add a card
card = requests.post(
    f"https://janee.app/api/apps/{app['id']}/cards",
    headers=headers,
    json={"title": "Inception", "description": "Mind-bending sci-fi thriller"}
).json()

# Step 3: Make a decision
decision = requests.post(
    f"https://janee.app/api/apps/{app['id']}/decisions",
    headers=headers,
    json={"cardId": card["id"], "decision": "yes"}
).json()`,
		cli: `# Step 1: Create an app
janee-cli create-app YOUR_API_KEY "Movie Watchlist" --public

# Output: App created — ID: abc123

# Step 2: Add a card
janee-cli add-card YOUR_API_KEY abc123 "Inception" \\
  --description "Mind-bending sci-fi thriller"

# Output: Card added — ID: card_042

# Step 3: Make a decision
janee-cli decide YOUR_API_KEY abc123 card_042 yes

# Output: Decision recorded: yes`
	};

	const authBearer: Record<Lang, string> = {
		curl: `curl -X GET "https://janee.app/api/apps" \\
  -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN"`,
		javascript: `const response = await fetch("https://janee.app/api/apps", {
  headers: {
    "Authorization": "Bearer YOUR_FIREBASE_ID_TOKEN"
  }
});`,
		python: `import requests

response = requests.get(
    "https://janee.app/api/apps",
    headers={"Authorization": "Bearer YOUR_FIREBASE_ID_TOKEN"}
)`,
		cli: `# The CLI uses API keys, not Bearer tokens.
# Generate an API key first via the web app or API.`
	};

	const authApiKey: Record<Lang, string> = {
		curl: `curl -X GET "https://janee.app/api/apps" \\
  -H "x-api-key: jn_live_a1b2c3d4e5f6..."`,
		javascript: `const response = await fetch("https://janee.app/api/apps", {
  headers: {
    "x-api-key": "jn_live_a1b2c3d4e5f6..."
  }
});`,
		python: `import requests

response = requests.get(
    "https://janee.app/api/apps",
    headers={"x-api-key": "jn_live_a1b2c3d4e5f6..."}
)`,
		cli: `# Set as environment variable
export JANEE_API_KEY="jn_live_a1b2c3d4e5f6..."
janee-cli list-apps

# Or pass directly
janee-cli list-apps jn_live_a1b2c3d4e5f6...`
	};

	const groups: EndpointGroup[] = [
		{
			name: 'Health',
			id: 'health',
			description: 'Service health check.',
			endpoints: [
				{
					method: 'GET',
					path: '/api/health',
					summary: 'Check API health status. No authentication required.',
					auth: 'none',
					cliExample: 'janee-cli health',
					response: `{
  "status": "ok",
  "timestamp": "2025-01-15T10:30:00.000Z"
}`
				}
			]
		},
		{
			name: 'Apps',
			id: 'apps',
			description: 'Create and manage decision apps.',
			endpoints: [
				{
					method: 'GET',
					path: '/api/apps',
					summary: 'List all apps accessible to the current user.',
					auth: 'both',
					queryNote: '?public=true — filter public apps only',
					cliExample: 'janee-cli list-apps YOUR_API_KEY',
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
					method: 'POST',
					path: '/api/apps',
					summary: 'Create a new app.',
					auth: 'bearer',
					bodyJson: `{
  "name": "Movie Watchlist",
  "description": "Movies to watch this year",
  "isPublic": true,
  "webhookUrl": "https://example.com/webhook"
}`,
					cliExample: `janee-cli create-app YOUR_API_KEY "Movie Watchlist" \\
  --public --description "Movies to watch this year"`,
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
					path: '/api/apps/:appId',
					summary: 'Get a single app by ID.',
					auth: 'both',
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
					summary: 'Update an app (owner only).',
					auth: 'bearer',
					bodyJson: `{
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
					summary: 'Delete an app and all its cards (owner only).',
					auth: 'bearer',
					response: `{
  "message": "App deleted successfully"
}`
				},
				{
					method: 'POST',
					path: '/api/apps/:appId/subscribe',
					summary: 'Subscribe to a public app.',
					auth: 'bearer',
					response: `{
  "message": "Subscribed successfully"
}`
				},
				{
					method: 'DELETE',
					path: '/api/apps/:appId/subscribe',
					summary: 'Unsubscribe from an app.',
					auth: 'bearer',
					response: `{
  "message": "Unsubscribed successfully"
}`
				}
			]
		},
		{
			name: 'Cards',
			id: 'cards',
			description: 'Add and manage cards within an app.',
			endpoints: [
				{
					method: 'GET',
					path: '/api/apps/:appId/cards',
					summary: 'List all cards in an app.',
					auth: 'both',
					queryNote: '?status=active — filter by card status',
					cliExample: 'janee-cli list-cards YOUR_API_KEY APP_ID',
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
					summary: 'List cards the current user has not yet decided on.',
					auth: 'both',
					cliExample: 'janee-cli list-cards YOUR_API_KEY APP_ID --undecided',
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
					summary:
						'Add one or more cards to an app (owner only). Send a single object or an array.',
					auth: 'both',
					bodyJson: `{
  "title": "Inception",
  "description": "Mind-bending sci-fi thriller",
  "imageUrl": "https://example.com/inception.jpg",
  "linkUrl": "https://imdb.com/title/tt1375666"
}`,
					cliExample: `janee-cli add-card YOUR_API_KEY APP_ID "Inception" \\
  --description "Mind-bending sci-fi thriller" \\
  --image "https://example.com/inception.jpg"`,
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
					summary: 'Update an existing card (owner only).',
					auth: 'both',
					bodyJson: `{
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
			id: 'decisions',
			description: 'Submit and retrieve card decisions.',
			endpoints: [
				{
					method: 'POST',
					path: '/api/apps/:appId/decisions',
					summary: 'Submit a decision on a card.',
					auth: 'both',
					bodyJson: `{
  "cardId": "card_042",
  "decision": "yes"
}`,
					cliExample: 'janee-cli decide YOUR_API_KEY APP_ID card_042 yes',
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
					summary: "Get current user's decisions for an app.",
					auth: 'both',
					queryNote: '?decision=yes&limit=50 — filter and limit results',
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
			id: 'keys',
			description: 'Manage API keys for programmatic access.',
			endpoints: [
				{
					method: 'POST',
					path: '/api/keys',
					summary: 'Generate a new API key scoped to an app.',
					auth: 'bearer',
					bodyJson: `{
  "appId": "abc123",
  "label": "CI Pipeline Key"
}`,
					cliExample: 'janee-cli create-key YOUR_BEARER_TOKEN abc123 "CI Pipeline Key"',
					response: `{
  "id": "key_001",
  "key": "jn_live_a1b2c3d4e5f6...",
  "label": "CI Pipeline Key",
  "appId": "abc123",
  "createdAt": "2025-01-15T10:30:00.000Z"
}`
				},
				{
					method: 'GET',
					path: '/api/keys',
					summary: 'List all API keys for the current user.',
					auth: 'bearer',
					response: `{
  "keys": [
    {
      "id": "key_001",
      "label": "CI Pipeline Key",
      "appId": "abc123",
      "lastUsed": "2025-01-15T10:30:00.000Z"
    }
  ]
}`
				},
				{
					method: 'DELETE',
					path: '/api/keys/:keyId',
					summary: 'Revoke an API key.',
					auth: 'bearer',
					response: `{
  "message": "API key revoked"
}`
				}
			]
		},
		{
			name: 'Users',
			id: 'users',
			description: 'User profiles and friend connections.',
			endpoints: [
				{
					method: 'GET',
					path: '/api/users/me',
					summary: 'Get current user profile.',
					auth: 'bearer',
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
					summary: 'Update current user profile.',
					auth: 'bearer',
					bodyJson: `{
  "displayName": "Alice B.",
  "bio": "Swiping through life",
  "photoURL": "https://example.com/new-avatar.jpg",
  "publicProfile": true
}`,
					response: `{
  "id": "user_456",
  "displayName": "Alice B.",
  "bio": "Swiping through life",
  "photoURL": "https://example.com/new-avatar.jpg",
  "publicProfile": true
}`
				},
				{
					method: 'GET',
					path: '/api/users/:userId',
					summary: 'Get a public user profile.',
					auth: 'bearer',
					response: `{
  "id": "user_789",
  "displayName": "Bob",
  "photoURL": "https://example.com/bob.jpg"
}`
				},
				{
					method: 'POST',
					path: '/api/users/friends/:friendId',
					summary: 'Send a friend request.',
					auth: 'bearer',
					response: `{
  "message": "Friend request sent"
}`
				},
				{
					method: 'PUT',
					path: '/api/users/friends/:friendId/accept',
					summary: 'Accept a friend request.',
					auth: 'bearer',
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
	<meta name="description" content="Complete API reference for the JaNee REST API." />
</svelte:head>

{#snippet codeBlock(code: string, id: string)}
	<div class="group relative">
		<button
			onclick={() => copyToClipboard(code, id)}
			class="absolute top-2 right-2 z-10 rounded-md px-2 py-1 text-xs transition-all hover:bg-ivory/20 hover:text-ivory {copiedId ===
			id
				? 'bg-emerald-500/20 text-emerald-400 opacity-100'
				: 'bg-ivory/10 text-ivory/50 opacity-0 group-hover:opacity-100'}"
		>
			{copiedId === id ? '✓ Copied' : 'Copy'}
		</button>
		<pre
			class="overflow-x-auto rounded-lg bg-jet px-4 py-3 text-[13px] leading-relaxed text-ivory/90 dark:bg-jet-lighter"
		><code>{code}</code></pre>
	</div>
{/snippet}

<header class="mb-12">
	<h1 class="font-serif text-4xl font-bold tracking-tight text-jet sm:text-5xl dark:text-ivory">
		API Reference
	</h1>
	<p class="mt-4 max-w-2xl text-lg leading-relaxed text-jet/60 dark:text-ivory/60">
		The JaNee REST API lets you manage apps, cards, and decisions programmatically.
		Build integrations, automate workflows, or power AI-driven decision flows.
	</p>
</header>

<!-- Sticky language selector -->
<div
	class="sticky top-0 z-20 -mx-6 mb-12 border-b border-jet/5 bg-ivory/95 px-6 py-3 backdrop-blur-md sm:-mx-8 sm:px-8 lg:-mx-12 lg:px-12 dark:border-ivory/5 dark:bg-jet/95"
>
	<div class="flex gap-1">
		{#each languages as lang}
			<button
				onclick={() => (selectedLang = lang.id)}
				class="rounded-lg px-3.5 py-1.5 text-sm font-medium transition-colors {selectedLang ===
				lang.id
					? 'bg-amber/15 text-amber'
					: 'text-jet/50 hover:bg-jet/5 hover:text-jet dark:text-ivory/50 dark:hover:bg-ivory/5 dark:hover:text-ivory'}"
			>
				{lang.label}
			</button>
		{/each}
	</div>
</div>

<!-- Quick Start -->
<section id="quick-start" class="mb-16">
	<h2 class="mb-2 font-serif text-2xl font-semibold text-jet dark:text-ivory">Quick Start</h2>
	<p class="mb-6 max-w-2xl text-sm leading-relaxed text-jet/60 dark:text-ivory/60">
		Create an app, add a card, and make your first decision — three API calls to get started.
		Replace placeholder values with your own credentials.
	</p>
	{@render codeBlock(quickStart[selectedLang], 'quick-start')}
</section>

<!-- Authentication -->
<section id="authentication" class="mb-16">
	<h2 class="mb-2 font-serif text-2xl font-semibold text-jet dark:text-ivory">Authentication</h2>
	<p class="mb-6 text-sm leading-relaxed text-jet/60 dark:text-ivory/60">
		All endpoints except
		<code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">/api/health</code>
		require authentication via one of two methods:
	</p>

	<div class="mb-8 rounded-xl border border-jet/5 bg-white p-5 dark:border-ivory/5 dark:bg-jet-light">
		<div class="mb-1 flex items-center gap-2">
			<span class="inline-block h-2 w-2 rounded-full bg-emerald-400"></span>
			<h3 class="text-sm font-semibold text-jet dark:text-ivory">Bearer Token</h3>
		</div>
		<p class="mb-4 text-sm text-jet/60 dark:text-ivory/60">
			Pass a Firebase ID token in the Authorization header. Use for user-scoped operations
			from your web or mobile app.
		</p>
		{@render codeBlock(authBearer[selectedLang], 'auth-bearer')}
	</div>

	<div class="rounded-xl border border-jet/5 bg-white p-5 dark:border-ivory/5 dark:bg-jet-light">
		<div class="mb-1 flex items-center gap-2">
			<span class="inline-block h-2 w-2 rounded-full bg-amber"></span>
			<h3 class="text-sm font-semibold text-jet dark:text-ivory">API Key</h3>
		</div>
		<p class="mb-4 text-sm text-jet/60 dark:text-ivory/60">
			Pass an API key via the
			<code class="rounded bg-jet/5 px-1.5 py-0.5 text-xs dark:bg-ivory/5">x-api-key</code>
			header. Keys are scoped to a single app and only grant access to that app's resources.
		</p>
		{@render codeBlock(authApiKey[selectedLang], 'auth-apikey')}
	</div>
</section>

<!-- Base URL -->
<section id="base-url" class="mb-16">
	<h2 class="mb-4 font-serif text-2xl font-semibold text-jet dark:text-ivory">Base URL</h2>
	<div class="space-y-3">
		<div class="rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter">
			<p class="mb-1 text-xs font-medium text-ivory/40">Production</p>
			<code class="text-sm text-amber">https://janee.app</code>
		</div>
		<div class="rounded-lg bg-jet px-4 py-3 dark:bg-jet-lighter">
			<p class="mb-1 text-xs font-medium text-ivory/40">Local emulator</p>
			<code class="text-sm text-ivory/70">http://localhost:6413/janee-app/us-central1</code>
		</div>
	</div>
</section>

<!-- Endpoint groups -->
{#each groups as group}
	<section id={group.id} class="mb-16">
		<div class="mb-6">
			<h2 class="font-serif text-2xl font-semibold text-jet dark:text-ivory">{group.name}</h2>
			<p class="mt-1 text-sm text-jet/60 dark:text-ivory/60">{group.description}</p>
		</div>

		<div class="space-y-6">
			{#each group.endpoints as ep, i}
				<div
					class="rounded-xl border border-jet/5 bg-white p-5 dark:border-ivory/5 dark:bg-jet-light"
				>
					<!-- Method + Path -->
					<div class="flex items-start gap-3">
						<span
							class="mt-0.5 inline-flex w-[4.5rem] shrink-0 items-center justify-center rounded-md px-2 py-1 text-xs font-bold tracking-wide {methodColors[ep.method]}"
						>
							{ep.method}
						</span>
						<code class="text-sm font-medium text-jet dark:text-ivory">{ep.path}</code>
					</div>

					<!-- Summary -->
					<p class="mt-3 text-sm leading-relaxed text-jet/60 dark:text-ivory/60">
						{ep.summary}
					</p>

					<!-- Auth + Query params -->
					<div class="mt-3 flex flex-wrap items-center gap-2">
						<span
							class="inline-flex items-center gap-1.5 rounded-full bg-jet/5 px-2.5 py-0.5 text-xs dark:bg-ivory/5"
						>
							<svg
								class="h-3 w-3 text-jet/40 dark:text-ivory/40"
								fill="none"
								viewBox="0 0 24 24"
								stroke="currentColor"
								stroke-width="2"
							>
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
								/>
							</svg>
							<span class="text-jet/60 dark:text-ivory/60">{authLabels[ep.auth]}</span>
						</span>
						{#if ep.queryNote}
							<span class="rounded-full bg-amber/10 px-2.5 py-0.5 text-xs text-amber">
								{ep.queryNote}
							</span>
						{/if}
					</div>

					<!-- Code example -->
					<div class="mt-4">
						<p
							class="mb-2 text-[11px] font-semibold tracking-widest text-jet/30 uppercase dark:text-ivory/30"
						>
							Request
						</p>
						{@render codeBlock(getExample(ep), group.id + '-' + i)}
					</div>

					<!-- Response -->
					{#if ep.response}
						<div class="mt-4">
							<p
								class="mb-2 text-[11px] font-semibold tracking-widest text-jet/30 uppercase dark:text-ivory/30"
							>
								Response
							</p>
							{@render codeBlock(ep.response, group.id + '-' + i + '-res')}
						</div>
					{/if}
				</div>
			{/each}
		</div>
	</section>
{/each}

<!-- Footer note -->
<section class="mb-8 rounded-xl border border-jet/5 bg-white p-6 dark:border-ivory/5 dark:bg-jet-light">
	<h3 class="mb-2 font-serif text-lg font-semibold text-jet dark:text-ivory">Need help?</h3>
	<p class="text-sm leading-relaxed text-jet/60 dark:text-ivory/60">
		Check the <a href="/docs/cli" class="text-amber hover:underline">CLI Guide</a> for command-line usage,
		or browse the <a href="/docs/guides" class="text-amber hover:underline">Guides</a> for step-by-step
		tutorials on common workflows.
	</p>
</section>
