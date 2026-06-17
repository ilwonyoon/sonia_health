# Handoff & Work Instructions — Design System Implementation

**For:** the agent continuing on `main`.
**From:** IA / design-system extraction session (2026-06-16).
**Goal:** turn the extracted design docs into working `SR*` code that matches the
product screenshots.

---

## 0. Read first (in this order)
1. [`design-system/code-gap-analysis.md`](design-system/code-gap-analysis.md) — **start here**; it is the work backlog.
2. [`design-system/foundations.md`](design-system/foundations.md) — color/type/spacing/radius targets.
3. [`design-system/themes.md`](design-system/themes.md) — the morning/evening/assessment/companion theme model.
4. [`design-system/components.md`](design-system/components.md) — component catalog + ✅/⚠/❌ status.
5. [`information-architecture.md`](information-architecture.md) + [`screen-inventory.md`](screen-inventory.md) — IA & screen states.

## 1. What is already done
- 16 screenshots analyzed → IA map, screen inventory, design-system spec (7 docs in `docs/`).
- API keys (`Config/Secrets.xcconfig`) set up + verified; gitignored (defense-in-depth `Config/.gitignore` added). **Do not commit secrets.**
- Xcode plumbing verified: `Secrets.xcconfig` → Info.plist `$()` → `Bundle.main` → `CartesiaConfig.swift:16`.

## 2. The one critical finding
**Current code does not match the screenshots.** Two big divergences:
1. **Brand color**: code = teal/evergreen (`SRColor.brandAccent/Action`, `SRRoutineHeroPalette`); screenshots = **gold (morning) + lilac (evening) + white/cream (assessment)**. No teal anywhere in the UI.
2. **Typography**: code = all sans (`SRTextStyle`, `design: .default`, max 28pt); screenshots = **serif headlines + sans body**, with a 32pt display tier.

Everything else (spacing, radius, glass material) already aligns — extend, don't rebuild.

## 3. Work plan (priority order — from code-gap-analysis)

### P0 — Foundations (unblocks everything)
- [ ] `DesignSystem/Tokens/SRColor.swift` — add semantic accents: `accentMorning` (gold ≈ `#C9A24B`), `accentEvening` (lilac ≈ `#B7A9D6`), `accentAssessment` (white/cream track ≈ `#E7E0CF`), `accentReward` (seed green ≈ `#3E9C6B`). Decide fate of teal tokens (deprecate or reserve).
- [ ] `DesignSystem/Tokens/SRTextStyle.swift` — add serif styles: `display` (32 serif bold), `questionTitle` (26–28 serif), `quote` (20 serif italic), `navTitleSerif` (17 serif); add `eyebrow` (12 sans, uppercase, tracking ~+8%). Use `design: .serif` (or a bundled face — see Open Questions).

### P1 — Theme system
- [ ] Add a semantic `Theme` (`morning | evening | assessment | companion`) carrying `{accent, accentOnText, icon, surfaceStyle, progressStyle, titleFont}` — see themes.md "Theme contract".
- [ ] Reuse the `SRRoutineHeroPalette` *pattern* but retune to gold/lilac/cream and **key by flow/time-of-day**, not UUID hash.
- [ ] Inject accent into `SRButton` and `SRProgressBar` (remove hardcoded brand color).

### P2 — Missing components (build)
- [ ] Journaling field (text + trailing mic) — screens 3369–3378
- [ ] Assessment slider (track+thumb, end labels, value label, cream fill) — 3380–3381
- [ ] Slide-to-start control — 3383
- [ ] Chat composer (`+` / field / mic) — 3382
- [ ] Live caption (word-highlight transcript over photo) — 3384
- [ ] Companion header (avatar + name chip over photo) — 3382–3384
- [ ] Photo surface + gradient scrim — 3382–3384

### P3 — IA reconciliation
- [ ] Model the 5-tab shell explicitly (Phone · Chat · Content · You · Settings). Current `Routing/AppRoute.swift` (`splash/onboarding/home/session/history/settings`) has no tab model. Map `session→Phone`, define `Chat`, `Content`, `You`.

## 4. Constraints & rules (important)
- **Shared working directory.** Multiple agents work in `/Users/ilwonyoon/Documents/Sonia_health` concurrently.
  - **NEVER `git add -A` / `git add .`** — scope adds to the files you authored. (A prior `git add -A` here leaked API keys + swept other agents' in-progress code into one commit.)
  - Before any git op: `git check-ignore` any `*Secret*`/`.env`/`.xcconfig` and confirm not staged.
- **Coding style** (user's global rules): immutable patterns (no mutation), small focused files (200–400 lines), comprehensive error handling, validate input, no `console.log`/`print` debris, no hardcoded values.
- **Hex values in docs are visually sampled approximations** — confirm against the real design source before locking tokens.

## 5. Open questions (need a decision)
1. **Serif font**: use system `.serif` (New York) or bundle a specific face (e.g. Newsreader/Lora)? Affects licensing + look.
2. **Teal tokens**: deprecate entirely, or keep for an unseen surface?
3. **Exact hex**: are the doc approximations acceptable, or is there a Figma/source to sample exact values?
4. **Assessment theme**: the Wellbeing flow uses a lighter treatment + white solid CTA — is it a full theme or just a flow-local style?

## 6. Done criteria
- A screen rendered from current code visually matches its screenshot (color, type, spacing) for: Morning Q (3369), Morning result (3375), Evening Q (3377), Wellbeing (3380–81).
- All four themes switch correctly by context.
- No teal visible unless explicitly decided to keep.
- Build runs; voice session (Phone tab) authenticates with the new keys.
