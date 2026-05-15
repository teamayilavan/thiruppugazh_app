# Thiruppugazh App — Color Guide

## Design Language

A **forest green** palette, Material 3 compliant, with full light/dark theme support. Every color has a deliberate light↔dark counterpart.

Source of truth: `lib/theme/app_theme.dart` — `AppColors` class and `AppColorExtension` ThemeExtension.

---

## Core Palette

### Light Theme

| Token | Hex | Role |
|---|---|---|
| `background` | `#D8EFD3` | Scaffold background |
| `container` | `#CAE8BD` | Cards, nav bar background |
| `card` | `#B3D8A8` | Card surfaces |
| `accent` | `#80AF81` | Primary / interactive |
| `textHigh` | `#196519` | Headlines, emphasis text |
| `text` | `#0D3619` | Body text, on-primary |
| `textMuted` | `#A9A9A9` | Timestamps, secondary labels |

### Dark Theme

| Token | Hex | Role |
|---|---|---|
| `dbackground` | `#1F4529` | Scaffold background |
| `dcontainer` | `#255F38` | Cards, nav bar background |
| `dcard` | `#357943` | Card surfaces |
| `daccent` | `#609755` | Primary / interactive |
| `dtextHigh` | `#63B467` | Headlines, emphasis text |
| `dtext` | `#ECECEC` | Body text, on-primary |
| `dtextMuted` | `#A9A9A9` | Timestamps, secondary labels (same in both modes) |

---

## Material 3 ColorScheme Mapping

| Slot | Light | Dark |
|---|---|---|
| `primary` | `#80AF81` | `#609755` |
| `onPrimary` | `#0D3619` | `#ECECEC` |
| `surface` | `#D8EFD3` | `#1F4529` |
| `onSurface` | `#0D3619` | `#ECECEC` |
| `error` | `Colors.red` | `Colors.red` |
| `onError` | `#FFFFFF` | `#FFFFFF` |

---

## Semantic / Functional Colors

| Use Case | Color | Notes |
|---|---|---|
| Destructive actions (delete) | `Colors.red` | Buttons, icons, text |
| Highlight (verse/note background) | `Colors.yellow @ 30% alpha` | Overlay on content |
| Muted metadata | `Colors.grey` | Dates, counts |
| Error state | `colorScheme.error` | Via theme, not hardcoded |

---

## Navigation Bar

| State | Light | Dark |
|---|---|---|
| Background | `#CAE8BD` | `#255F38` |
| Selected indicator | `#80AF81` | `#609755` |
| Selected icon | `#1F4529` | `#D8EFD3` |
| Unselected icon | `#A9A9A9` | `#A9A9A9` |

---

## Green Depth Scale

Each step moves one shade darker in light mode and one shade lighter in dark mode:

```
Light:  #D8EFD3  →  #CAE8BD  →  #B3D8A8  →  #80AF81
         bg          container     card         accent

Dark:   #1F4529  →  #255F38  →  #357943  →  #609755
         bg          container     card         accent
```

---

## Rules for New Apps

1. **Define all colors centrally** — never use raw `Color(0xFF...)` in UI widgets. Define in an `AppColors` class and expose via `ThemeExtension`.
2. **Always pair light/dark values** — every color token needs a counterpart for the opposite mode.
3. **Use `colorScheme.surface` for scaffold backgrounds**, not the raw hex.
4. **Red is reserved for destructive/error states only** — do not use it decoratively.
5. **`textMuted` (#A9A9A9) is theme-invariant** — it sits at a neutral midpoint that works on both light and dark backgrounds.
6. **Follow the depth hierarchy** — `background` → `container` → `card` for layered surfaces, each step one shade darker (light) or lighter (dark).
