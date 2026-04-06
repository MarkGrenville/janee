import { writable } from 'svelte/store';
import { browser } from '$app/environment';

type Theme = 'light' | 'dark';

function getInitialTheme(): Theme {
	if (!browser) return 'dark';
	const stored = localStorage.getItem('janee-theme') as Theme | null;
	if (stored) return stored;
	return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

export const theme = writable<Theme>(getInitialTheme());

export function toggleTheme() {
	theme.update((current) => {
		const next = current === 'dark' ? 'light' : 'dark';
		if (browser) {
			localStorage.setItem('janee-theme', next);
			document.documentElement.classList.toggle('dark', next === 'dark');
		}
		return next;
	});
}

export function initTheme() {
	if (!browser) return;
	const initial = getInitialTheme();
	document.documentElement.classList.toggle('dark', initial === 'dark');
	theme.set(initial);
}
