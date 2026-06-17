# Sonia Health — IA & Design System (extracted from product screenshots)

This folder documents the **Information Architecture (IA)** and **Design System**
of the Sonia Health iOS app, reverse-engineered from 16 product screenshots
(`IMG_3369`–`IMG_3385`).

> Source of truth: the screenshots capture the *intended* product experience.
> Where the current Swift code (`DesignSystem/`) diverges from the screenshots,
> the gap is recorded in [`design-system/code-gap-analysis.md`](design-system/code-gap-analysis.md).

## What Sonia Health is

An AI-companion mental-health & wellbeing app. The companion is **"Michelle"**.
Users interact through **voice calls**, **chat**, and structured **daily routines**
(Morning Intention, Evening Reflection, Wellbeing check-ins, Daily Affirmation).
The tone is calm, warm, reflective. Visuals are dark, editorial, serif-led.

## Documents

| Doc | Contents |
|-----|----------|
| [`information-architecture.md`](information-architecture.md) | Navigation model, tab structure, routine flows, screen map |
| [`screen-inventory.md`](screen-inventory.md) | Every screenshot mapped to a screen + states |
| [`design-system/foundations.md`](design-system/foundations.md) | Color, typography, spacing, radius, elevation |
| [`design-system/components.md`](design-system/components.md) | Component catalog with anatomy & states |
| [`design-system/themes.md`](design-system/themes.md) | Morning / Evening / Assessment / Voice theme variants |
| [`design-system/code-gap-analysis.md`](design-system/code-gap-analysis.md) | Screenshots vs. current `SR*` tokens/components |

## Method & confidence

- Color hex values are **visually sampled approximations** — verify against
  design source files before locking tokens.
- Type sizes are **estimated** from a 393pt-wide iPhone frame.
- Structure/IA is **high confidence** (directly observable in the UI).
