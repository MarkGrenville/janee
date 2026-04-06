<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { user, signOut } from '$lib/stores/auth';
	import { theme, toggleTheme } from '$lib/stores/theme';
	import { api } from '$lib/firebase/api';

	let apps = $state<any[]>([]);
	let apiKeys = $state<any[]>([]);
	let loading = $state(true);

	let newKeyAppId = $state('');
	let newKeyLabel = $state('');
	let creatingKey = $state(false);
	let newlyCreatedKey = $state('');

	let displayName = $state('');
	let savingName = $state(false);
	let nameSuccess = $state('');

	onMount(async () => {
		try {
			const [appsData, keysData, profile] = await Promise.all([
				api.apps.list(),
				api.keys.list(),
				api.users.me(),
			]);
			apps = appsData;
			apiKeys = keysData;
			displayName = profile.displayName || $user?.displayName || '';
		} catch (e: any) {
			console.log('[settings] Error loading data:', e.message);
		} finally {
			loading = false;
		}
	});

	async function saveName(e: Event) {
		e.preventDefault();
		savingName = true;
		nameSuccess = '';
		try {
			await api.users.updateMe({ displayName: displayName.trim() });
			nameSuccess = 'Saved';
			setTimeout(() => nameSuccess = '', 3000);
		} catch (e: any) {
			console.log('[settings] Error saving name:', e.message);
		} finally {
			savingName = false;
		}
	}

	async function createKey() {
		if (!newKeyAppId) return;
		creatingKey = true;
		newlyCreatedKey = '';
		try {
			const result = await api.keys.create(newKeyAppId, newKeyLabel.trim() || undefined);
			newlyCreatedKey = result.key || result.apiKey || '';
			newKeyLabel = '';
			apiKeys = await api.keys.list();
		} catch (e: any) {
			console.log('[settings] Error creating key:', e.message);
		} finally {
			creatingKey = false;
		}
	}

	async function deleteKey(keyId: string) {
		try {
			await api.keys.delete(keyId);
			apiKeys = apiKeys.filter((k: any) => k.id !== keyId);
		} catch (e: any) {
			console.log('[settings] Error deleting key:', e.message);
		}
	}

	async function handleSignOut() {
		await signOut();
		goto('/login');
	}

	function copyToClipboard(text: string) {
		navigator.clipboard.writeText(text);
	}
</script>

<div class="px-6 py-6 md:px-8 md:py-8">
	<div class="mx-auto max-w-lg">
		<h1 class="font-serif text-2xl md:text-3xl text-jet dark:text-ivory mb-8">Settings</h1>

		{#if loading}
			<div class="flex items-center justify-center py-20">
				<div class="h-8 w-8 animate-spin rounded-full border-2 border-amber border-t-transparent"></div>
			</div>
		{:else}
			<div class="space-y-10">
				<!-- Account -->
				<section>
					<h2 class="font-serif text-lg text-jet dark:text-ivory mb-4">Account</h2>
					<div class="space-y-4">
						<div class="rounded-xl border border-jet/10 dark:border-ivory/10 px-4 py-3">
							<p class="text-xs text-jet/50 dark:text-ivory/50 mb-1">Email</p>
							<p class="text-sm text-jet dark:text-ivory">{$user?.email}</p>
						</div>

						<form onsubmit={saveName} class="rounded-xl border border-jet/10 dark:border-ivory/10 p-4">
							<label for="settingsName" class="mb-1.5 block text-xs text-jet/50 dark:text-ivory/50">Display Name</label>
							<div class="flex gap-2">
								<input
									id="settingsName"
									type="text"
									bind:value={displayName}
									class="flex-1 rounded-lg border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-3 py-2 text-sm text-jet dark:text-ivory outline-none focus:border-amber transition-colors"
								/>
								<button
									type="submit"
									disabled={savingName}
									class="rounded-lg bg-amber px-4 py-2 text-xs font-medium text-jet hover:bg-amber-light disabled:opacity-50 transition-colors"
								>
									{#if nameSuccess}
										{nameSuccess}
									{:else}
										{savingName ? 'Saving...' : 'Save'}
									{/if}
								</button>
							</div>
						</form>
					</div>
				</section>

				<!-- API Keys -->
				<section>
					<h2 class="font-serif text-lg text-jet dark:text-ivory mb-4">API Keys</h2>

					{#if apiKeys.length > 0}
						<div class="space-y-2 mb-4">
							{#each apiKeys as key}
								<div class="flex items-center justify-between rounded-xl border border-jet/10 dark:border-ivory/10 px-4 py-3">
									<div class="min-w-0 flex-1">
										<p class="text-sm font-medium text-jet dark:text-ivory truncate">{key.label || 'Unnamed key'}</p>
										<div class="flex items-center gap-2 mt-0.5">
											<p class="text-xs text-jet/40 dark:text-ivory/40 font-mono">{key.prefix}•••</p>
											{#if key.appName}
												<span class="text-xs text-jet/30 dark:text-ivory/30">· {key.appName}</span>
											{/if}
										</div>
									</div>
									<button
										onclick={() => deleteKey(key.id)}
										class="text-xs text-rose hover:text-rose-light transition-colors shrink-0 ml-3"
									>
										Revoke
									</button>
								</div>
							{/each}
						</div>
					{:else}
						<p class="text-sm text-jet/40 dark:text-ivory/40 mb-4">No API keys created yet.</p>
					{/if}

					{#if newlyCreatedKey}
						<div class="mb-4 rounded-xl bg-sage/10 border border-sage/20 p-4">
							<p class="text-xs text-sage mb-2">Copy your API key now — it won't be shown again.</p>
							<div class="flex items-center gap-2">
								<code class="flex-1 rounded-lg bg-white/50 dark:bg-jet-light px-3 py-2 text-xs font-mono text-jet dark:text-ivory break-all">{newlyCreatedKey}</code>
								<button
									onclick={() => copyToClipboard(newlyCreatedKey)}
									class="rounded-lg bg-sage/20 px-3 py-2 text-xs text-sage hover:bg-sage/30 transition-colors shrink-0"
								>
									Copy
								</button>
							</div>
						</div>
					{/if}

					<div class="rounded-xl border border-jet/10 dark:border-ivory/10 p-4 space-y-3">
						<p class="text-xs text-jet/50 dark:text-ivory/50">Create new API key</p>
						<select
							bind:value={newKeyAppId}
							class="w-full rounded-lg border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-3 py-2 text-sm text-jet dark:text-ivory outline-none focus:border-amber transition-colors"
						>
							<option value="">Select an app</option>
							{#each apps as app}
								<option value={app.id}>{app.icon || ''} {app.name}</option>
							{/each}
						</select>
						<input
							type="text"
							bind:value={newKeyLabel}
							placeholder="Key label (optional)"
							class="w-full rounded-lg border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-3 py-2 text-sm text-jet dark:text-ivory outline-none focus:border-amber transition-colors"
						/>
						<button
							onclick={createKey}
							disabled={creatingKey || !newKeyAppId}
							class="w-full rounded-lg bg-amber px-4 py-2.5 text-sm font-medium text-jet hover:bg-amber-light disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
						>
							{creatingKey ? 'Creating...' : 'Create API Key'}
						</button>
					</div>
				</section>

				<!-- Appearance -->
				<section>
					<h2 class="font-serif text-lg text-jet dark:text-ivory mb-4">Appearance</h2>
					<div class="flex items-center justify-between rounded-xl border border-jet/10 dark:border-ivory/10 px-4 py-3">
						<div>
							<p class="text-sm font-medium text-jet dark:text-ivory">Theme</p>
							<p class="text-xs text-jet/50 dark:text-ivory/50">{$theme === 'dark' ? 'Dark mode' : 'Light mode'}</p>
						</div>
						<button
							onclick={toggleTheme}
							class="relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full transition-colors duration-200 {$theme === 'dark' ? 'bg-amber' : 'bg-jet/20'}"
							role="switch"
							aria-checked={$theme === 'dark'}
							aria-label="Toggle dark mode"
						>
							<span
								class="pointer-events-none inline-block h-5 w-5 translate-y-0.5 rounded-full bg-white shadow-sm transition-transform duration-200 {$theme === 'dark' ? 'translate-x-5.5' : 'translate-x-0.5'}"
							></span>
						</button>
					</div>
				</section>

				<!-- Sign Out -->
				<section>
					<button
						onclick={handleSignOut}
						class="w-full rounded-xl border border-rose/20 px-6 py-3 text-sm font-medium text-rose hover:bg-rose/5 transition-colors"
					>
						Sign Out
					</button>
				</section>
			</div>
		{/if}
	</div>
</div>
