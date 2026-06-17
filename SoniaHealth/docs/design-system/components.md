# Design System — Component Catalog

Each entry: anatomy, variants/states, the screenshots it appears in, and the
mapped `SR*` Swift component (✅ exists / ⚠ partial / ❌ missing).

## Navigation

### Bottom Tab Bar  → `SRBottomBarGlass` ✅
- **Anatomy**: glass capsule, 5 items (icon + label), active item = filled pill behind.
- **States**: active / inactive; **accent-tinted** variant (gold tint on Morning result, IMG_3375).
- Seen: every non-fullscreen screen.

### Page Header  → `SRPageHeader` ✅ / `SRSplitHeader` ✅
- Circular **back button** (glass) + centered serif title (IMG_3369).
- Title-only variant (centered, no back) on loading screens (IMG_3374).
- **Companion header** variant: centered avatar + name chip (IMG_3382–3384) — may need `SRNavigationGlass`.

## Inputs

### Journaling Field (text + voice) → ❌ missing
- **Anatomy**: rounded `bg/inputField` box, placeholder "Type your response…", trailing **mic** glyph.
- **States**: empty (placeholder) / focused (caret) / filled.
- Seen: IMG_3369, 3371, 3372, 3373, 3377, 3378.

### Slider (assessment) → ❌ missing
- **Anatomy**: track + circular thumb, end labels ("At no time" / "All of the time"),
  dynamic value label above ("More than half").
- **States**: cream-filled proportional to value (IMG_3381); neutral centered default (IMG_3380).
- Seen: Wellbeing flow only.

### Slide-to-start control → ❌ missing
- Pill track + leading circular `→` thumb, "Slide to start session" (IMG_3383).

### Chat composer → ❌ missing
- `+` attach, expanding `Message…` field, trailing `🎤` mic (IMG_3382).

## Actions

### Button  → `SRButton` ⚠ (needs accent + serif/variant audit)
- **Primary pill**, full-width or trailing-aligned. Accent-colored fill, dark label.
  - gold (Morning), lilac (Evening), white/solid (Assessment).
- **Secondary / text**: `< Previous` (plain text + chevron).
- **Variants by label**: `Continue >`, `Complete ✓`, `Done` (full-width), `Continue` (disabled grey).
- **States**: enabled / disabled (grey, IMG_3369 & 3380) / pressed.
- Seen: all routine + assessment screens.

### Glass Icon Button  → `SRGlassIconButton` ✅
- Round translucent control. Voice rail: touch / message / share / settings; pause (IMG_3384).

## Containers & Surfaces

### Card  → `SRCard` ✅ / `SRSurface` ✅
- Reflection card ("Your Reflection" + icon label + body, IMG_3375).
- Quote card (centered italic serif + `❝ ❞`, IMG_3375/3376).
- Affirmation cards ("Today's Affirmation", "Michelle's Note", IMG_3385).
- Assessment statement card (eyebrow + big serif + slider, IMG_3380).

### Glass Container  → `SRGlassContainer` ✅
- Tab bar, voice rail, name chips, composer background.

### Vertical Scroll Host → `SRVerticalScrollHost` ✅
- Result screens scroll to reveal `Done` (IMG_3375 → 3376).

## Feedback & Status

### Progress Bar  → `SRProgressBar` ⚠
- **Segmented** variant: N segments = N questions, accent fill (IMG_3369/3372/3373, lilac in 3377/3378).
- **Continuous** thin variant for assessment (IMG_3380/3381).
- > Confirm both modes are supported.

### Badge / Chip  → `SRBadge` ✅
- **Reward**: green `+50 seeds` w/ leaf (IMG_3375).
- **Context pill**: `♡ Wellbeing · 1 of 5` (IMG_3380), `✦ Daily Affirmation` (IMG_3385).
- **Name chip**: "Michelle" / "You" over photo (IMG_3382–3384).

### Eyebrow / Step indicator → part of header pattern
- Icon + "Question 1 of 3" (sun/moon), uppercase tracked label (IMG_3369/3377).

### Loading state → ⚠ (compose from `SRIcon` + `SRText`)
- Centered themed medallion (sun / moon+stars) + status line "Reading your responses…".

### Live Caption → ❌ missing
- Bottom-anchored word-by-word highlighted transcript over video/photo (IMG_3384).

### Toast → `SRToast` ✅ (not seen in captures)

## Icon  → `SRIcon` ✅
Sun, moon, stars, sparkle, heart, document, play, mic, chevrons, tab glyphs.

---

## Component gap summary
| Need | Status |
|------|--------|
| Journaling field (text+mic) | ❌ build |
| Assessment slider | ❌ build |
| Slide-to-start | ❌ build |
| Chat composer | ❌ build |
| Live caption | ❌ build |
| Button accent-injection + variants | ⚠ extend |
| Progress bar segmented+continuous | ⚠ verify |
| Companion header (avatar+name) | ⚠ verify |
