# Design System — Theme Variants

Sonia Health uses **one structural design system** rendered through **four
contextual themes**. The accent color + iconography + (sometimes) the surface
treatment swap; layout and components stay constant.

## The four themes

| Theme | Trigger | Accent | Icon | Surface | CTA style | Screens |
|-------|---------|--------|------|---------|-----------|---------|
| **Morning** ☀ | Morning Intention | gold/amber `#C9A24B` | sun | dark charcoal cards | gold pill | 3369–3376 |
| **Evening** 🌙 | Evening Reflection | lilac `#B7A9D6` | moon+stars | dark charcoal cards | lilac pill | 3377–3379 |
| **Assessment** ♡ | Wellbeing survey | white / cream track | heart | dark, **larger type, modal** | white solid pill | 3380–3381 |
| **Companion** 📷 | Phone & Chat | white-on-photo + glass | — | **full-bleed photography + scrim** | glass / slide control | 3382–3384 |

> The Morning ↔ Evening pair is the clearest proof: **identical screens, only the
> accent token and time icon differ.** Build components accent-agnostic and inject
> the theme.

## Theme contract (recommended shape)

```
Theme {
  accent            // gold | lilac | white
  accentOnText      // dark text used on accent CTA
  icon              // sun | moon | heart | sparkle
  surfaceStyle      // .card(dark) | .photo(scrim) | .modalAssessment
  progressStyle     // .segmented | .continuous
  titleFont         // serif display
}
```

Map to context:
- `Morning Intention` → `.morning`
- `Evening Reflection` → `.evening`
- `Wellbeing` → `.assessment`
- `Phone`, `Chat` → `.companion`
- `Daily Affirmation` → `.morning`-adjacent (gold sparkle, dark cards)

## Relationship to existing code

`SRRoutineHeroPalette` already models **per-routine palettes** (evergreen,
rosewood, steelBlue, amberOlive, aubergine, spruce, clay) with a rotation/hash
assignment. That is a *good* mechanism — but its **colors are teal/earth-based,
not the gold/lilac in the screenshots**, and it's keyed by `routineID` hash
rather than time-of-day/flow semantics.

**Recommendation:** keep the `SRRoutineHeroPalette` *pattern*, but
1. add semantic themes (`morning`, `evening`, `assessment`, `companion`), and
2. re-key selection to flow/time-of-day instead of UUID hash,
3. retune hex to the sampled gold/lilac/cream values.

See [`code-gap-analysis.md`](code-gap-analysis.md).
