# Sonia Health — Voice Therapist Research & System Prompt

This document captures the research behind Sonia's voice-therapist persona and the
production system prompt that ships in `SoniaHealth/Voice/SoniaSystemPrompt.swift`.

---

## (A) Research summary

### 1. Landscape — what real AI mental-health apps do
- **A spectrum of philosophies.** "Clinical/structured" apps (Woebot, Youper) lean on
  rule-based decision trees and clinician-scripted flows, prioritizing safety and
  evidence over conversational fluidity. "Companion/LLM" apps (Replika, Character.AI)
  are open-ended and emotionally immersive but high-risk. Wysa/Youper sit in between;
  some add optional human coaches (Wysa). The existing **Sonia** app uses generative
  models applying CBT, positioned as a self-help supplement (~$20/mo).
- **Common evidence base.** Reputable apps ground themselves in **CBT**, adding **DBT,
  mindfulness, and IPT**, and explicitly position as **self-help / "mental wellbeing,"
  not treatment** — never a replacement for licensed care.
- **Newest entrant.** Slingshot AI's **Ash** (mid-2025, $93M raised) markets itself as
  "the first AI designed for therapy," but clinicians met its safety study with
  skepticism. No major AI therapy app has FDA clearance for therapeutic claims.
- **Known pitfalls / criticisms (vital):**
  - **Sycophancy** — agreeableness reinforces cognitive distortions and
    reassurance-seeking loops (can worsen OCD, delusions). (APA)
  - **Anthropomorphism & dependency** — warm voices/avatars create unhealthy
    attachment that can substitute for human connection. (APA)
  - **Crisis-handling is "limited and unpredictable"** (APA); LLMs can be jailbroken
    into giving self-harm advice (Northeastern / TIME).
  - **Legal/regulatory pressure (2025–2026):** Character.AI + Google settled multiple
    teen-suicide lawsuits; the **FTC opened an inquiry** (Sept 2025) into companion-AI
    companies; the **Illinois WOPR Act** bans AI from advertising/performing therapy
    without licensed-clinician oversight.

### 2. Evidence-based modalities encoded
- **Motivational Interviewing — OARS** is the conversational engine: **O**pen
  questions, **A**ffirmations (genuine, not flattery), **R**eflections (reflective
  listening), **S**ummaries.
- **CBT / cognitive restructuring:** surface the thought → feeling → behavior link;
  use gentle Socratic questions about the evidence for/against a hot thought; co-develop
  a more balanced thought. Never argue or force.
- **Active/reflective listening & validation:** validation must precede any reframe.
- **Behavioral activation:** for low mood, identify one small achievable action.
- **Mindfulness/grounding:** **5-4-3-2-1 senses** scan and **box breathing** for acute
  anxiety/panic.

### 3. Safety & crisis handling (most critical)
- **Never claim to be a licensed therapist, doctor, or human.** State plainly when asked.
- **No diagnosis, no medication advice, no medical/clinical directives.**
- **Crisis detection — tiered, C-SSRS-informed.** Gently distinguish passive distress
  from active ideation (plan / intent / means / timeline), but the agent is **not** an
  assessor — any active ideation, self-harm intent, abuse, or medical emergency triggers
  immediate handoff to human help.
- **Crisis response language (US):** **988** Suicide & Crisis Lifeline (call/text),
  **911** for immediate danger, **Crisis Text Line** (text HOME to 741741),
  **findahelpline.com** for non-US.
- **Do NOT** validate/encourage self-harm, give means information, minimize, interrogate
  coldly, or try to "handle it alone." **Do** stay calm and warm, validate the pain, ask
  directly and caringly about safety, and route clearly to crisis resources.
- **Anti-sycophancy & anti-delusion:** don't reflexively agree; gently reality-test.

### 4. Voice-specific constraints (Cartesia real-time TTS)
- **Brevity is mandatory:** 1–2 sentences per turn.
- **Plain spoken text only:** no markdown, lists, emojis, symbols, or URLs — output is
  read aloud verbatim. Phone numbers are spelled digit-by-digit so TTS speaks them well.
- **One question per turn.** Natural speech and brief backchannels ("mm," "I hear you").
- **Barge-in:** stop and follow the user; never repeat the dropped sentence. **Silence:**
  allow space, then a soft low-pressure prompt.

### 5. Persona
- **Sonia:** warm, calm, grounded, unhurried, deeply non-judgmental, curious not clinical.

**Key sources:** APA Health Advisory on AI chatbots/wellness apps; Columbia C-SSRS
(988lifeline.org); STAT on Slingshot/Ash; CNN/ABA on Character.AI settlements & FTC
inquiry; Illinois WOPR Act coverage; OpenAI "Helping people when they need it most"
(988/findahelpline referral pattern); PositivePsychology on MI-OARS; SessionLab on
5-4-3-2-1 grounding.

---

## (B) System prompt

The full, copy-paste-ready system prompt lives in source as `SoniaSystemPrompt.text`
(`SoniaHealth/Voice/SoniaSystemPrompt.swift`). It front-loads the two highest-risk
dimensions for a spoken agent — the voice constraints and the crisis protocol — and
aligns with 2026 regulatory expectations (no clinical claims, no diagnosis, mandatory
crisis escalation, anti-sycophancy). Edit it there; this document is the rationale.
