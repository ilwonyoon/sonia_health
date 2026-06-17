# Information Architecture

## 1. Navigation model

Primary navigation is a **persistent glass bottom tab bar** with **5 destinations**.
It is visible across almost every screen (hidden only during full-screen voice
calls and modal assessments).

```
┌─────────────────────────────────────────────┐
│                                               │
│                 (screen body)                 │
│                                               │
├───────────────────────────────────────────── ┤
│  📞 Phone   💬 Chat   📖 Content   👤 You   ⚙ Settings │
└─────────────────────────────────────────────┘
```

| Tab | Icon | Purpose | Evidence |
|-----|------|---------|----------|
| **Phone** | handset | Live **voice session** with Michelle | IMG_3383, IMG_3384 |
| **Chat** | speech bubble | Asynchronous **message timeline** w/ Michelle (voice notes + text) | IMG_3382 |
| **Content** | open book | **Routines hub** — Morning/Evening/Wellbeing/Affirmation | IMG_3369–3381, 3385 |
| **You** | person | Profile / progress (seeds, streaks) — *not captured* | tab visible in all bars |
| **Settings** | gear | App settings — *not captured* | tab visible in all bars |

The active tab is shown with a **highlighted pill** behind the icon+label
(see Content active in IMG_3369, Chat active in IMG_3382, Phone active in IMG_3383).

## 2. Top-level routes (from code)

`Routing/AppRoute.swift` currently defines: `splash`, `onboarding`, `home`,
`session`, `history`, `settings`. The 5-tab IA above is the **runtime home
shell**; `session` maps to **Phone**, `history` likely backs **You/Chat**.
> Gap: the tab IA (Phone/Chat/Content/You/Settings) is not yet a 1:1 match with
> `AppRoute`. See code-gap-analysis.

## 3. Content tab — routine flows

The Content tab is a hub that launches four routine types. Each routine is a
self-contained flow.

### 3.1 Morning Intention  (gold/amber theme ☀)
```
Content
  └─ Morning Intention
       ├─ Q1  "How are you feeling right now…"      (IMG_3369 / typing 3371)
       ├─ Q2  "…what do you want to stay focused…"  (IMG_3372)   [Previous｜Continue]
       ├─ Q3  "When Kai gets loud…"                 (IMG_3373)   [Previous｜Complete ✓]
       ├─ Loading  "Reading your responses…" ☀      (IMG_3374)
       └─ Result  "Calm First"                      (IMG_3375 / 3376)
            • AI "Your Reflection" card
            • Reward badge  "+50 seeds"
            • Pull-quote card (italic serif)
            • [Done] full-width CTA
```
- 3 questions, **segmented progress bar** (one segment per question).
- Each question = free-text journaling with **text input + voice (mic) input**.
- Footer buttons evolve: `Continue` → `Previous|Continue` → `Previous|Complete ✓`.

### 3.2 Evening Reflection  (lilac/lavender theme 🌙)
```
Content
  └─ Evening Reflection
       ├─ Q1  "How are you feeling tonight…"   (IMG_3377)
       ├─ Q2  "Was there a moment today…"      (IMG_3378)   [Previous｜Continue]
       ├─ Loading  "Reading your responses…" 🌙 (IMG_3379)
       └─ Result  (analogous to Morning, lilac-themed)
```
Structurally identical to Morning Intention; **only the accent color and icon
change** (moon + lilac vs. sun + gold). This is the core theming insight.

### 3.3 Wellbeing check-in  (assessment / lighter theme ♡)
```
Content
  └─ Wellbeing  (modal, dismissible via ✕)
       ├─ 1 of 5  "I have felt cheerful and in good spirits"  (IMG_3380)
       ├─ …       "I have felt calm and relaxed"              (IMG_3381)
       └─ 5 of 5  → results
```
- WHO-5-style instrument: **statement + slider** ("At no time" ↔ "All of the time").
- Continuous **thin progress bar** (not segmented).
- Distinct visual treatment: larger type, cream-filled slider, **white/solid CTA**,
  pill header `♡ Wellbeing · 1 of 5`, `✕` close (a *task* not a *tab context*).

### 3.4 Daily Affirmation  (read-only)
```
Content
  └─ Daily Affirmation  (IMG_3385)
       ├─ chip  "✦ Daily Affirmation"
       ├─ title + date  "Monday, Jun 15 at 3:01 PM"
       ├─ card  "Today's Affirmation"
       └─ card  "Michelle's Note"
```
Passive content surface — no input, just two stacked cards.

## 4. Phone tab — voice session flow
```
Phone
  ├─ Pre-session  (IMG_3383)
  │    • photographic background (flower field)
  │    • Michelle avatar + name chip
  │    • user pull-quote  "I want them to think of me as someone you can always trust." — You
  │    └─ [→ Slide to start session]   (slide-to-confirm control)
  └─ In-session  (IMG_3384)
       • full-bleed background, dynamic-island active
       • live **caption** at bottom (word-by-word highlight)
       • right-rail glass controls: touch / message / share / settings
       • pause control (top-right)
```

## 5. Chat tab — message timeline
```
Chat  (IMG_3382)
  • photographic background
  • Michelle avatar + name chip pinned top
  • day separators  "Wednesday 8:00 PM" / "Today 12:05 PM"
  • voice-note bubbles each with  ▶ Play
  • composer  [ + | Message…………… 🎤 ]
```

## 6. Cross-cutting IA notes

- **Two interaction registers**: *companion* (Phone/Chat, photographic, intimate)
  vs. *guided practice* (Content routines, dark editorial cards).
- **Reward economy**: "seeds" (e.g. `+50 seeds`) granted on routine completion →
  surfaced in the **You** tab (inferred).
- **Time-of-day theming** is a first-class IA dimension (morning gold ↔ evening lilac).
- **Named third parties** appear in prompts ("Kai", "Ray", "Michelle") → the app
  personalizes questions to the user's real relationships/context.
