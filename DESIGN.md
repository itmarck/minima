# Minima Design System

## Principles

1. **Reduction** — no decoration, no color, no gradients. Every element has a purpose.
2. **Stability** — layout does not shift. Dynamic content uses fixed-height containers.
3. **Grayscale hierarchy** — importance is expressed through brightness, not hue or size.
4. **Text as interface** — labels are the primary interaction surface. Icons are secondary.
5. **Calm density** — generous touch targets, compact information spacing.

---

## Theme approach

All visual values live in `MinimaTheme` as a fully configured `ThemeData`.
Widgets use `Theme.of(context)` — never static `MinimaTheme.*` references.
To change the look, change only `MinimaTheme`. No widget-level styles needed.

---

## Color roles

Seven tones on a black-to-white scale. Mapped to `ColorScheme` in ThemeData.

| Role            | Semantic meaning                              |
|-----------------|-----------------------------------------------|
| `background`    | Screen background (darkest)                   |
| `surface`       | Cards, inputs, bottom sheets                  |
| `surfaceLight`  | Elevated/pressed interactive surfaces         |
| `textPrimary`   | Primary content — titles, input text          |
| `textSecondary` | Secondary content — app labels, subtask text  |
| `textMuted`     | Supporting info — hints, metadata, icons      |
| `accent`        | Emphasis (reserved, use sparingly)            |

---

## Typography roles

Mapped to `TextTheme` in ThemeData. Two levels per component at most.

| Role           | Used for                                    |
|----------------|---------------------------------------------|
| titleMedium    | AppBar titles                               |
| bodyLarge      | Text input                                  |
| bodyMedium     | List item titles, tile labels               |
| bodySmall      | Subtitles, metadata                         |
| labelSmall     | Actionable type labels, captions            |
| labelMedium    | Pending count, info text, links             |
| labelLarge     | Settings section headers (+ letterSpacing)  |

---

## Spacing & shape

Defined once in ThemeData. Widgets inherit via component themes.

- Base unit: **4px**. All spacing is a multiple of 4.
- Default border radius: **12**. Used for inputs, cards, tiles, buttons, sheets.
- Exceptions: checkboxes (3), drag handle (2), bottom sheet top corners (16).

---

## Layout rules

1. **Fixed-height containers** for dynamic content — prevents layout shifts.
   - `FavoriteApps`: 5 slots × 28px = 140px (top-aligned, empty slots invisible)
   - `ActionableResults`: 3 slots × 40px + 8px gap = 128px (bottom-aligned)
2. **Bottom-anchored home** — all interactions are in the bottom section. Center is empty.
3. **Vertical hierarchy** — top: status. center: calm/empty. bottom: actions.
4. **Optimistic updates** — items are removed from the UI immediately; sync is background.

---

## Icons

Material Icons, outlined variants preferred. Color: `textMuted`. One per tile max.
Sizes: 16 (inline), 18 (tile leading), 22 (top bar).
