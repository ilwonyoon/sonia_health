# Guided Journal — Redesign Brief

> Today's working topic. A redesign of the **Guided Journal** (Morning Intention /
> Evening Reflection) — one of the most-used features after the core voice session.
> This document captures the brief, the current state, the problems, and the goals.
> Design proposals and prototype work build on top of this.
>
> Related: [`PERSONA.md`](./PERSONA.md) · [`DATA_MODEL.md`](./DATA_MODEL.md) ·
> current code in `Features/Content/` (`CheckInFlowView`, `ContentTodayView`).

---

## 1. Context — where this sits in the app

- **Main feature:** the voice session (and text chat) — direct interaction with the AI
  coach inside the app.
- **The problem it solves:** real therapy-style sessions are hard to do *daily* — they're
  exhausting, and they don't *need* to happen every day.
- **The solution:** lightweight **daily habit activities** in the app that keep the
  relationship and momentum going between sessions.
- **Guided journals are one of those habit activities** — and the most-used one next to
  the voice session itself.

So the guided journal is not a form to fill in. It's a **daily ritual** that should feel
worth returning to, and that should give the user something back every time.

---

## 2. What Guided Journals are today

A guided journal is a structured **3-question prompt** the user fills out once a day.
Two flavors:

- **Morning Intention** — surfaced in the morning, meant to *set* the day.
- **Evening Reflection** — surfaced in the evening, meant to *close* the day.

### Today's mechanics

1. **All 3 questions are pre-generated** by a single LLM call *before the user even opens
   the entry*. Both flavors share the **same prompt template**.
2. After the user submits answers, a **second LLM call generates a "reflection"**:
   - Title
   - Summary text
   - Optional insight
   - Mood tags
   - Affirmation
3. **Voice input exists but plays second fiddle to typing** — a small audio bar plus a
   text field. Completion shows a fairly **static** screen with the reflection.

---

## 3. Current problems

- **Pre-generated questions** — generated up-front, so they can be presumptuous and
  sometimes not relevant to where the user actually is.
- **Morning and evening feel the same** — shared template, no real conceptual difference.
- **Text-first design** — voice is buried under typing.
- **Feedback / review page is not meaningful** — static, not rewarding, not personalized.
  It doesn't make the time feel worth it.

---

## 4. The brief — what the redesign must do

A new guided journal flow with these properties:

### 4.1 Adaptive questions
1. **Q1 is pre-generated** before the user enters the app in the morning.
2. **Q2 and Q3 are generated on the fly**, appearing *after* the user answers the previous
   question. Generation should use:
   - **Latest user context:** recent activity, goals, prior journals
   - **The most recent question and answer**
   - **Adaptive tone, depth, and direction**

### 4.2 Voice-first
3. Voice is the **dominant input modality**. Typing must still work cleanly, but the
   **visual hierarchy and default state** should make speaking the obviously-intended path.
   Be opinionated — the current "audio bar" is bland. Show what journaling-by-voice
   *should feel like*.

### 4.3 It should not feel like a form
4. Care about the **moment-to-moment feel** of the flow:
   - How questions appear
   - How the user moves through them
   - **What waiting feels like** (e.g. while Q2/Q3 generate)
   - How transitions look
   - **How morning and evening feel meaningfully different**

### 4.4 A rewarding ending
5. A **short visual reward and/or AI-generated report** at the end — **briefer and more
   varied** than today's reflection. Different entries should deliver **different kinds of
   value**, e.g.:
   - An insight
   - A connection back to something earlier
   - A quiet affirmation
   - A question to carry forward
   - Sometimes just "well done"
   - Some **metrics** — words shared, days journaled so far, streak, etc.

   The user should leave feeling **the time was worth it.**

---

## 5. What we're looking for (deliverables)

- **Clear thinking about journaling** — morning vs. evening as *conceptually distinct*.
- **Opinionated UI for the voice flow** — show how voice becomes the obvious path.
- **A reasonable approach to streaming Q2/Q3** — latency, perceived speed, and animation,
  without feeling jumpy.
- **Trade-offs explained.**
- **Bonus — a continuity hook:** how does today's journal show up *elsewhere* in the
  user's experience tomorrow?

---

## 6. Open questions & idea bank (side notes)

### 6.1 What does the user get out of it? (worth coming back for)
- What **motivates** them to come back?
- What **celebration** can we give them?
- What **stats** can we show after they finish?
- What is the durable thing they **get out of it**?
- Ideas:
  - An **optional field** at the end: hint / pattern / reference / quote / *nothing*.
  - **Voice-based stats** (e.g. emotions detected in the voice), Oura-style.

### 6.2 How to sit alongside other Quests / daily activities
- **Streaks?**
- **Calendar overview** of completed activities?
- **Specific stats over time?**

### 6.3 Continuity
- How does today's entry resurface tomorrow (in the next journal, in a session, on the
  Today page, in a quest)?

---

## 7. Grounding in the current prototype

| Concern | Where it lives today |
|---|---|
| Answer flow UI (3-question sequence) | `Features/Content/CheckInFlowView.swift` |
| Flow components (progress bar, question header, response field) | `Features/Content/Components/CheckIn*.swift` |
| "Today" page (open cards + completed timeline) | `Features/Content/ContentTodayView.swift` |
| Journal data model + seed | `Models/JournalModels.swift`, `Resources/SeedData/journal_today.json` |
| Persona + 2-week history | `Prototype/PERSONA.md` |
| Crisis-safety protocol (must be preserved) | see project `CLAUDE.md` — clinical safety |

---

_Status: brief captured. Next: design directions for the voice-first flow, adaptive Q2/Q3
streaming, and the morning/evening split._
