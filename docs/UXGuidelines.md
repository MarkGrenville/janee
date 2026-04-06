# JaNee — UX Guidelines

## Design Philosophy

JaNee follows an **editorial luxury** aesthetic — cinematic, premium, and visually dramatic. The goal is to feel closer to an Awwwards-quality concept site than a generic SaaS product.

---

## Design Tokens

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Jet | `#0A0A0A` | Primary dark background |
| Jet Light | `#1A1A1A` | Elevated surfaces (dark mode) |
| Jet Lighter | `#2A2A2A` | Tertiary surfaces (dark mode) |
| Ivory | `#FAF8F5` | Primary light background |
| Ivory Dark | `#F0EDE8` | Elevated surfaces (light mode) |
| Amber | `#D4A853` | Primary accent — CTAs, interactive elements, highlights |
| Amber Light | `#E8C97A` | Hover states, secondary accent |
| Amber Dark | `#B8922F` | Active/pressed states |
| Sage | `#8B9A7E` | Secondary accent — success, nature, calm |
| Sage Light | `#A8B59E` | Subtle secondary |
| Rose | `#C4908A` | Tertiary accent — warmth, decline/reject |
| Rose Light | `#D4A8A3` | Subtle tertiary |

### Swipe Colors

| Token | Hex | Usage |
|-------|-----|-------|
| Swipe Yes | `#4ADE80` | Green overlay when swiping right |
| Swipe No | `#F87171` | Red overlay when swiping left |
| Swipe Skip | `#A78BFA` | Purple overlay when swiping up |

### Typography

| Role | Font | Weight | Size (Desktop) | Size (Mobile) |
|------|------|--------|----------------|---------------|
| Display | Playfair Display | 700-900 | 6rem-9rem | 3rem-5rem |
| Heading 1 | Playfair Display | 700 | 3rem | 2rem |
| Heading 2 | Playfair Display | 600 | 2rem | 1.5rem |
| Heading 3 | Playfair Display | 500 | 1.25rem | 1.125rem |
| Body | Inter | 400 | 1rem | 0.875rem |
| Body Small | Inter | 400 | 0.875rem | 0.8125rem |
| Label | Inter | 500-600 | 0.875rem | 0.8125rem |
| Mono | JetBrains Mono / system mono | 400 | 0.875rem | 0.8125rem |

### Spacing

- Base unit: 8px
- Section padding (vertical): 120-200px (desktop), 64-96px (mobile)
- Content max-width: 1280px
- Card padding: 24-32px
- Element gap: 8-24px

### Border Radius

| Element | Radius |
|---------|--------|
| Cards | 16px (rounded-xl) |
| Buttons | 9999px (pill / rounded-full) |
| Inputs | 12px (rounded-lg) |
| Avatars | 9999px (circle) |
| Modals | 24px (rounded-2xl) |

### Shadows

- Card: `0 4px 24px rgba(0, 0, 0, 0.08)` (light), `0 4px 24px rgba(0, 0, 0, 0.4)` (dark)
- Elevated: `0 8px 40px rgba(0, 0, 0, 0.12)` (light), `0 8px 40px rgba(0, 0, 0, 0.6)` (dark)
- Glow (amber CTA): `0 0 40px rgba(212, 168, 83, 0.3)`

---

## Component Inventory

### Buttons

| Variant | Background | Text | Border |
|---------|-----------|------|--------|
| Primary | Amber | Jet | None |
| Secondary | Transparent | Amber | 1px amber |
| Ghost | Transparent | Ivory/Jet | None |
| Danger | Rose | White | None |

All buttons are pill-shaped (`rounded-full`), with `px-6 py-3` default padding. Hover: scale 1.02 + subtle glow. Active: scale 0.98.

### Cards

- **App Card**: Icon + name + description + subscriber count. Rounded-xl, hover lift effect.
- **Swipe Card**: Full-height stack with spring physics drag. Shows icon, title, subtitle, description. Green/red/purple tint on directional drag.
- **Glass Card**: `backdrop-blur(24px)` + subtle white/black border. Used for testimonials, stats.
- **Decision Card**: Compact list item with decision badge (yes=green, no=rose, skip=purple), timestamp, time-to-decision.

### Navigation

- **Landing**: Fixed top bar, transparent → glassmorphic on scroll
- **App (Desktop)**: Collapsible left sidebar (64px collapsed, 256px expanded)
- **App (Mobile)**: Bottom tab navigation, 5 items max

### Forms

- Inputs: Full-width, rounded-lg, subtle border, focus ring in amber
- Labels: Above input, small uppercase tracking
- Toggles: Custom switch with amber active color
- Selects: Dropdown with amber focus ring

### Badges

| Type | Background | Text |
|------|-----------|------|
| Yes | Green/10% | Green |
| No | Rose/10% | Rose |
| Skip | Purple/10% | Purple |
| Public | Amber/10% | Amber |
| Private | Gray/10% | Gray |

---

## Animation Principles

1. **Entrance**: Fade-up with 40px translate, 0.8s ease-out. Stagger 150ms between siblings.
2. **Hover**: Scale 1.02, 0.2s ease. Add subtle shadow lift.
3. **Press**: Scale 0.98, 0.1s ease.
4. **Page transitions**: Fade 0.3s.
5. **Swipe physics**: Spring-based drag with rotation proportional to horizontal displacement. Velocity-aware fling.
6. **Scroll reveal**: IntersectionObserver with threshold 0.15, one-shot (no exit animation).

---

## Accessibility Standards

- Minimum contrast ratio: 4.5:1 for body text, 3:1 for large text
- Focus indicators: 2px amber ring offset
- Touch targets: minimum 44x44px
- Keyboard navigation: all interactive elements focusable
- Screen reader: meaningful alt text, aria labels, semantic HTML
- Reduced motion: respect `prefers-reduced-motion`, disable parallax and entrance animations
- Color: never convey meaning through color alone (always pair with icon or text)

---

## Responsive Breakpoints

| Breakpoint | Width | Layout |
|------------|-------|--------|
| Mobile | < 640px | Single column, bottom nav, stacked cards |
| Tablet | 640-1024px | Two column where appropriate, bottom nav |
| Desktop | 1024-1280px | Sidebar nav, multi-column layouts |
| Large | > 1280px | Max-width container, generous whitespace |

---

## Dark/Light Mode

- Default: Dark mode
- Toggle: Available in settings and app header
- Storage: `localStorage` key `janee-theme`
- System: Respect `prefers-color-scheme` on first visit
- Transition: 0.3s ease on background-color and color

### Dark Mode Specifics
- Backgrounds: jet → jet-light → jet-lighter (elevation)
- Text: ivory (primary) → ivory/70 (secondary) → ivory/40 (tertiary)
- Borders: ivory/5 → ivory/10

### Light Mode Specifics
- Backgrounds: ivory → white → ivory-dark (elevation)
- Text: jet (primary) → jet/70 (secondary) → jet/40 (tertiary)
- Borders: jet/5 → jet/10

---

## Image Prompts for Visual Assets

### Hero Background
"Abstract editorial gradient, dark to warm amber, subtle film grain texture, cinematic quality, high-end luxury feel, 4K resolution, dark moody atmosphere with golden light"

### Use Case Illustrations
"Minimalist line-art illustration of [movie reel / wedding rings / briefcase / robot], single amber accent color on dark background, editorial luxury style, clean geometric"

### Profile Placeholder
"Minimalist geometric avatar, amber and ivory tones, editorial luxury style, no text, abstract human silhouette"
