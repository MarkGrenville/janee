<script lang="ts">
	import { onMount } from 'svelte';
	import { user } from '$lib/stores/auth';
	import { api } from '$lib/firebase/api';

	let profile = $state<any>(null);
	let loading = $state(true);
	let saving = $state(false);
	let error = $state('');
	let successMsg = $state('');

	let displayName = $state('');
	let bio = $state('');
	let isPublicProfile = $state(false);

	let stats = $state({ yes: 0, no: 0, skip: 0, total: 0 });

	onMount(async () => {
		await loadProfile();
		await loadStats();
	});

	async function loadProfile() {
		loading = true;
		try {
			profile = await api.users.me();
			displayName = profile.displayName || $user?.displayName || '';
			bio = profile.bio || '';
			isPublicProfile = profile.isPublic || false;
		} catch (e: any) {
			error = e.message;
			console.log('[profile] Error loading profile:', e.message);
		} finally {
			loading = false;
		}
	}

	async function loadStats() {
		try {
			const apps = await api.apps.list();
			let yes = 0, no = 0, skip = 0;
			for (const app of apps) {
				try {
					const decisions = await api.decisions.list(app.id);
					for (const d of decisions) {
						if (d.decision === 'yes') yes++;
						else if (d.decision === 'no') no++;
						else skip++;
					}
				} catch {
					// skip apps where listing fails
				}
			}
			stats = { yes, no, skip, total: yes + no + skip };
		} catch (e: any) {
			console.log('[profile] Error loading stats:', e.message);
		}
	}

	async function saveProfile(e: Event) {
		e.preventDefault();
		saving = true;
		error = '';
		successMsg = '';
		try {
			await api.users.updateMe({
				displayName: displayName.trim(),
				bio: bio.trim(),
				isPublic: isPublicProfile,
			});
			successMsg = 'Profile saved';
			setTimeout(() => successMsg = '', 3000);
		} catch (e: any) {
			error = e.message;
		} finally {
			saving = false;
		}
	}
</script>

<div class="px-6 py-6 md:px-8 md:py-8">
	<div class="mx-auto max-w-lg">
		<h1 class="font-serif text-2xl md:text-3xl text-jet dark:text-ivory mb-8">Profile</h1>

		{#if loading}
			<div class="flex items-center justify-center py-20">
				<div class="h-8 w-8 animate-spin rounded-full border-2 border-amber border-t-transparent"></div>
			</div>
		{:else}
			<!-- Avatar & Identity -->
			<div class="mb-8 flex items-center gap-4">
				{#if $user?.photoURL}
					<img src={$user.photoURL} alt="Avatar" class="h-20 w-20 rounded-2xl object-cover ring-2 ring-amber/20" />
				{:else}
					<div class="flex h-20 w-20 items-center justify-center rounded-2xl bg-amber/10 font-serif text-2xl font-bold text-amber">
						{displayName?.charAt(0)?.toUpperCase() || '?'}
					</div>
				{/if}
				<div>
					<h2 class="font-serif text-xl text-jet dark:text-ivory">{displayName || 'Anonymous'}</h2>
					<p class="text-sm text-jet/50 dark:text-ivory/50">{$user?.email}</p>
				</div>
			</div>

			<!-- Stats -->
			<div class="mb-8 grid grid-cols-3 gap-3">
				<div class="rounded-2xl glass dark:glass p-4 text-center">
					<p class="text-2xl font-serif font-bold text-swipe-yes">{stats.yes}</p>
					<p class="text-[10px] uppercase tracking-wider text-jet/40 dark:text-ivory/40 mt-1">Yes</p>
				</div>
				<div class="rounded-2xl glass dark:glass p-4 text-center">
					<p class="text-2xl font-serif font-bold text-swipe-no">{stats.no}</p>
					<p class="text-[10px] uppercase tracking-wider text-jet/40 dark:text-ivory/40 mt-1">No</p>
				</div>
				<div class="rounded-2xl glass dark:glass p-4 text-center">
					<p class="text-2xl font-serif font-bold text-swipe-skip">{stats.skip}</p>
					<p class="text-[10px] uppercase tracking-wider text-jet/40 dark:text-ivory/40 mt-1">Skip</p>
				</div>
			</div>

			{#if error}
				<div class="mb-6 rounded-xl bg-rose/10 border border-rose/20 px-4 py-3 text-sm text-rose">{error}</div>
			{/if}
			{#if successMsg}
				<div class="mb-6 rounded-xl bg-sage/10 border border-sage/20 px-4 py-3 text-sm text-sage">{successMsg}</div>
			{/if}

			<!-- Edit Form -->
			<form onsubmit={saveProfile} class="space-y-6">
				<div>
					<label for="displayName" class="mb-1.5 block text-sm font-medium text-jet/80 dark:text-ivory/80">Display Name</label>
					<input
						id="displayName"
						type="text"
						bind:value={displayName}
						class="w-full rounded-xl border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-4 py-3 text-sm text-jet dark:text-ivory outline-none focus:border-amber focus:ring-1 focus:ring-amber transition-colors"
					/>
				</div>

				<div>
					<label for="bio" class="mb-1.5 block text-sm font-medium text-jet/80 dark:text-ivory/80">Bio</label>
					<textarea
						id="bio"
						bind:value={bio}
						placeholder="Tell us about yourself"
						rows={3}
						class="w-full rounded-xl border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-4 py-3 text-sm text-jet dark:text-ivory placeholder:text-jet/30 dark:placeholder:text-ivory/30 outline-none focus:border-amber focus:ring-1 focus:ring-amber transition-colors resize-none"
					></textarea>
				</div>

				<!-- Public Profile Toggle -->
				<div class="flex items-center justify-between rounded-xl border border-jet/10 dark:border-ivory/10 px-4 py-3">
					<div>
						<p class="text-sm font-medium text-jet dark:text-ivory">Public Profile</p>
						<p class="text-xs text-jet/50 dark:text-ivory/50">Others can see your profile and stats</p>
					</div>
					<button
						type="button"
						onclick={() => isPublicProfile = !isPublicProfile}
						class="relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full transition-colors duration-200 {isPublicProfile ? 'bg-amber' : 'bg-jet/20 dark:bg-ivory/20'}"
						role="switch"
						aria-checked={isPublicProfile}
					>
						<span
							class="pointer-events-none inline-block h-5 w-5 translate-y-0.5 rounded-full bg-white shadow-sm transition-transform duration-200 {isPublicProfile ? 'translate-x-5.5' : 'translate-x-0.5'}"
						></span>
					</button>
				</div>

				<button
					type="submit"
					disabled={saving}
					class="w-full rounded-xl bg-amber px-6 py-3 text-sm font-medium text-jet hover:bg-amber-light disabled:opacity-50 transition-colors active:scale-[0.99]"
				>
					{saving ? 'Saving...' : 'Save Profile'}
				</button>
			</form>

			<!-- Friends (placeholder) -->
			<div class="mt-10">
				<h2 class="font-serif text-xl text-jet dark:text-ivory mb-4">Friends</h2>
				<div class="rounded-2xl glass dark:glass p-8 text-center">
					<p class="text-sm text-jet/50 dark:text-ivory/50">Friends feature coming soon.</p>
				</div>
			</div>
		{/if}
	</div>
</div>
