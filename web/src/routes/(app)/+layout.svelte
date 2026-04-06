<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { user, isAuthenticated, loading, signOut } from '$lib/stores/auth';
	import { theme, toggleTheme } from '$lib/stores/theme';

	let { children } = $props();

	let sidebarCollapsed = $state(false);
	let mobileMenuOpen = $state(false);

	const navItems = [
		{ label: 'Swipe', href: '/swipe', icon: 'swipe' },
		{ label: 'Apps', href: '/apps', icon: 'apps' },
		{ label: 'Decisions', href: '/decisions', icon: 'decisions' },
		{ label: 'Profile', href: '/profile', icon: 'profile' },
		{ label: 'Settings', href: '/settings', icon: 'settings' },
	];

	$effect(() => {
		if (!$loading && !$isAuthenticated) {
			goto('/login');
		}
	});

	function isActive(href: string): boolean {
		return $page.url.pathname === href || $page.url.pathname.startsWith(href + '/');
	}

	async function handleSignOut() {
		await signOut();
		goto('/login');
	}

	function navigate(href: string) {
		goto(href);
		mobileMenuOpen = false;
	}

	function userInitial(u: any): string {
		if (!u) return '?';
		if (u.displayName) return u.displayName.charAt(0).toUpperCase();
		if (u.email) return u.email.charAt(0).toUpperCase();
		return '?';
	}
</script>

{#if $loading}
	<div class="flex h-screen items-center justify-center bg-ivory dark:bg-jet">
		<div class="flex flex-col items-center gap-4">
			<div class="h-8 w-8 animate-spin rounded-full border-2 border-amber border-t-transparent"></div>
			<p class="font-serif text-lg text-jet/60 dark:text-ivory/60">Loading...</p>
		</div>
	</div>
{:else if $isAuthenticated}
	<div class="flex h-screen bg-ivory dark:bg-jet">
		<!-- Desktop Sidebar -->
		<aside
			class="hidden md:flex flex-col border-r border-jet/10 dark:border-ivory/10 bg-ivory dark:bg-jet transition-all duration-300 {sidebarCollapsed ? 'w-20' : 'w-64'}"
		>
			<!-- Logo -->
			<div class="flex h-16 items-center justify-between px-4 border-b border-jet/10 dark:border-ivory/10">
				{#if !sidebarCollapsed}
					<button onclick={() => navigate('/swipe')} class="font-serif text-xl tracking-wide text-jet dark:text-ivory">
						JaNee
					</button>
				{/if}
				<button
					onclick={() => sidebarCollapsed = !sidebarCollapsed}
					class="rounded-lg p-2 text-jet/60 hover:bg-jet/5 dark:text-ivory/60 dark:hover:bg-ivory/5 transition-colors"
					aria-label="Toggle sidebar"
				>
					<svg class="h-5 w-5 transition-transform {sidebarCollapsed ? 'rotate-180' : ''}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
						<path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
					</svg>
				</button>
			</div>

			<!-- Nav Items -->
			<nav class="flex-1 px-3 py-4 space-y-1">
				{#each navItems as item}
					<button
						onclick={() => navigate(item.href)}
						class="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all duration-200
							{isActive(item.href)
								? 'bg-amber/10 text-amber dark:bg-amber/15 dark:text-amber-light'
								: 'text-jet/70 hover:bg-jet/5 hover:text-jet dark:text-ivory/70 dark:hover:bg-ivory/5 dark:hover:text-ivory'}"
					>
						{#if item.icon === 'swipe'}
							<svg class="h-5 w-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5" />
							</svg>
						{:else if item.icon === 'apps'}
							<svg class="h-5 w-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6zM3.75 15.75A2.25 2.25 0 016 13.5h2.25a2.25 2.25 0 012.25 2.25V18a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18v-2.25zM13.5 6a2.25 2.25 0 012.25-2.25H18A2.25 2.25 0 0120.25 6v2.25A2.25 2.25 0 0118 10.5h-2.25a2.25 2.25 0 01-2.25-2.25V6zM13.5 15.75a2.25 2.25 0 012.25-2.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-2.25A2.25 2.25 0 0113.5 18v-2.25z" />
							</svg>
						{:else if item.icon === 'decisions'}
							<svg class="h-5 w-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15a2.25 2.25 0 012.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25z" />
							</svg>
						{:else if item.icon === 'profile'}
							<svg class="h-5 w-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
							</svg>
						{:else if item.icon === 'settings'}
							<svg class="h-5 w-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z" />
								<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
							</svg>
						{/if}
						{#if !sidebarCollapsed}
							<span>{item.label}</span>
						{/if}
					</button>
				{/each}
			</nav>

			<!-- Theme Toggle -->
			<div class="px-3 py-2 border-t border-jet/10 dark:border-ivory/10">
				<button
					onclick={toggleTheme}
					class="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm text-jet/70 hover:bg-jet/5 dark:text-ivory/70 dark:hover:bg-ivory/5 transition-colors"
				>
					{#if $theme === 'dark'}
						<svg class="h-5 w-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
							<path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" />
						</svg>
					{:else}
						<svg class="h-5 w-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
							<path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 006.002-2.082z" />
						</svg>
					{/if}
					{#if !sidebarCollapsed}
						<span>{$theme === 'dark' ? 'Light Mode' : 'Dark Mode'}</span>
					{/if}
				</button>
			</div>

			<!-- User -->
			<div class="border-t border-jet/10 dark:border-ivory/10 p-3">
				<div class="flex items-center gap-3 {sidebarCollapsed ? 'justify-center' : ''}">
					{#if $user?.photoURL}
						<img src={$user.photoURL} alt="Avatar" class="h-9 w-9 rounded-full object-cover ring-2 ring-amber/30" />
					{:else}
						<div class="flex h-9 w-9 items-center justify-center rounded-full bg-amber/20 font-serif text-sm font-semibold text-amber">
							{userInitial($user)}
						</div>
					{/if}
					{#if !sidebarCollapsed}
						<div class="flex-1 min-w-0">
							<p class="truncate text-sm font-medium text-jet dark:text-ivory">{$user?.displayName || 'User'}</p>
							<p class="truncate text-xs text-jet/50 dark:text-ivory/50">{$user?.email}</p>
						</div>
						<button
							onclick={handleSignOut}
							class="rounded-lg p-1.5 text-jet/40 hover:text-rose dark:text-ivory/40 dark:hover:text-rose transition-colors"
							aria-label="Sign out"
						>
							<svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15m3 0l3-3m0 0l-3-3m3 3H9" />
							</svg>
						</button>
					{/if}
				</div>
			</div>
		</aside>

		<!-- Main Content -->
		<main class="flex-1 overflow-y-auto pb-20 md:pb-0">
			{@render children()}
		</main>

		<!-- Mobile Bottom Nav -->
		<nav class="md:hidden fixed bottom-0 left-0 right-0 z-50 border-t border-jet/10 dark:border-ivory/10 bg-ivory/95 dark:bg-jet/95 backdrop-blur-xl">
			<div class="flex items-center justify-around px-2 py-1">
				{#each navItems as item}
					<button
						onclick={() => navigate(item.href)}
						class="flex flex-col items-center gap-0.5 rounded-xl px-3 py-2 text-xs transition-colors
							{isActive(item.href)
								? 'text-amber dark:text-amber-light'
								: 'text-jet/50 dark:text-ivory/50'}"
					>
						{#if item.icon === 'swipe'}
							<svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5" />
							</svg>
						{:else if item.icon === 'apps'}
							<svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6zM3.75 15.75A2.25 2.25 0 016 13.5h2.25a2.25 2.25 0 012.25 2.25V18a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18v-2.25zM13.5 6a2.25 2.25 0 012.25-2.25H18A2.25 2.25 0 0120.25 6v2.25A2.25 2.25 0 0118 10.5h-2.25a2.25 2.25 0 01-2.25-2.25V6zM13.5 15.75a2.25 2.25 0 012.25-2.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-2.25A2.25 2.25 0 0113.5 18v-2.25z" />
							</svg>
						{:else if item.icon === 'decisions'}
							<svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15a2.25 2.25 0 012.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25z" />
							</svg>
						{:else if item.icon === 'profile'}
							<svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
							</svg>
						{:else if item.icon === 'settings'}
							<svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z" />
								<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
							</svg>
						{/if}
						<span>{item.label}</span>
					</button>
				{/each}
			</div>
		</nav>
	</div>
{/if}
