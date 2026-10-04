# Design system

Paste in the design system you submitted, and replace it with the final version
when the project is done. It is also the reference you open every time you build
a new screen, so keeping it current helps you more than it helps anyone reading.

**This document needs a visual, not just this text.** Export a PDF or an image
that *shows* your palette, type scale, spacing and components, put it in
`assets/`, and link it here:

```markdown
![Design system](assets/design-system.png)
[Design system (PDF)](assets/design-system.pdf)
```

Figma, Canva, Excalidraw, Google Slides or Docs exported to PDF all work. A
reader should be able to see your app's look in one glance, without reading a
table.

[Caly design system (PDF)](assets/caly-design-system.pdf)

## Palette

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| Gold / primary | `#D9A400` | `#E9B72D` | Primary actions, selected navigation, focus |
| Ink / on-primary | `#1C1C1E` | `#1C1C1E` | Text and icons placed on gold |
| Paper / surface | `#FFFDF8` | `#121210` | Main page background |
| Card / surface container | `#FFFFFF` | `#1C1C1A` | Inputs, sheets, and raised content |
| Main text / on-surface | `#1C1C1E` | `#F4F1EA` | Titles and body copy |
| Muted / on-surface variant | `#6F6F73` | `#B8B5AE` | Dates, hints, metadata |
| Outline | `#E7E4DE` | `#383834` | Dividers and input borders |
| Error | `#C63A35` | `#FFB4AB` | Validation and failed requests |
| Soft gold / secondary | `#FFF4C2` | `#4A3E19` | Gentle emphasis and progress areas |

The multicolour `CALY` wordmark uses calico-inspired charcoal, orange, cream,
and pink accents. Its neutral letters switch to theme-aware contrast in dark
mode so the name remains readable.

## Type scale

The app uses platform-native fallbacks (`-apple-system`, `BlinkMacSystemFont`,
then `Segoe UI`) to keep the interface simple and familiar.

| Style | Size / line height | Weight | Use |
| --- | --- | --- | --- |
| `headlineSmall` | 30 / 1.12 | 700 | Large page titles |
| `titleLarge` | 22 / 1.20 | 600 | Sheet and section titles |
| `bodyMedium` | 16 / 1.40 | 400 | Food notes, inputs, and regular copy |
| `labelSmall` | 13 / 1.35 | 400 | Dates, meal labels, status, and metadata |

## Spacing

The spacing scale is based on eight pixels and is defined in
`lib/theme/caly_spacing.dart`.

| Token | Value | Typical use |
| --- | --- | --- |
| `xs` | 8 px | Tight icon and label gaps |
| `sm` | 16 px | Related controls and field padding |
| `md` | 24 px | Page margins and section separation |
| `lg` | 32 px | Major content groups |
| `xl` | 48 px | Large vertical breathing room |

Inputs and primary buttons use 12-pixel corner radii, floating snackbars use a
14-pixel radius, and phone layouts use 24-pixel horizontal page padding.

## Components

One row per reusable widget: what it is, which file it lives in, what parameters
it takes, which screens use it.

| Widget | File | Main parameters | Used by |
| --- | --- | --- | --- |
| `CalyPageBody` | `lib/widgets/caly_page_body.dart` | `child`, optional `maxWidth` | Sign In, Today, History, Settings |
| `CalyBrandHeader` | `lib/widgets/caly_brand_header.dart` | none | Sign In |
| `LargeTitleHeader` | `lib/widgets/large_title_header.dart` | `title`, optional `subtitle`, `trailing` | Today, History, Settings |
| `MealSection` | `lib/widgets/meal_section.dart` | meal, entries, draft controller/state, submit/retry/edit/delete callbacks | Today |
| `FoodEntryRow` | `lib/widgets/meal_section.dart` | entry, calorie action, retry action | Meal sections on Today |
| `FoodThinkingIndicator` | `lib/widgets/meal_section.dart` | none | Draft and entry loading states |
| `DailyCalorieSummary` | `lib/widgets/daily_calorie_summary.dart` | `totalCalories`, `dailyGoal` | Today |
| `FoodCorrectionSheet` | `lib/widgets/food_correction_sheet.dart` | `entry` | Today correction flow |
| `SettingsRow` | `lib/screens/settings_screen.dart` | icon, label, optional value/action/destructive state | Settings |

Shared component rules:

- Use icons with semantic labels for compact navigation and actions; retain text
  for food notes, values, validation, and primary actions where meaning matters.
- Show progress next to the exact food line being interpreted, not as a blocking
  full-screen loader.
- Use the colour scheme from `Theme.of(context)` instead of fixed foregrounds so
  every component follows system light or dark mode.
- Keep food entries immutable; callbacks return changes to Today, which owns the
  journal state and persistence flow.

## Changes since the last version

- **2026-09-23:** Converted the submitted colours, type hierarchy, buttons, and
  input styling into reusable Flutter theme tokens.
- **2026-10-02:** Simplified food entry into an Apple Notes-inspired inline
  journal, added animated thinking dots, and used icon-led navigation/actions.
- **2026-10-04:** Added responsive width constraints, system dark theme colours,
  and theme-aware CALY wordmark contrast.
