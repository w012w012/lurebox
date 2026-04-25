# LureBox Design System

> Inspired by Tesla's design language — radical minimalism, photography-first, single accent color.

## 1. Design Philosophy

- Full-bleed content sections, minimal UI decoration
- Near-zero chrome: no shadows, no gradients, no borders on cards
- Single accent color — Electric Blue (`#3E6AE1`) — for all CTAs
- Photography and data visualization carry the emotional weight
- 0.33s cubic-bezier transitions as universal timing

## 2. Color Palette

### Primary
- **Electric Blue** (`#3E6AE1`): Primary CTA and accent actions
- **Pure White** (`#FFFFFF`): Surface and background

### Surface & Background
- **White Canvas** (`#FFFFFF`): Primary surface
- **Light Ash** (`#F4F4F4`): Alternate surface for section differentiation
- **Carbon Dark** (`#171A20`): Dark surface / hero text overlays
- **Frosted Glass** (`rgba(255, 255, 255, 0.75)`): Semi-transparent nav backdrop

### Neutrals & Text
- **Carbon Dark** (`#171A20`): Primary headings and navigation
- **Graphite** (`#393C41`): Body text
- **Pewter** (`#5C5E62`): Tertiary text and sub-links
- **Silver Fog** (`#8E8E8E`): Placeholder text and disabled states
- **Cloud Gray** (`#EEEEEE`): Light borders and dividers
- **Pale Silver** (`#D0D1D2`): Subtle UI borders

### Semantic
- `AppColors.gold/silver/bronze` — trophy/achievement colors
- `AppColors.release` (green) / `AppColors.keep` (orange) — fish fate indicators
- No gradients; depth via photography, whitespace, and opacity

## 3. Typography

### Font System
- Display + Text variant split (geometric sans-serif)
- Display: hero titles, large headings (40px, w500)
- Text: UI, body, buttons (14px, w400 body / w500 UI)

### Hierarchy

| Role | Size | Weight | Notes |
|------|------|--------|-------|
| Hero Title | 40px | 500 | Display variant, on dark backgrounds |
| Product Name | 17px | 500 | Model/feature names |
| Nav Item | 14px | 500 | Navigation labels |
| Body Text | 14px | 400 | Paragraph content |
| Button Label | 14px | 500 | CTA text |
| Promo Text | 22px | 400 | Highlight text |

### Principles
- Only weights 400 and 500 — no bold, no light
- Default letter-spacing everywhere
- No text transforms (no uppercase)
- Maximum 40px for web text

## 4. Spacing & Layout

- **Base unit**: 8px
- **Button padding**: 4px outer, content-centered
- **Card radius**: 12px
- **Button radius**: 4px
- **Content max-width**: ~1383px

### Whitespace
- Generous vertical spacing between sections
- Spacing as luxury signal — never fill space just because it's empty
- One message per section/viewport

## 5. Depth & Elevation

| Level | Treatment | Use |
|-------|-----------|-----|
| Level 0 | No shadow, no border | Default state |
| Level 1 | `rgba(255,255,255,0.75)` backdrop | Nav bar on scroll |
| Level 2 | `rgba(128,128,128,0.65)` | Modal overlays |
| Level 3 | `rgba(0,0,0,0.05)` | Rare hover hints |

No box-shadows in primary UI. Depth via z-index, opacity, and photography.

## 6. Border Radius Scale

| Value | Context |
|-------|---------|
| 0px | Default — sharp edges |
| 4px | Buttons — barely perceptible rounding |
| ~12px | Cards — restrained rounding on larger surfaces |
| 50% | Dot indicators — perfect circles |

## 7. Do's and Don'ts

### Do
- Let content dominate — the product IS the design
- Use Electric Blue exclusively for primary CTAs
- Keep typography at 400-500 only
- Use 4px border-radius for interactive elements
- Trust whitespace as a luxury signal
- Maintain 0.33s transition consistency

### Don't
- Add shadows to elements
- Use more than one chromatic color
- Apply gradients or decorative backgrounds
- Use uppercase text transforms
- Introduce pill buttons or large border-radii
- Add hover animations with scale/translate transforms
- Clutter the viewport with multiple CTAs

## 8. Responsive Behavior

| Breakpoint | Width | Key Changes |
|------------|-------|-------------|
| Mobile | <768px | Single-column, hamburger nav, hero ~28px, CTAs stack |
| Tablet | 768-1024px | 2-column layout, reduced padding |
| Desktop | 1024-1440px | Full nav, 3-column grids, side-by-side CTAs |
| Large | >1440px | Content centered, photography scales |

## 9. Agent Prompt Guide

### Quick Color Reference
- Primary CTA: "Electric Blue (#3E6AE1)"
- Background: "Pure White (#FFFFFF)"
- Heading text: "Carbon Dark (#171A20)"
- Body text: "Graphite (#393C41)"
- Tertiary text: "Pewter (#5C5E62)"
- Placeholder: "Silver Fog (#8E8E8E)"
- Alternate surface: "Light Ash (#F4F4F4)"
- Dark surface: "Carbon Dark (#171A20)"

### Iteration Guide
1. Focus on ONE component at a time — each element must be pixel-perfect
2. Reference specific color names and hex codes — only 6-7 colors in the system
3. Use natural language descriptions alongside measurements
4. Verify that content does the emotional heavy-lifting — if the UI itself feels "designed," it's too much
