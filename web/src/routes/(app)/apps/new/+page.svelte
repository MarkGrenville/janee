<script lang="ts">
	import { goto } from '$app/navigation';
	import { api } from '$lib/firebase/api';

	let name = $state('');
	let description = $state('');
	let icon = $state('');
	let isPublic = $state(false);
	let webhookUrl = $state('');
	let submitting = $state(false);
	let error = $state('');

	async function handleSubmit(e: Event) {
		e.preventDefault();
		if (!name.trim()) return;

		submitting = true;
		error = '';

		try {
			const app = await api.apps.create({
				name: name.trim(),
				description: description.trim() || undefined,
				icon: icon.trim() || undefined,
				isPublic,
				webhookUrl: webhookUrl.trim() || undefined,
			});
			goto(`/apps/${app.id}`);
		} catch (e: any) {
			error = e.message;
			console.log('[apps/new] Error creating app:', e.message);
		} finally {
			submitting = false;
		}
	}
</script>

<div class="px-6 py-6 md:px-8 md:py-8">
	<div class="mx-auto max-w-lg">
		<!-- Header -->
		<div class="mb-8">
			<button
				onclick={() => goto('/apps')}
				class="mb-4 inline-flex items-center gap-1.5 text-sm text-jet/60 dark:text-ivory/60 hover:text-amber transition-colors"
			>
				<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
					<path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
				</svg>
				Back to Apps
			</button>
			<h1 class="font-serif text-2xl md:text-3xl text-jet dark:text-ivory">Create App</h1>
		</div>

		{#if error}
			<div class="mb-6 rounded-xl bg-rose/10 border border-rose/20 px-4 py-3 text-sm text-rose">
				{error}
			</div>
		{/if}

		<form onsubmit={handleSubmit} class="space-y-6">
			<!-- Icon -->
			<div>
				<label for="icon" class="mb-1.5 block text-sm font-medium text-jet/80 dark:text-ivory/80">Icon</label>
				<input
					id="icon"
					type="text"
					bind:value={icon}
					placeholder="Paste an emoji, e.g. 🎬"
					class="w-full rounded-xl border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-4 py-3 text-2xl text-jet dark:text-ivory placeholder:text-jet/30 dark:placeholder:text-ivory/30 focus:border-amber focus:ring-1 focus:ring-amber outline-none transition-colors"
				/>
			</div>

			<!-- Name -->
			<div>
				<label for="name" class="mb-1.5 block text-sm font-medium text-jet/80 dark:text-ivory/80">
					Name <span class="text-rose">*</span>
				</label>
				<input
					id="name"
					type="text"
					bind:value={name}
					placeholder="e.g. Movie Wishlist"
					required
					class="w-full rounded-xl border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-4 py-3 text-sm text-jet dark:text-ivory placeholder:text-jet/30 dark:placeholder:text-ivory/30 focus:border-amber focus:ring-1 focus:ring-amber outline-none transition-colors"
				/>
			</div>

			<!-- Description -->
			<div>
				<label for="description" class="mb-1.5 block text-sm font-medium text-jet/80 dark:text-ivory/80">Description</label>
				<textarea
					id="description"
					bind:value={description}
					placeholder="What decisions will this app help with?"
					rows={3}
					class="w-full rounded-xl border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-4 py-3 text-sm text-jet dark:text-ivory placeholder:text-jet/30 dark:placeholder:text-ivory/30 focus:border-amber focus:ring-1 focus:ring-amber outline-none transition-colors resize-none"
				></textarea>
			</div>

			<!-- Public Toggle -->
			<div class="flex items-center justify-between rounded-xl border border-jet/10 dark:border-ivory/10 px-4 py-3">
				<div>
					<p class="text-sm font-medium text-jet dark:text-ivory">Public App</p>
					<p class="text-xs text-jet/50 dark:text-ivory/50">Anyone can discover and subscribe to this app</p>
				</div>
				<button
					type="button"
					onclick={() => isPublic = !isPublic}
					class="relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full transition-colors duration-200 {isPublic ? 'bg-amber' : 'bg-jet/20 dark:bg-ivory/20'}"
					role="switch"
					aria-checked={isPublic}
				>
					<span
						class="pointer-events-none inline-block h-5 w-5 translate-y-0.5 rounded-full bg-white shadow-sm ring-0 transition-transform duration-200 {isPublic ? 'translate-x-5.5' : 'translate-x-0.5'}"
					></span>
				</button>
			</div>

			<!-- Webhook URL -->
			<div>
				<label for="webhook" class="mb-1.5 block text-sm font-medium text-jet/80 dark:text-ivory/80">
					Webhook URL
					<span class="font-normal text-jet/40 dark:text-ivory/40">(optional)</span>
				</label>
				<input
					id="webhook"
					type="url"
					bind:value={webhookUrl}
					placeholder="https://your-server.com/webhook"
					class="w-full rounded-xl border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-4 py-3 text-sm text-jet dark:text-ivory placeholder:text-jet/30 dark:placeholder:text-ivory/30 focus:border-amber focus:ring-1 focus:ring-amber outline-none transition-colors"
				/>
			</div>

			<!-- Submit -->
			<button
				type="submit"
				disabled={submitting || !name.trim()}
				class="w-full rounded-xl bg-amber px-6 py-3 text-sm font-medium text-jet hover:bg-amber-light disabled:opacity-50 disabled:cursor-not-allowed transition-colors active:scale-[0.99]"
			>
				{#if submitting}
					<span class="inline-flex items-center gap-2">
						<span class="h-4 w-4 animate-spin rounded-full border-2 border-jet/30 border-t-jet"></span>
						Creating...
					</span>
				{:else}
					Create App
				{/if}
			</button>
		</form>
	</div>
</div>
