# CLAUDE.md — Sonia Health

Operating guide for AI agents working in this repo. Read this first; see `README.md`
for the full stack and file map, and `SoniaHealth/docs/` for IA, screens, and design system.

> **What this is:** an AI **voice-centric therapist** iOS app (SwiftUI, iOS 18+).
> Cartesia for real-time speech (STT + TTS), Anthropic Claude for the therapist turn,
> design system ported from SaveReset (`SR*` liquid-glass components).

---

## Operating principles (Karpathy's four rules)

Adapted from Andrej Karpathy's observations on LLM coding pitfalls
([source](https://github.com/multica-ai/andrej-karpathy-skills)). These override the urge to do more.

1. **Think before coding.** Don't assume, don't hide confusion, surface tradeoffs.
   If a request is ambiguous, state your interpretation (or present the options) and
   ask *before* implementing — not after discovering the mistake. This repo is worked
   on by several people/agents at once, so a wrong guess is expensive.
2. **Simplicity first.** Write the minimum code that solves the stated problem. No
   speculative features, single-use abstractions, or error handling for cases that
   can't happen. Prototype-stage: prefer the direct solution.
3. **Surgical changes.** Touch only what the task requires. Preserve existing style;
   don't refactor working code you weren't asked to. Clean up only the mess your own
   change created.
4. **Goal-driven execution.** Turn vague asks into testable success criteria, then
   loop until verified (build it, run it, decode it) instead of declaring done by
   inspection. See "Verification" below.

---

## Git & collaboration (READ — non-obvious, has bitten us)

**Multiple Claude panels work this same repo and the same local `main` concurrently.**

- **NEVER `git add -A` / `git add .`.** Stage only the specific files *you* authored
  (explicit paths). A blanket add here once (a) swept other agents' in-progress work
  into a commit and (b) leaked real API keys. Run `git ls-files <path>` before assuming
  a file is untracked — a sibling commit may already include it.
- **Secrets:** `SoniaHealth/Config/Secrets.xcconfig` is the **single source of truth**
  for the `CARTESIA_API_KEY` / `ANTHROPIC_API_KEY` (gitignored, injected into Info.plist
  at build). Tooling reads the key from it too — e.g. `scripts/cartesia-voices.sh` lists
  the Cartesia voice catalog using this same key, so there is **no separate `.env`** to
  keep in sync. Update the key in this one file only. Before any commit, `git check-ignore`
  anything matching `*Secret*`, `.env`, `*.xcconfig`. Never commit keys. Only
  `Secrets.example.xcconfig` (empty template) is tracked.
- **Flow:** the team pushes directly to `main` (shared local working copy makes PRs
  awkward to retrofit). Direct `git push origin main` is the accepted flow; PRs optional.
- **Commit messages:** brief summary + timestamp `DD/MM/YY - HH:MM:SS`, conventional
  type prefix (`feat`/`fix`/`docs`/`refactor`/`chore`). Attribution is disabled globally
  (no Co-Authored-By line). Commit after each coherent unit of work.
- **Confirm first** for irreversible history ops: force-push, rebasing shared branches,
  `reset --hard` when others have uncommitted changes, or deleting `.git`.

---

## Build & project structure

- **XcodeGen** owns the project. `project.yml` globs the whole `SoniaHealth/` folder,
  so new files under it are picked up automatically — but you must run
  `xcodegen generate` to regenerate `.xcodeproj` after adding/moving files.
- `.xcodeproj`, `build/`, `DerivedData/` are gitignored; don't commit them.
- Layout (details in `README.md`): `App/` entry · `Routing/` central router ·
  `DesignSystem/` (`Tokens` → `Theme` → `Foundation` → `Components`) ·
  `Voice/` speech pipeline · `Features/` screens · `Models/` data · `Resources/`.

## Swift conventions

- **Design system uses the `SR` prefix** (`SRButton`, `SRPageHeader`, `SRColor`…).
  Reuse these before introducing new UI primitives; the look is liquid-glass, ported
  from SaveReset.
- **Immutability:** build new values, don't mutate (`struct` + `let`, return copies).
  Keep files focused (~200–400 lines; extract when large).
- Models are `Codable` with **camelCase keys matching the JSON** (no custom CodingKeys
  needed). Dates are ISO-8601 strings (see `Models/SeedModels.swift`).

## Prototype data (personas & history)

- **`Resources/SeedData/sonia_seed.json` is the single source of truth** for the demo
  persona + 2 weeks of guided check-ins. `Models/SeedModels.swift` decodes it 1:1.
- Persona, data-model schema, and the session arc are documented in
  `SoniaHealth/Prototype/PERSONA.md` and `DATA_MODEL.md`. Keep JSON, models, and docs
  in sync when changing the shape.
- Chat sessions store the **full message array**; voice sessions store **summary +
  excerpt turns** (with `atOffsetSec`). Preserve that distinction.

## Clinical safety (domain rule — do not relax)

Sonia is **not** a licensed therapist and not a substitute for care. Any conversational
or prompt change must preserve the **crisis-safety protocol** (e.g. redirect to **988**
US / local emergency). Don't add features that imply diagnosis or guarantee outcomes.

---

## Verification (before saying "done")

- **Swift:** if you can't open Xcode, at least `swiftc -parse` the changed files, and
  for data/model changes, compile + decode against the real JSON (as in this repo's
  history) rather than trusting it by eye.
- **JSON seed:** validate it parses and that counts/IDs are internally consistent
  (e.g. session totals, insight `evidenceSessionIds` resolve).
- State plainly what you verified and what you didn't.
