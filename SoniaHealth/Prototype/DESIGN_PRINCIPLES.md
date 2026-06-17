# Sonia — Design Principles

> App-wide principles that sit *above* any single feature. The guided journal is the first
> place we apply them, but they govern notifications, cards, content, rewards, and IA.
> Companion brief: [`GUIDED_JOURNAL_REDESIGN.md`](./GUIDED_JOURNAL_REDESIGN.md).

---

## P0 — Everything is Sonia speaking

**Sonia is the app's single narrator.** Every prompt, card, reflection, reward, and
notification is *Sonia talking to you* — never a faceless system surface. Everything is part
of one ongoing conversation with Sonia.

| Rule | What it means |
|---|---|
| **Point of view** | Always Sonia's first person / your second person. *"I was thinking about your interview…"*, *"you said this morning…"* — never system voice (*"Your check-in is due"*). |
| **Identity is present** | Wherever Sonia "speaks," her name / avatar / voice is attached — notifications, cards, the journal opener, the reward. |
| **She remembers** | She references real threads from memory, never generic prompts. (Already wired via `SoniaMemoryContext`.) |
| **Talking back is default** | If Sonia speaks to you, the natural reply is to *speak* — this is the root of voice-first. |

**Boundaries**
- Pure utility (settings, raw numbers) may stay neutral — but even stats read better in her
  voice: *"You've shown up 16 mornings."*
- **Clinical safety holds.** A clearer speaker makes the guardrail *more* important: Sonia is
  not a licensed therapist; warm, but never diagnoses or guarantees outcomes; crisis →
  redirect (988 / local emergency).

---

## P1 — A pocket companion you *check in* with (not tasks to complete)

Sonia is always in your pocket. These moments aren't a to-do list — they're **checking in with
someone who's always there.**

- The unifying verb is **check-in**, not "complete your Morning Intention."
- **Drop feature labels from the surface.** The headline is always *what Sonia actually says*;
  "morning / evening check-in" stays as internal metadata (for streaks/stats), not a title.
- **IA implication:** a faceless "feature tab" isn't justified — it's one relationship surfaced
  in different moments. Points toward collapsing the experience around *talking to Sonia* rather
  than splitting it across tabs.

---

## P2 — Morning and evening are two ends of one chain

Same engine, **deliberately different rituals** — and they depend on each other.

```
yesterday's sessions / journals / what you talked about
      │  (memory context)
      ▼
☀️  MORNING — Sonia uses YESTERDAY to help you decide today's commitment
             (a promise you make to yourself; she helps shape it and holds it)
      │  (commitment persisted)
      ▼
      … your day …
      ▼
🌙  EVENING — Sonia brings the commitment back: did you get to live it today?
             (compassion, not pass/fail)
      │  (reflection persisted)
      ▼
   feeds tomorrow's memory  →  (loop)
```

### The asymmetry

| | ☀️ Morning — a commitment | 🌙 Evening — a review |
|---|---|---|
| **Purpose** | start the day by choosing a direction | close the day by looking back |
| **Emotional center** | resolve, forward | acceptance, setting down |
| **Who it's for** | **a promise to yourself** | a review you and Sonia do together |
| **Sonia's role** | *active* — uses yesterday to help you **decide** a meaningful commitment, then **holds** it for the day | *accountability companion* — brings the morning self back and reflects, gently, whether you lived it |
| **Structure** | converge → **land on one commitment** (said aloud), Sonia reflects it back | re-open the commitment → compare with the real day → credit + release |
| **Ending** | Sonia's promise to carry the intention through the day | closure — what you carried, what to set down |
| **Surface** | gold, ☀️ | lavender, 🌙 |

### The dependency (this is the value engine)

- The morning commitment **is** the evening's measuring stick. Doing the morning is what makes
  the evening meaningful.
- **Graceful degrade:** if the morning was skipped, the evening can't anchor on a commitment →
  it becomes a lighter standalone review. Sonia notes it warmly, never punishes:
  *"We didn't catch the morning today — let's still close the day together."*
- Technically: the morning→evening link is `MemoryJournal.guidedEntries` +
  `guidedEntry(date:kind:)` carry-over (optional, so the skip case is handled by design).

---

## How the principles resolve the open questions

- **"Do we have to say *Morning Intention* in the notification?"** → No. P0/P1: the headline is
  Sonia's actual words; the label is internal metadata.
- **"It's awkward that the prompt arrives with no speaker."** → P0: it always comes *from Sonia*,
  with her identity, as part of your ongoing conversation.
- **"Morning and evening feel the same."** → P2: different purpose, different role for Sonia,
  linked as a chain.

---

_Status: captured from design discussion. Next: apply to the guided-journal touchpoints
(notification → Today card → entry), starting with the morning (it anchors the loop)._
