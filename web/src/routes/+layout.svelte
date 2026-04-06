<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { initAuth } from '$lib/stores/auth';
	import { initTheme } from '$lib/stores/theme';

	let { children } = $props();

	onMount(() => {
		initTheme();
		initAuth();
	});
</script>

{@render children()}
