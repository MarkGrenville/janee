<script lang="ts">
	import { onMount } from 'svelte';
	import { api } from '$lib/firebase/api';

	let apps = $state<any[]>([]);
	let cards = $state<any[]>([]);
	let selectedAppId = $state('all');
	let loadingCards = $state(true);
	let error = $state('');

	let dragStartX = $state(0);
	let dragStartY = $state(0);
	let dragOffsetX = $state(0);
	let dragOffsetY = $state(0);
	let isDragging = $state(false);
	let isAnimatingOut = $state(false);
	let exitX = $state(0);
	let exitRotation = $state(0);
	let cardStartTime = $state(0);

	const SWIPE_THRESHOLD = 100;
	const MAX_ROTATION = 15;

	let currentCard = $derived(cards.length > 0 ? cards[0] : null);
	let nextCard = $derived(cards.length > 1 ? cards[1] : null);

	let rotation = $derived(isDragging ? (dragOffsetX / SWIPE_THRESHOLD) * MAX_ROTATION : 0);
	let swipeDirection = $derived<'yes' | 'no' | null>(
		isDragging && Math.abs(dragOffsetX) > 30
			? dragOffsetX > 0 ? 'yes' : 'no'
			: null
	);
	let swipeProgress = $derived(Math.min(Math.abs(dragOffsetX) / SWIPE_THRESHOLD, 1));

	onMount(async () => {
		await loadApps();
		await loadCards();
	});

	async function loadApps() {
		try {
			apps = await api.apps.list();
		} catch (e: any) {
			console.log('[swipe] Error loading apps:', e.message);
		}
	}

	async function loadCards() {
		loadingCards = true;
		error = '';
		try {
			if (selectedAppId === 'all') {
				const allCards: any[] = [];
				for (const app of apps) {
					const appCards = await api.cards.undecided(app.id);
					allCards.push(...appCards.map((c: any) => ({ ...c, appId: app.id, appName: app.name })));
				}
				cards = allCards;
			} else {
				const appCards = await api.cards.undecided(selectedAppId);
				const app = apps.find((a: any) => a.id === selectedAppId);
				cards = appCards.map((c: any) => ({ ...c, appId: selectedAppId, appName: app?.name || '' }));
			}
			cardStartTime = Date.now();
		} catch (e: any) {
			error = e.message;
			console.log('[swipe] Error loading cards:', e.message);
		} finally {
			loadingCards = false;
		}
	}

	function handlePointerDown(e: PointerEvent) {
		if (isAnimatingOut) return;
		isDragging = true;
		dragStartX = e.clientX;
		dragStartY = e.clientY;
		dragOffsetX = 0;
		dragOffsetY = 0;
		(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
	}

	function handlePointerMove(e: PointerEvent) {
		if (!isDragging) return;
		dragOffsetX = e.clientX - dragStartX;
		dragOffsetY = e.clientY - dragStartY;
	}

	function handlePointerUp() {
		if (!isDragging) return;
		isDragging = false;

		if (Math.abs(dragOffsetX) >= SWIPE_THRESHOLD) {
			const decision = dragOffsetX > 0 ? 'yes' : 'no';
			animateOut(decision);
		} else {
			dragOffsetX = 0;
			dragOffsetY = 0;
		}
	}

	function animateOut(decision: 'yes' | 'no' | 'skip') {
		isAnimatingOut = true;
		if (decision === 'yes') {
			exitX = window.innerWidth;
			exitRotation = MAX_ROTATION;
		} else if (decision === 'no') {
			exitX = -window.innerWidth;
			exitRotation = -MAX_ROTATION;
		} else {
			exitX = 0;
			exitRotation = 0;
		}

		setTimeout(() => {
			submitDecision(decision);
		}, 300);
	}

	async function submitDecision(decision: 'yes' | 'no' | 'skip') {
		if (!currentCard) return;
		try {
			await api.decisions.create(currentCard.appId, currentCard.id, decision);
		} catch (e: any) {
			console.log('[swipe] Error submitting decision:', e.message);
		}
		cards = cards.slice(1);
		dragOffsetX = 0;
		dragOffsetY = 0;
		isAnimatingOut = false;
		cardStartTime = Date.now();
	}

	function handleYes() {
		if (!currentCard || isAnimatingOut) return;
		animateOut('yes');
	}

	function handleNo() {
		if (!currentCard || isAnimatingOut) return;
		animateOut('no');
	}

	function handleSkip() {
		if (!currentCard || isAnimatingOut) return;
		animateOut('skip');
	}

	async function handleAppChange(e: Event) {
		selectedAppId = (e.target as HTMLSelectElement).value;
		await loadCards();
	}
</script>

<div class="flex flex-col h-full min-h-[calc(100vh-5rem)] md:min-h-screen">
	<!-- Header -->
	<header class="px-6 pt-6 pb-4 md:px-8 md:pt-8">
		<div class="mx-auto max-w-lg">
			<h1 class="font-serif text-2xl md:text-3xl text-jet dark:text-ivory mb-4">Swipe</h1>
			<select
				value={selectedAppId}
				onchange={handleAppChange}
				class="w-full rounded-xl border border-jet/10 dark:border-ivory/10 bg-white dark:bg-jet-light px-4 py-2.5 text-sm text-jet dark:text-ivory focus:border-amber focus:ring-1 focus:ring-amber outline-none transition-colors"
			>
				<option value="all">All Apps</option>
				{#each apps as app}
					<option value={app.id}>{app.icon || ''} {app.name}</option>
				{/each}
			</select>
		</div>
	</header>

	<!-- Card Stack -->
	<div class="flex-1 flex items-center justify-center px-6 pb-6">
		<div class="relative w-full max-w-sm mx-auto" style="height: 420px;">
			{#if loadingCards}
				<div class="absolute inset-0 flex items-center justify-center">
					<div class="h-8 w-8 animate-spin rounded-full border-2 border-amber border-t-transparent"></div>
				</div>
			{:else if error}
				<div class="absolute inset-0 flex items-center justify-center">
					<div class="text-center">
						<p class="text-rose mb-3">{error}</p>
						<button onclick={loadCards} class="text-sm text-amber hover:text-amber-light transition-colors">Try again</button>
					</div>
				</div>
			{:else if !currentCard}
				<div class="absolute inset-0 flex items-center justify-center">
					<div class="text-center">
						<div class="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-amber/10">
							<svg class="h-10 w-10 text-amber" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
							</svg>
						</div>
						<h2 class="font-serif text-xl text-jet dark:text-ivory mb-2">All caught up!</h2>
						<p class="text-sm text-jet/60 dark:text-ivory/60">No more cards to swipe on. Check back later.</p>
					</div>
				</div>
			{:else}
				<!-- Next card (peeking behind) -->
				{#if nextCard}
					<div
						class="absolute inset-x-2 top-2 bottom-0 rounded-2xl glass dark:glass bg-white/80 dark:bg-jet-light/80 shadow-lg"
						style="transform: scale(0.96); transform-origin: center top;"
					>
						<div class="p-6">
							<div class="flex items-start gap-3">
								{#if nextCard.icon}
									<span class="text-3xl">{nextCard.icon}</span>
								{/if}
								<div>
									<h3 class="font-serif text-lg text-jet dark:text-ivory">{nextCard.title}</h3>
									{#if nextCard.appName}
										<p class="text-xs text-jet/50 dark:text-ivory/50 mt-0.5">{nextCard.appName}</p>
									{/if}
								</div>
							</div>
						</div>
					</div>
				{/if}

				<!-- Current card -->
				<div
					class="absolute inset-0 rounded-2xl bg-white dark:bg-jet-light shadow-xl cursor-grab active:cursor-grabbing select-none overflow-hidden touch-none"
					style="
						transform: translate({isAnimatingOut ? exitX : dragOffsetX}px, {isDragging ? dragOffsetY * 0.3 : 0}px) rotate({isAnimatingOut ? exitRotation : rotation}deg);
						transition: {isDragging ? 'none' : 'transform 0.3s ease-out, opacity 0.3s ease-out'};
						opacity: {isAnimatingOut ? 0 : 1};
					"
					role="button"
					tabindex="0"
					onpointerdown={handlePointerDown}
					onpointermove={handlePointerMove}
					onpointerup={handlePointerUp}
					onpointercancel={handlePointerUp}
				>
					<!-- Swipe direction overlay -->
					{#if swipeDirection === 'yes'}
						<div
							class="absolute inset-0 rounded-2xl border-4 border-swipe-yes/50 pointer-events-none z-10"
							style="opacity: {swipeProgress};"
						>
							<div class="absolute top-6 left-6 rounded-lg bg-swipe-yes/20 px-4 py-2" style="opacity: {swipeProgress};">
								<span class="font-serif text-xl font-bold text-swipe-yes">YES</span>
							</div>
						</div>
					{:else if swipeDirection === 'no'}
						<div
							class="absolute inset-0 rounded-2xl border-4 border-swipe-no/50 pointer-events-none z-10"
							style="opacity: {swipeProgress};"
						>
							<div class="absolute top-6 right-6 rounded-lg bg-swipe-no/20 px-4 py-2" style="opacity: {swipeProgress};">
								<span class="font-serif text-xl font-bold text-swipe-no">NO</span>
							</div>
						</div>
					{/if}

					<!-- Card content -->
					<div class="flex h-full flex-col p-6">
						{#if currentCard.imageUrl}
							<div class="mb-4 h-40 overflow-hidden rounded-xl">
								<img src={currentCard.imageUrl} alt={currentCard.title} class="h-full w-full object-cover" />
							</div>
						{/if}

						<div class="flex items-start gap-4 mb-4">
							{#if currentCard.icon}
								<span class="text-4xl">{currentCard.icon}</span>
							{/if}
							<div class="flex-1">
								<h2 class="font-serif text-xl md:text-2xl text-jet dark:text-ivory leading-snug">{currentCard.title}</h2>
								{#if currentCard.appName}
									<p class="text-xs text-amber mt-1">{currentCard.appName}</p>
								{/if}
							</div>
						</div>

						{#if currentCard.description}
							<p class="text-sm leading-relaxed text-jet/70 dark:text-ivory/70 flex-1">{currentCard.description}</p>
						{/if}

						{#if currentCard.linkUrl}
							<a
								href={currentCard.linkUrl}
								target="_blank"
								rel="noopener noreferrer"
								class="mt-4 inline-flex items-center gap-1.5 text-sm text-amber hover:text-amber-light transition-colors"
								onclick={(e) => e.stopPropagation()}
							>
								<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
									<path stroke-linecap="round" stroke-linejoin="round" d="M13.19 8.688a4.5 4.5 0 011.242 7.244l-4.5 4.5a4.5 4.5 0 01-6.364-6.364l1.757-1.757m9.914-3.814a4.5 4.5 0 00-1.242-7.244l-4.5-4.5a4.5 4.5 0 00-6.364 6.364L4.25 8.497" />
								</svg>
								View link
							</a>
						{/if}
					</div>
				</div>
			{/if}
		</div>
	</div>

	<!-- Action Buttons -->
	{#if currentCard && !loadingCards}
		<div class="px-6 pb-8 md:pb-10">
			<div class="mx-auto flex max-w-sm items-center justify-center gap-6">
				<button
					onclick={handleNo}
					class="flex h-16 w-16 items-center justify-center rounded-full border-2 border-swipe-no/30 text-swipe-no hover:bg-swipe-no/10 hover:border-swipe-no/60 transition-all duration-200 active:scale-95"
					aria-label="No"
				>
					<svg class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
						<path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
					</svg>
				</button>

				<button
					onclick={handleSkip}
					class="flex h-12 w-12 items-center justify-center rounded-full border-2 border-swipe-skip/30 text-swipe-skip hover:bg-swipe-skip/10 hover:border-swipe-skip/60 transition-all duration-200 active:scale-95"
					aria-label="Skip"
				>
					<svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
						<path stroke-linecap="round" stroke-linejoin="round" d="M3 8.688c0-.864.933-1.405 1.683-.977l7.108 4.062a1.125 1.125 0 010 1.953l-7.108 4.062A1.125 1.125 0 013 16.81V8.688zM12.75 8.688c0-.864.933-1.405 1.683-.977l7.108 4.062a1.125 1.125 0 010 1.953l-7.108 4.062a1.125 1.125 0 01-1.683-.977V8.688z" />
					</svg>
				</button>

				<button
					onclick={handleYes}
					class="flex h-16 w-16 items-center justify-center rounded-full border-2 border-swipe-yes/30 text-swipe-yes hover:bg-swipe-yes/10 hover:border-swipe-yes/60 transition-all duration-200 active:scale-95"
					aria-label="Yes"
				>
					<svg class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
						<path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
					</svg>
				</button>
			</div>
		</div>
	{/if}
</div>
