# Code Gap Analysis — Screenshots vs. current `SR*` system

Comparison of the design extracted from screenshots against the current Swift
code under `DesignSystem/` and `Routing/`. Ordered by impact.

## 🔴 High impact — visual identity divergence

### 1. Brand color: teal/evergreen (code) vs. gold + lilac (screenshots)
- `SRColor.brandAccent/brandAction` = **teal** (`#2BC99A`/`#4AE8C2`).
- `SRRoutineHeroPalette` = evergreen/rosewood/steelBlue/… **earth tones**.
- Screenshots use **gold/amber** (morning, CTA) and **lilac** (evening) — no teal anywhere.
- **Action**: introduce `accent/morning` (gold), `accent/evening` (lilac),
  `accent/assessment` (white/cream), `accent/reward` (seed green). Decide whether
  teal is deprecated or reserved for an unseen surface.

### 2. Typography: all sans (code) vs. serif/sans split (screenshots)
- `SRTextStyle` uses `design: .default` (sans) for every style; max size 28.
- Screenshots show a **serif display layer** (questions, "Calm First", quotes,
  nav titles) over **sans body/UI**, with a **32pt** display tier.
- **Action**: add serif styles (`display`, `questionTitle`, `quote` italic,
  `navTitleSerif`) and an `eyebrow` uppercase+tracking style.

## 🟠 Medium impact — IA / structure

### 3. Tab IA not represented in `AppRoute`
- Screenshots: 5-tab shell **Phone · Chat · Content · You · Settings**.
- `AppRoute` = `splash, onboarding, home, session, history, settings` (no tab model).
- **Action**: model the 5 tabs explicitly (e.g. `enum HomeTab`), map
  `session→Phone`, define `Chat`, `Content`, `You`.

### 4. Theme keyed by UUID hash vs. flow/time semantics
- `SRRoutineHeroPalette.assigned(to: UUID)` picks palette by hashing routine ID.
- Screenshots imply **semantic** theming (morning=gold, evening=lilac, assessment=white).
- **Action**: add semantic themes + select by flow/time-of-day. Keep the rotation
  helper for any list/variety use-cases.

## 🟡 Components to build (missing)
| Component | Screens | Notes |
|-----------|---------|-------|
| Journaling field (text + mic) | 3369–3378 | rounded field, trailing mic, placeholder |
| Assessment slider | 3380–3381 | track+thumb, end labels, value label, cream fill |
| Slide-to-start control | 3383 | pill + draggable thumb |
| Chat composer | 3382 | + / field / mic |
| Live caption | 3384 | word-highlight transcript over photo |
| Companion header (avatar+name chip) | 3382–3384 | over-photo glass |
| Photo surface + scrim | 3382–3384 | full-bleed bg with gradient |

## 🟢 Already aligned (keep)
- **Spacing** `SRSpacing` (8pt grid) — matches.
- **Radius** `SRRadius` (card 20, surface 28, pill) — matches.
- **Glass material** `SRGlassContainer`, `SRBottomBarGlass`, `SRGlassIconButton` — matches.
- **Card/Surface/Badge/ProgressBar/Icon/Text** primitives exist — extend, don't rebuild.
- **Hero palette rotation pattern** — good mechanism, retune colors + keying.

## Suggested sequencing (when moving to code)
1. Foundations: add serif type styles + gold/lilac/cream/seed accents.
2. Theme: semantic `Theme` enum + accent injection into `SRButton`/`SRProgressBar`.
3. Build missing input components (journaling field, slider, composer).
4. Build companion surfaces (photo+scrim, header, live caption, slide-to-start).
5. Reconcile IA: 5-tab shell + map routes.
