# Design System — Foundations

> Hex values are visually sampled from screenshots → **approximate**. Treat as a
> starting palette to confirm against design source. The token *names* and
> *relationships* are the durable part.

## 1. Color

### 1.1 Neutrals (dark canvas)
| Token | Approx hex | Usage |
|-------|-----------|-------|
| `bg/canvas` | `#0E0E10` | App background (near-black charcoal) |
| `bg/surface` | `#1A1A1D` | Cards, reflection blocks |
| `bg/surfaceElevated` | `#222227` | Input fields, raised cards |
| `bg/inputField` | `#2A2A2E` | Text entry field |
| `border/hairline` | `rgba(255,255,255,0.07)` | Card & divider edges |

### 1.2 Text
| Token | Approx hex | Usage |
|-------|-----------|-------|
| `text/primary` | `#F4F2ED` | Titles, body (warm off-white) |
| `text/secondary` | `#9C9C9F` | Eyebrows, captions, helper |
| `text/tertiary` | `#6A6A6E` | Placeholder, disabled |
| `text/onAccent` | `#1A1407` | Text on gold/white CTA (dark) |

### 1.3 Accents — time-of-day system (KEY)
| Token | Approx hex | Used by |
|-------|-----------|---------|
| `accent/morning` (gold/amber) | `#C9A24B` → `#D6B25E` | Morning Intention, Content, primary CTA |
| `accent/evening` (lilac) | `#B7A9D6` → `#C6BAE2` | Evening Reflection |
| `accent/assessment` (white/cream) | `#FFFFFF` / track `#E7E0CF` | Wellbeing survey CTA + slider |
| `accent/reward` (seed green) | `#3E9C6B` on `rgba(62,156,107,0.18)` | `+50 seeds` badge |

> **The accent is a runtime variable keyed to context (time of day / flow type),
> not a fixed brand color.** Components must accept an injected accent.

### 1.4 Photographic / companion surfaces
Phone & Chat use **full-bleed photography** (flower field, misty meadow) with a
dark gradient scrim for legibility. Foreground uses translucent **glass** chips
and `text/onPhoto` = `#FFFFFF` at 88–100% opacity.

## 2. Typography

**Two families, intentionally split:**

| Role | Family | Why |
|------|--------|-----|
| **Display / Headings / Quotes** | **Serif** (transitional, New York / Newsreader-like) | Editorial, calm, human voice |
| **Body / UI / Labels** | **Sans-serif** (SF Pro / system) | Legibility, controls |

### Type scale (estimated, pt)
| Token | Size / weight | Family | Example |
|-------|---------------|--------|---------|
| `display` | 32 / bold | serif | "Calm First", "Daily Affirmation" |
| `questionTitle` | 26–28 / regular | serif | routine questions |
| `assessmentStatement` | 28 / medium | serif | "I have felt cheerful…" |
| `quote` | 20 / regular **italic** | serif | pull-quotes |
| `navTitle` | 17 / semibold | serif | "Morning Intention" header |
| `body` | 16 / regular | sans | reflection paragraph |
| `label` | 14 / medium | sans | button text, field labels |
| `eyebrow` | 12 / medium, **+UPPERCASE, tracking ~+8%** | sans | "OVER THE LAST 2 WEEKS", "Question 1 of 3" |
| `tabLabel` | 11 / regular | sans | Phone/Chat/Content/You/Settings |

> Current code (`SRTextStyle`) uses `design: .default` (sans) everywhere and tops
> out at 28pt. The serif display layer and 32pt tier are **missing** — see gap doc.

## 3. Spacing — 8pt grid
Matches existing `SRSpacing` (keep as-is): `2, 4, 8, 10, 12, 16, 20, 24, 32`.
| Semantic | Value |
|----------|-------|
| Screen horizontal padding | 20–24 |
| Card padding | 16 |
| Section gap | 24 |
| Label → input | 8 |
| Footer button inset from bottom | 24–32 (above tab bar) |

## 4. Radius — matches existing `SRRadius`
| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 4 | — |
| `lg` | 12 | small chips |
| `xl` (thumbnail) | 16 | input field, small cards |
| `xxl` (card) | 20 | reflection/quote/affirmation cards |
| `xxxl` (surface) | 28 | large surfaces, sheets |
| `pill` (control) | ∞ | buttons, badges, tab highlight, name chips |

## 5. Elevation & material
- **Glass / blur**: bottom tab bar, voice control rail, name chips, composer.
  Translucent dark with subtle white hairline border + soft shadow.
- **Cards**: flat fill (`bg/surface`) + 1px hairline border, minimal shadow.
- **Scrims**: linear dark gradient over photos (top + bottom) for text contrast.

## 6. Iconography
- Line icons, ~1.5–2px stroke, rounded.
- Time-of-day motifs: ☀ sun (morning), 🌙+✨ moon (evening), ✦ sparkle (affirmation),
  ♡ heart (wellbeing), 📄 document (loading/notes).
- Tab icons: handset, speech-bubble, open-book, person, gear.
- Inline glyphs: ▶ play (voice notes), 🎤 mic (input), arrows for nav.
