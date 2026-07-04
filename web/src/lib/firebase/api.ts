import { getFirebaseAuth } from './config';

let resolvedApiBase: string | null = null;

async function discoverApiBase(): Promise<string> {
	if (resolvedApiBase) return resolvedApiBase;

	if (typeof window === 'undefined' || window.location.hostname !== 'localhost') {
		resolvedApiBase = '';
		return resolvedApiBase;
	}

	const candidates = [
		'http://localhost:6413/demo-janee/us-central1/api',
		'http://localhost:6413/webfootprint-crm/us-central1/api',
	];

	for (const base of candidates) {
		try {
			const res = await fetch(`${base}/api/health`, { signal: AbortSignal.timeout(2000) });
			if (res.ok) {
				console.log(`[api] Discovered API base: ${base}`);
				resolvedApiBase = base;
				return base;
			}
		} catch {
			continue;
		}
	}

	try {
		const hubRes = await fetch('http://localhost:6417/emulators', { signal: AbortSignal.timeout(2000) });
		if (hubRes.ok) {
			console.log('[api] Emulator hub reachable but no function URL found. Functions may still be loading.');
		}
	} catch {
		console.log('[api] Emulator hub not reachable');
	}

	resolvedApiBase = candidates[0];
	console.log(`[api] Falling back to: ${resolvedApiBase}`);
	return resolvedApiBase;
}

async function getAuthHeaders(): Promise<Record<string, string>> {
	const auth = getFirebaseAuth();
	const user = auth.currentUser;
	if (!user) throw new Error('Not authenticated');

	const token = await user.getIdToken();
	return {
		'Content-Type': 'application/json',
		'Authorization': `Bearer ${token}`,
	};
}

async function apiRequest<T>(method: string, path: string, body?: unknown): Promise<T> {
	const headers = await getAuthHeaders();
	const base = await discoverApiBase();
	const url = `${base}${path}`;

	console.log(`[api] ${method} ${url}`);

	const res = await fetch(url, {
		method,
		headers,
		body: body ? JSON.stringify(body) : undefined,
	});

	const data = await res.json();

	if (!data.success) {
		throw new Error(data.error || 'API request failed');
	}

	return data.data;
}

export const api = {
	apps: {
		list: (publicOnly = false) => apiRequest<any[]>('GET', `/api/apps${publicOnly ? '?public=true' : ''}`),
		get: (appId: string) => apiRequest<any>('GET', `/api/apps/${appId}`),
		create: (data: { name: string; description?: string; isPublic?: boolean; webhookUrl?: string; icon?: string }) =>
			apiRequest<any>('POST', '/api/apps', data),
		update: (appId: string, data: Record<string, unknown>) =>
			apiRequest<any>('PUT', `/api/apps/${appId}`, data),
		delete: (appId: string) => apiRequest<void>('DELETE', `/api/apps/${appId}`),
		subscribe: (appId: string) => apiRequest<void>('POST', `/api/apps/${appId}/subscribe`),
		unsubscribe: (appId: string) => apiRequest<void>('DELETE', `/api/apps/${appId}/subscribe`),
	},

	cards: {
		list: (appId: string) => apiRequest<any[]>('GET', `/api/apps/${appId}/cards`),
		undecided: (appId: string) => apiRequest<any[]>('GET', `/api/apps/${appId}/cards/undecided`),
		create: (appId: string, cards: Array<{ title: string; description?: string; icon?: string; imageUrl?: string; linkUrl?: string; webhookUrl?: string }>) =>
			apiRequest<any[]>('POST', `/api/apps/${appId}/cards`, cards),
		update: (appId: string, cardId: string, data: Record<string, unknown>) =>
			apiRequest<any>('PUT', `/api/apps/${appId}/cards/${cardId}`, data),
	},

	decisions: {
		create: (appId: string, cardId: string, decision: 'yes' | 'no' | 'skip') =>
			apiRequest<any>('POST', `/api/apps/${appId}/decisions`, { cardId, decision }),
		list: (appId: string, filter?: string) =>
			apiRequest<any[]>('GET', `/api/apps/${appId}/decisions${filter ? `?decision=${filter}` : ''}`),
	},

	keys: {
		list: () => apiRequest<any[]>('GET', '/api/keys'),
		create: (appId: string, label?: string) =>
			apiRequest<any>('POST', '/api/keys', { appId, label }),
		delete: (keyId: string) => apiRequest<void>('DELETE', `/api/keys/${keyId}`),
	},

	users: {
		me: () => apiRequest<any>('GET', '/api/users/me'),
		updateMe: (data: Record<string, unknown>) => apiRequest<any>('PUT', '/api/users/me', data),
		get: (userId: string) => apiRequest<any>('GET', `/api/users/${userId}`),
		addFriend: (friendId: string) => apiRequest<void>('POST', `/api/users/friends/${friendId}`),
		acceptFriend: (friendId: string) => apiRequest<void>('PUT', `/api/users/friends/${friendId}/accept`),
	},
};
