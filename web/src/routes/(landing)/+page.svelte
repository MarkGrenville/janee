<svelte:head>
	<title>JaNee — Your life, one swipe at a time.</title>
</svelte:head>

<script lang="ts">
	let scrollY = $state(0);
	let navScrolled = $derived(scrollY > 50);
	let openFaq = $state<number | null>(null);

	function reveal(node: HTMLElement, options?: { delay?: number }) {
		const observer = new IntersectionObserver(
			([entry]) => {
				if (entry.isIntersecting) {
					setTimeout(() => node.classList.add('in-view'), options?.delay ?? 0);
					observer.unobserve(node);
				}
			},
			{ threshold: 0.1, rootMargin: '0px 0px -60px 0px' }
		);
		observer.observe(node);
		return { destroy: () => observer.disconnect() };
	}

	function toggleFaq(index: number) {
		openFaq = openFaq === index ? null : index;
	}

	const faqs = [
		{
			q: 'What exactly is JaNee?',
			a: 'JaNee is a decision-making app inspired by Tinder\u2019s swipe interface. Create collections of cards, swipe yes or no, and let the results guide your choices \u2014 from movie nights to business approvals.'
		},
		{
			q: 'Is it free to use?',
			a: 'Yes. JaNee offers a generous free tier for personal use. Pro plans unlock team features, API access, webhooks, and higher card limits for power users and businesses.'
		},
		{
			q: 'Can I integrate JaNee with AI workflows?',
			a: 'Absolutely. Our CLI tool and REST API let you pipe AI-generated options directly into JaNee as cards. Build human-in-the-loop approval flows in minutes.'
		},
		{
			q: 'How do webhooks work?',
			a: 'Configure a webhook URL on any app or card. When a decision is made, JaNee fires an HTTP POST with the decision payload \u2014 perfect for triggering Slack notifications, database updates, or downstream workflows.'
		},
		{
			q: 'Is my data private?',
			a: 'Your decisions are always private to you. Apps can be public or private. We never sell data, and you can export or delete everything at any time.'
		}
	];

	const testimonials = [
		{
			quote: 'JaNee replaced our 45-minute prioritization meetings. The team just swipes, and we have alignment in minutes.',
			name: 'Sarah Chen',
			role: 'Product Manager, Vercel'
		},
		{
			quote: 'We use it for hiring decisions. Quick, unbiased first-pass screening \u2014 and the webhook integration is chef\u2019s kiss.',
			name: 'Marcus Webb',
			role: 'Startup Founder'
		},
		{
			quote: 'The CLI lets me pipe GPT outputs straight into JaNee cards. My content approval workflow is fully automated now.',
			name: 'Priya Sharma',
			role: 'AI Developer'
		}
	];

	const useCases = [
		{
			title: 'Movie Watchlists',
			desc: 'Build the perfect movie night. Swipe through suggestions, match with friends on what to watch.',
			icon: 'film',
			span: 'md:row-span-2'
		},
		{
			title: 'Wedding Decisions',
			desc: 'Venues, catering, flowers \u2014 decide together without the debates.',
			icon: 'heart',
			span: ''
		},
		{
			title: 'Team Approvals',
			desc: 'Queue requests as cards. Approve or deny from your phone. No more email chains.',
			icon: 'briefcase',
			span: ''
		},
		{
			title: 'AI Workflows',
			desc: 'Pipe AI outputs into JaNee via CLI. Human-in-the-loop decisions, simplified.',
			icon: 'code',
			span: 'md:col-span-2'
		}
	];

	const steps = [
		{
			num: '01',
			title: 'Create',
			desc: 'Feed your choices as cards. Movies, hires, date-night ideas \u2014 anything worth deciding on.'
		},
		{
			num: '02',
			title: 'Swipe',
			desc: 'Yes, no, or skip. Fast, intuitive, and oddly satisfying. Each swipe is logged with timing data.'
		},
		{
			num: '03',
			title: 'Act',
			desc: 'Webhooks fire, data flows, decisions land exactly where they need to. Full audit trail included.'
		}
	];
</script>

<svelte:window bind:scrollY />

<!-- Navigation -->
<nav
	class="fixed top-0 inset-x-0 z-50 transition-all duration-700"
	class:nav-scrolled={navScrolled}
>
	<div class="max-w-7xl mx-auto px-6 lg:px-8 flex items-center justify-between h-20">
		<a href="/" class="font-serif text-2xl font-bold text-ivory tracking-tight">
			JaNee
		</a>
		<div class="flex items-center gap-6">
			<a
				href="/login"
				class="text-sm font-medium text-ivory/60 hover:text-ivory transition-colors duration-300"
			>
				Sign In
			</a>
			<a
				href="/register"
				class="inline-flex items-center bg-amber text-jet px-5 py-2.5 rounded-full text-sm font-semibold hover:bg-amber-light transition-all duration-300"
			>
				Get Started
			</a>
		</div>
	</div>
</nav>

<!-- ======================== HERO ======================== -->
<section class="hero-section relative min-h-screen flex items-center overflow-hidden bg-jet">
	<div class="hero-ambient"></div>
	<div class="hero-grain"></div>

	<div class="relative z-10 max-w-7xl mx-auto px-6 lg:px-8 w-full grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20 items-center pt-24 pb-20">
		<div class="text-center lg:text-left">
			<h1 class="font-serif text-5xl sm:text-6xl md:text-7xl lg:text-8xl xl:text-[6.5rem] font-bold text-ivory leading-[0.92] tracking-tight text-balance animate-fade-up">
				Your life,<br />one swipe<br />at a time.
			</h1>
			<p
				class="mt-8 text-lg md:text-xl text-ivory/50 max-w-md mx-auto lg:mx-0 leading-relaxed animate-fade-up"
				style="animation-delay: 0.2s"
			>
				Make every decision count. JaNee turns overwhelming choices into simple, satisfying swipes.
			</p>
			<div class="mt-10 animate-fade-up" style="animation-delay: 0.4s">
				<a
					href="/register"
					class="btn-glow inline-flex items-center gap-3 bg-amber text-jet px-8 py-4 rounded-full text-base font-semibold hover:bg-amber-light transition-all duration-300"
				>
					Start Swiping
					<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
					</svg>
				</a>
			</div>
		</div>

		<div class="flex justify-center lg:justify-end animate-fade-in" style="animation-delay: 0.6s">
			<div class="card-stack">
				<div class="stack-card stack-card-3">
					<div class="stack-card-inner">
						<span class="text-ivory/40 text-sm">Movie Night</span>
					</div>
				</div>
				<div class="stack-card stack-card-2">
					<div class="stack-card-inner">
						<span class="text-ivory/60 text-sm">Hire Sarah?</span>
					</div>
				</div>
				<div class="stack-card stack-card-1">
					<div class="stack-card-inner">
						<span class="text-3xl mb-3 block">🏖️</span>
						<span class="font-serif text-xl font-semibold text-ivory block">Beach or Mountains?</span>
						<span class="text-ivory/40 text-sm mt-1 block">Weekend getaway</span>
					</div>
					<div class="card-actions">
						<span class="card-action card-action-no">✕</span>
						<span class="card-action card-action-yes">✓</span>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div
		class="absolute bottom-10 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2 animate-fade-in"
		style="animation-delay: 1.2s"
	>
		<span class="text-[10px] font-medium tracking-[0.25em] uppercase text-ivory/25">Scroll</span>
		<div class="scroll-line"></div>
	</div>
</section>

<!-- ======================== PROBLEM / STORY ======================== -->
<section class="relative py-32 md:py-40 bg-ivory dark:bg-jet-light overflow-hidden">
	<div class="max-w-7xl mx-auto px-6 lg:px-8">
		<div class="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-20 items-start">
			<div class="lg:col-span-7 reveal" use:reveal>
				<div class="w-12 h-px bg-amber mb-10"></div>
				<h2 class="font-serif text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-bold text-jet dark:text-ivory leading-[0.95] tracking-tight">
					Decision<br />fatigue<br />is real.
				</h2>
			</div>
			<div class="lg:col-span-5 lg:pt-20 reveal" use:reveal={{ delay: 200 }}>
				<p class="text-lg md:text-xl text-jet/60 dark:text-ivory/50 leading-relaxed">
					Every day you make thousands of micro-decisions. What to eat. What to watch. Who to hire.
					Each one drains a little more willpower until the important choices feel impossible.
				</p>
				<div class="mt-10 pl-6 border-l-2 border-amber/40">
					<p class="font-serif text-xl md:text-2xl italic text-jet/80 dark:text-ivory/70 leading-snug">
						"The average adult makes 35,000 decisions per day. Most of them don't need a meeting."
					</p>
				</div>
				<p class="mt-10 text-lg text-jet/60 dark:text-ivory/50 leading-relaxed">
					JaNee reduces every decision to its essence: <em class="text-amber font-medium not-italic">yes</em> or <em class="text-amber font-medium not-italic">no</em>. No spreadsheets. No hour-long debates. Just swipe.
				</p>
			</div>
		</div>
	</div>
</section>

<!-- ======================== HOW IT WORKS ======================== -->
<section class="relative py-32 md:py-40 bg-jet text-ivory overflow-hidden">
	<div class="max-w-7xl mx-auto px-6 lg:px-8">
		<div class="reveal" use:reveal>
			<span class="text-xs font-semibold tracking-[0.2em] uppercase text-amber">How it works</span>
			<h2 class="font-serif text-4xl sm:text-5xl md:text-6xl font-bold mt-4 tracking-tight">
				Three steps.<br />Zero stress.
			</h2>
		</div>

		<div class="grid grid-cols-1 md:grid-cols-3 gap-8 lg:gap-12 mt-20">
			{#each steps as step, i}
				<div
					class="reveal group relative"
					use:reveal={{ delay: i * 150 }}
				>
					<div class="flex items-baseline gap-4 mb-6">
						<span class="font-serif text-6xl md:text-7xl font-bold text-amber/20 leading-none">{step.num}</span>
						<div class="flex-1 h-px bg-ivory/10"></div>
					</div>
					<h3 class="font-serif text-2xl md:text-3xl font-semibold mb-4">{step.title}</h3>
					<p class="text-ivory/50 leading-relaxed">{step.desc}</p>
				</div>
			{/each}
		</div>
	</div>
</section>

<!-- ======================== USE CASES ======================== -->
<section class="relative py-32 md:py-40 bg-ivory dark:bg-jet-light overflow-hidden">
	<div class="max-w-7xl mx-auto px-6 lg:px-8">
		<div class="reveal" use:reveal>
			<span class="text-xs font-semibold tracking-[0.2em] uppercase text-amber">Use cases</span>
			<h2 class="font-serif text-4xl sm:text-5xl md:text-6xl font-bold text-jet dark:text-ivory mt-4 tracking-tight">
				Built for every<br />decision.
			</h2>
		</div>

		<div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-16">
			{#each useCases as uc, i}
				<div
					class="use-case-card reveal {uc.span}"
					use:reveal={{ delay: i * 100 }}
				>
					<div class="p-8 md:p-10 h-full flex flex-col">
						<div class="w-12 h-12 rounded-xl bg-amber/10 flex items-center justify-center mb-6">
							{#if uc.icon === 'film'}
								<svg class="w-6 h-6 text-amber" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
									<path stroke-linecap="round" stroke-linejoin="round" d="M3.375 19.5h17.25m-17.25 0a1.125 1.125 0 01-1.125-1.125M3.375 19.5h1.5C5.496 19.5 6 18.996 6 18.375m-2.625 0V5.625m0 12.75v-1.5c0-.621.504-1.125 1.125-1.125m18.375 2.625V5.625m0 12.75c0 .621-.504 1.125-1.125 1.125m1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125m0 3.75h-1.5A1.125 1.125 0 0118 18.375M20.625 4.5H3.375m17.25 0c.621 0 1.125.504 1.125 1.125M20.625 4.5h-1.5C18.504 4.5 18 5.004 18 5.625m3.75 0v1.5c0 .621-.504 1.125-1.125 1.125M3.375 4.5c-.621 0-1.125.504-1.125 1.125M3.375 4.5h1.5C5.496 4.5 6 5.004 6 5.625m-2.625 0v1.5c0 .621.504 1.125 1.125 1.125m0 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125m1.5-3.75C5.496 8.25 6 7.746 6 7.125v-1.5M4.875 8.25C5.496 8.25 6 8.754 6 9.375v1.5m0-5.25v5.25m0-5.25C6 5.004 6.504 4.5 7.125 4.5h9.75c.621 0 1.125.504 1.125 1.125m1.125 2.625h1.5m-1.5 0A1.125 1.125 0 0118 7.125v-1.5m1.125 2.625c-.621 0-1.125.504-1.125 1.125v1.5m2.625-2.625c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125M18 5.625v5.25M7.125 12h9.75m-9.75 0A1.125 1.125 0 016 10.875M7.125 12C6.504 12 6 12.504 6 13.125m0-2.25C6 11.496 5.496 12 4.875 12M18 10.875c0 .621-.504 1.125-1.125 1.125M18 10.875c0 .621.504 1.125 1.125 1.125m-2.25 0c.621 0 1.125.504 1.125 1.125m-12 5.25v-5.25m0 5.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125m-12 0v-1.5c0-.621-.504-1.125-1.125-1.125M18 18.375v-5.25m0 5.25v-1.5c0-.621.504-1.125 1.125-1.125M18 13.125v1.5c0 .621.504 1.125 1.125 1.125M18 13.125c0-.621.504-1.125 1.125-1.125M6 13.125v1.5c0 .621-.504 1.125-1.125 1.125M6 13.125C6 12.504 5.496 12 4.875 12m-1.5 0h1.5m-1.5 0c-.621 0-1.125-.504-1.125-1.125v-1.5c0-.621.504-1.125 1.125-1.125m1.5 3.75c-.621 0-1.125-.504-1.125-1.125v-1.5c0-.621.504-1.125 1.125-1.125m0 3.75h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125M4.875 8.25c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125M19.125 12h1.5m0 0c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125m1.5 3.75c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125m-1.5-3.75c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125" />
								</svg>
							{:else if uc.icon === 'heart'}
								<svg class="w-6 h-6 text-amber" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
									<path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z" />
								</svg>
							{:else if uc.icon === 'briefcase'}
								<svg class="w-6 h-6 text-amber" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
									<path stroke-linecap="round" stroke-linejoin="round" d="M20.25 14.15v4.25c0 1.094-.787 2.036-1.872 2.18-2.087.277-4.216.42-6.378.42s-4.291-.143-6.378-.42c-1.085-.144-1.872-1.086-1.872-2.18v-4.25m16.5 0a2.18 2.18 0 00.75-1.661V8.706c0-1.081-.768-2.015-1.837-2.175a48.114 48.114 0 00-3.413-.387m4.5 8.006c-.194.165-.42.295-.673.38A23.978 23.978 0 0112 15.75c-2.648 0-5.195-.429-7.577-1.22a2.016 2.016 0 01-.673-.38m0 0A2.18 2.18 0 013 12.489V8.706c0-1.081.768-2.015 1.837-2.175a48.111 48.111 0 013.413-.387m7.5 0V5.25A2.25 2.25 0 0013.5 3h-3a2.25 2.25 0 00-2.25 2.25v.894m7.5 0a48.667 48.667 0 00-7.5 0" />
								</svg>
							{:else if uc.icon === 'code'}
								<svg class="w-6 h-6 text-amber" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
									<path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5" />
								</svg>
							{/if}
						</div>
						<h3 class="font-serif text-2xl font-semibold text-jet dark:text-ivory mb-3">{uc.title}</h3>
						<p class="text-jet/60 dark:text-ivory/50 leading-relaxed flex-1">{uc.desc}</p>
					</div>
				</div>
			{/each}
		</div>
	</div>
</section>

<!-- ======================== AI INTEGRATION ======================== -->
<section class="relative py-32 md:py-40 bg-jet text-ivory overflow-hidden">
	<div class="max-w-7xl mx-auto px-6 lg:px-8">
		<div class="grid grid-cols-1 lg:grid-cols-2 gap-16 lg:gap-20 items-center">
			<div class="reveal" use:reveal>
				<span class="text-xs font-semibold tracking-[0.2em] uppercase text-amber">API & CLI</span>
				<h2 class="font-serif text-4xl sm:text-5xl md:text-6xl font-bold mt-4 tracking-tight">
					Built for<br />builders.
				</h2>
				<p class="mt-8 text-lg text-ivory/50 leading-relaxed max-w-md">
					Pipe AI outputs, CI results, or any data source into JaNee via our CLI or REST API. Human-in-the-loop decisions at the speed of automation.
				</p>
				<a
					href="/docs/cli"
					class="inline-flex items-center gap-2 mt-8 text-amber hover:text-amber-light transition-colors font-medium"
				>
					Read the docs
					<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
					</svg>
				</a>
			</div>

			<div class="reveal" use:reveal={{ delay: 200 }}>
				<div class="terminal">
					<div class="terminal-header">
						<span class="terminal-dot" style="background: #FF5F56"></span>
						<span class="terminal-dot" style="background: #FFBD2E"></span>
						<span class="terminal-dot" style="background: #27C93F"></span>
					</div>
					<div class="terminal-body">
						<div class="terminal-line">
							<span class="terminal-prompt">$</span>
							<span class="terminal-cmd"> npx janee-cli add-card \</span>
						</div>
						<div class="terminal-line pl-6">
							<span class="terminal-flag">--app</span>
							<span class="terminal-str"> "approvals"</span>
							<span class="terminal-cmd"> \</span>
						</div>
						<div class="terminal-line pl-6">
							<span class="terminal-flag">--title</span>
							<span class="terminal-str"> "Hire Sarah?"</span>
							<span class="terminal-cmd"> \</span>
						</div>
						<div class="terminal-line pl-6">
							<span class="terminal-flag">--description</span>
							<span class="terminal-str"> "Senior Engineer, 5 yrs exp"</span>
						</div>
						<div class="terminal-line mt-4">
							<span class="terminal-success">✓ Card added to "approvals"</span>
							<span class="text-ivory/30"> (card_id: k8x2m)</span>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</section>

<!-- ======================== SOCIAL PROOF ======================== -->
<section class="relative py-32 md:py-40 bg-jet-light text-ivory overflow-hidden">
	<div class="max-w-7xl mx-auto px-6 lg:px-8">
		<div class="text-center reveal" use:reveal>
			<span class="text-xs font-semibold tracking-[0.2em] uppercase text-amber">Testimonials</span>
			<h2 class="font-serif text-4xl sm:text-5xl font-bold mt-4 tracking-tight">Loved by deciders.</h2>
		</div>

		<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-16">
			{#each testimonials as t, i}
				<div
					class="testimonial-card glass reveal"
					use:reveal={{ delay: i * 150 }}
				>
					<div class="p-8 md:p-10 flex flex-col h-full">
						<svg class="w-8 h-8 text-amber/40 mb-6 shrink-0" viewBox="0 0 24 24" fill="currentColor">
							<path d="M4.583 17.321C3.553 16.227 3 15 3 13.011c0-3.5 2.457-6.637 6.03-8.188l.893 1.378c-3.335 1.804-3.987 4.145-4.247 5.621.537-.278 1.24-.375 1.929-.311 1.804.167 3.226 1.648 3.226 3.489a3.5 3.5 0 01-3.5 3.5c-1.073 0-2.099-.49-2.748-1.179zm10 0C13.553 16.227 13 15 13 13.011c0-3.5 2.457-6.637 6.03-8.188l.893 1.378c-3.335 1.804-3.987 4.145-4.247 5.621.537-.278 1.24-.375 1.929-.311 1.804.167 3.226 1.648 3.226 3.489a3.5 3.5 0 01-3.5 3.5c-1.073 0-2.099-.49-2.748-1.179z" />
						</svg>
						<p class="text-ivory/80 leading-relaxed flex-1 text-lg">{t.quote}</p>
						<div class="mt-8 pt-6 border-t border-ivory/10">
							<p class="font-semibold text-ivory">{t.name}</p>
							<p class="text-ivory/40 text-sm mt-0.5">{t.role}</p>
						</div>
					</div>
				</div>
			{/each}
		</div>
	</div>
</section>

<!-- ======================== FAQ ======================== -->
<section class="relative py-32 md:py-40 bg-ivory dark:bg-jet overflow-hidden">
	<div class="max-w-3xl mx-auto px-6 lg:px-8">
		<div class="text-center reveal" use:reveal>
			<h2 class="font-serif text-4xl sm:text-5xl md:text-6xl font-bold text-jet dark:text-ivory tracking-tight">
				Questions
			</h2>
			<div class="w-12 h-px bg-amber mx-auto mt-6"></div>
		</div>

		<div class="mt-16 space-y-0 reveal" use:reveal={{ delay: 100 }}>
			{#each faqs as faq, i}
				<div class="faq-item border-b border-jet/10 dark:border-ivory/10">
					<button
						onclick={() => toggleFaq(i)}
						class="w-full flex items-center gap-6 py-7 text-left group"
					>
						<span class="font-serif text-2xl md:text-3xl text-amber/40 tabular-nums shrink-0">
							{String(i + 1).padStart(2, '0')}
						</span>
						<span class="font-serif text-xl md:text-2xl font-medium text-jet dark:text-ivory flex-1 group-hover:text-amber transition-colors duration-300">
							{faq.q}
						</span>
						<svg
							class="w-5 h-5 text-jet/40 dark:text-ivory/40 shrink-0 transition-transform duration-500 {openFaq === i ? 'rotate-180' : ''}"
							fill="none"
							viewBox="0 0 24 24"
							stroke="currentColor"
							stroke-width="1.5"
						>
							<path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />
						</svg>
					</button>
					<div
						class="faq-answer"
						style="grid-template-rows: {openFaq === i ? '1fr' : '0fr'}"
					>
						<div class="overflow-hidden">
							<p class="pb-7 pl-14 md:pl-16 text-jet/60 dark:text-ivory/50 leading-relaxed max-w-xl">
								{faq.a}
							</p>
						</div>
					</div>
				</div>
			{/each}
		</div>
	</div>
</section>

<!-- ======================== FINAL CTA ======================== -->
<section class="relative py-32 md:py-40 overflow-hidden cta-gradient">
	<div class="relative z-10 max-w-4xl mx-auto px-6 lg:px-8 text-center">
		<div class="reveal" use:reveal>
			<h2 class="font-serif text-5xl sm:text-6xl md:text-7xl lg:text-8xl font-bold text-jet leading-[0.92] tracking-tight">
				Ready to<br />decide?
			</h2>
			<p class="mt-8 text-xl text-jet/60 max-w-md mx-auto leading-relaxed">
				Stop overthinking. Start swiping. Your decisions are waiting.
			</p>
			<div class="mt-10">
				<a
					href="/register"
					class="inline-flex items-center gap-3 bg-jet text-ivory px-8 py-4 rounded-full text-base font-semibold hover:bg-jet-light transition-all duration-300 shadow-xl shadow-black/20"
				>
					Get Started Free
					<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
					</svg>
				</a>
			</div>
		</div>
	</div>
</section>

<!-- ======================== FOOTER ======================== -->
<footer class="bg-jet text-ivory py-20 border-t border-ivory/5">
	<div class="max-w-7xl mx-auto px-6 lg:px-8">
		<div class="grid grid-cols-1 md:grid-cols-4 gap-12 md:gap-8">
			<div class="md:col-span-2">
				<a href="/" class="font-serif text-2xl font-bold tracking-tight">JaNee</a>
				<p class="mt-4 text-ivory/40 leading-relaxed max-w-sm">
					Make every decision count. The Tinder-style decision app for individuals, teams, and AI workflows.
				</p>
			</div>
			<div>
				<h4 class="text-xs font-semibold tracking-[0.15em] uppercase text-ivory/30 mb-4">Product</h4>
				<ul class="space-y-3">
					<li><a href="/about" class="text-ivory/60 hover:text-ivory transition-colors text-sm">About</a></li>
					<li><a href="/docs" class="text-ivory/60 hover:text-ivory transition-colors text-sm">Docs</a></li>
					<li><a href="/docs/cli" class="text-ivory/60 hover:text-ivory transition-colors text-sm">CLI</a></li>
					<li><a href="/docs/api" class="text-ivory/60 hover:text-ivory transition-colors text-sm">API</a></li>
				</ul>
			</div>
			<div>
				<h4 class="text-xs font-semibold tracking-[0.15em] uppercase text-ivory/30 mb-4">Legal</h4>
				<ul class="space-y-3">
					<li><a href="/privacy" class="text-ivory/60 hover:text-ivory transition-colors text-sm">Privacy</a></li>
					<li><a href="/terms" class="text-ivory/60 hover:text-ivory transition-colors text-sm">Terms</a></li>
				</ul>
			</div>
		</div>
		<div class="mt-16 pt-8 border-t border-ivory/5 flex flex-col sm:flex-row justify-between items-center gap-4">
			<p class="text-ivory/25 text-sm">&copy; {new Date().getFullYear()} JaNee. All rights reserved.</p>
			<p class="text-ivory/25 text-xs">Designed to help you decide.</p>
		</div>
	</div>
</footer>

<style>
	/* ===== Navigation ===== */
	.nav-scrolled {
		background: rgba(10, 10, 10, 0.85);
		backdrop-filter: blur(24px);
		-webkit-backdrop-filter: blur(24px);
		border-bottom: 1px solid rgba(255, 255, 255, 0.05);
	}

	/* ===== Hero ===== */
	.hero-ambient {
		position: absolute;
		inset: 0;
		background:
			radial-gradient(ellipse at 25% 40%, rgba(212, 168, 83, 0.12) 0%, transparent 55%),
			radial-gradient(ellipse at 75% 60%, rgba(139, 154, 126, 0.06) 0%, transparent 45%),
			radial-gradient(ellipse at 50% 100%, rgba(196, 144, 138, 0.04) 0%, transparent 40%);
		animation: ambientShift 20s ease-in-out infinite alternate;
	}

	@keyframes ambientShift {
		from { opacity: 1; transform: scale(1); }
		to { opacity: 0.7; transform: scale(1.05); }
	}

	.hero-grain {
		position: absolute;
		inset: 0;
		opacity: 0.035;
		pointer-events: none;
		z-index: 1;
		background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.7' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
		background-repeat: repeat;
		mix-blend-mode: overlay;
	}

	/* ===== Card Stack ===== */
	.card-stack {
		position: relative;
		width: 260px;
		height: 360px;
	}

	@media (min-width: 768px) {
		.card-stack {
			width: 300px;
			height: 400px;
		}
	}

	.stack-card {
		position: absolute;
		inset: 0;
		border-radius: 24px;
		background: linear-gradient(145deg, #1a1a1a 0%, #111 100%);
		border: 1px solid rgba(255, 255, 255, 0.08);
		display: flex;
		flex-direction: column;
		overflow: hidden;
	}

	.stack-card-inner {
		flex: 1;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 2rem;
		text-align: center;
	}

	.stack-card-3 {
		transform: rotate(-6deg) translateX(-16px) translateY(8px);
		opacity: 0.5;
		z-index: 1;
	}

	.stack-card-2 {
		transform: rotate(3deg) translateX(8px) translateY(-4px);
		opacity: 0.75;
		z-index: 2;
	}

	.stack-card-1 {
		z-index: 3;
		border: 1px solid rgba(212, 168, 83, 0.15);
		animation: swipeHint 6s ease-in-out infinite;
	}

	@keyframes swipeHint {
		0%, 100% {
			transform: translateX(0) rotate(0deg);
			box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4);
		}
		30% {
			transform: translateX(20px) rotate(2.5deg);
			box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4),
				0 0 40px rgba(74, 222, 128, 0.15);
		}
		70% {
			transform: translateX(-14px) rotate(-1.5deg);
			box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4),
				0 0 40px rgba(248, 113, 113, 0.15);
		}
	}

	.card-actions {
		display: flex;
		justify-content: center;
		gap: 2rem;
		padding: 1.25rem 2rem;
		border-top: 1px solid rgba(255, 255, 255, 0.06);
	}

	.card-action {
		width: 48px;
		height: 48px;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 1.125rem;
		font-weight: 700;
		transition: transform 0.2s;
	}

	.card-action-no {
		background: rgba(248, 113, 113, 0.12);
		color: #F87171;
		border: 1px solid rgba(248, 113, 113, 0.2);
	}

	.card-action-yes {
		background: rgba(74, 222, 128, 0.12);
		color: #4ADE80;
		border: 1px solid rgba(74, 222, 128, 0.2);
	}

	/* ===== Scroll Indicator ===== */
	.scroll-line {
		width: 1px;
		height: 40px;
		background: linear-gradient(to bottom, rgba(250, 248, 245, 0.4), transparent);
		animation: scrollPulse 2.5s ease-in-out infinite;
	}

	@keyframes scrollPulse {
		0%, 100% { transform: scaleY(0.6); opacity: 0.3; }
		50% { transform: scaleY(1); opacity: 0.8; }
	}

	/* ===== Buttons ===== */
	.btn-glow {
		box-shadow:
			0 0 30px rgba(212, 168, 83, 0.25),
			0 0 60px rgba(212, 168, 83, 0.08);
		transition: box-shadow 0.4s ease, background-color 0.3s ease;
	}

	.btn-glow:hover {
		box-shadow:
			0 0 40px rgba(212, 168, 83, 0.45),
			0 0 80px rgba(212, 168, 83, 0.15);
	}

	/* ===== Reveal Animations ===== */
	.reveal {
		opacity: 0;
		transform: translateY(40px);
		transition:
			opacity 0.9s cubic-bezier(0.16, 1, 0.3, 1),
			transform 0.9s cubic-bezier(0.16, 1, 0.3, 1);
	}

	.reveal:global(.in-view) {
		opacity: 1;
		transform: translateY(0);
	}

	/* ===== Use Case Cards ===== */
	.use-case-card {
		background: rgba(10, 10, 10, 0.03);
		border: 1px solid rgba(10, 10, 10, 0.06);
		border-radius: 20px;
		transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
	}

	:global(.dark) .use-case-card {
		background: rgba(255, 255, 255, 0.03);
		border-color: rgba(255, 255, 255, 0.06);
	}

	.use-case-card:hover {
		transform: translateY(-4px);
		border-color: rgba(212, 168, 83, 0.2);
		box-shadow: 0 20px 40px -12px rgba(0, 0, 0, 0.1);
	}

	:global(.dark) .use-case-card:hover {
		box-shadow: 0 20px 40px -12px rgba(0, 0, 0, 0.4);
	}

	/* ===== Terminal ===== */
	.terminal {
		background: #0a0a0a;
		border: 1px solid rgba(255, 255, 255, 0.08);
		border-radius: 16px;
		overflow: hidden;
		font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', monospace;
		font-size: 0.875rem;
		box-shadow:
			0 25px 50px -12px rgba(0, 0, 0, 0.5),
			0 0 80px rgba(39, 201, 63, 0.03);
	}

	.terminal-header {
		display: flex;
		gap: 8px;
		padding: 16px 20px;
		background: rgba(255, 255, 255, 0.02);
		border-bottom: 1px solid rgba(255, 255, 255, 0.05);
	}

	.terminal-dot {
		width: 12px;
		height: 12px;
		border-radius: 50%;
	}

	.terminal-body {
		padding: 24px;
		line-height: 2;
	}

	.terminal-line {
		white-space: nowrap;
		overflow-x: auto;
	}

	.terminal-prompt { color: #27C93F; }
	.terminal-cmd { color: #FAF8F5; }
	.terminal-flag { color: #D4A853; }
	.terminal-str { color: #8B9A7E; }
	.terminal-success {
		color: #4ADE80;
		text-shadow: 0 0 20px rgba(74, 222, 128, 0.3);
	}

	/* ===== Testimonials ===== */
	.testimonial-card {
		border-radius: 20px;
		transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
	}

	.testimonial-card:hover {
		transform: translateY(-4px);
		border-color: rgba(212, 168, 83, 0.15);
	}

	/* ===== FAQ Accordion ===== */
	.faq-answer {
		display: grid;
		grid-template-rows: 0fr;
		transition: grid-template-rows 0.5s cubic-bezier(0.16, 1, 0.3, 1);
	}

	/* ===== CTA Gradient ===== */
	.cta-gradient {
		background: linear-gradient(
			135deg,
			var(--color-amber-dark) 0%,
			var(--color-amber) 50%,
			var(--color-amber-light) 100%
		);
	}
</style>
