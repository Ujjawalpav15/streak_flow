# StreakFlow — UI/UX Polish Specification

> Feed this file to the coding agent working on the StreakFlow Flutter app.
> Goal: elevate the UI/UX from "functional habit tracker" to "gamified, Duolingo/Snapchat-grade streak app" — multiple accent themes, tier-based visual feedback, satisfying micro-interactions, and a polished design system.

---

## 0. Context

StreakFlow is a Flutter + Riverpod + Hive offline-first habit streak tracker (ENEX 386 project). Core loop, data layer, and most functional features (CRUD, streaks, milestones, calendar, notifications, backup) are already implemented. **This spec covers UI/UX polish only — do not change data models, streak logic, or architecture unless explicitly required to support a visual feature below.**

Reference the existing architecture before making changes:
```
Presentation: HomeScreen, StatsScreen, HabitCard, MilestoneBadgesSheet, CelebrationDialog, SettingsSheet
Application:  HabitsNotifier (Riverpod), filters, search/sort providers
Data/Domain:  Habit model (@HiveType), HiveStorage, NotificationService, BackupService
```

---

## 1. Design System (build this first — everything else depends on it)

Create `lib/theme/` with:

- `app_colors.dart` — semantic color tokens (not raw hex scattered through widgets)
- `app_typography.dart` — type scale using `google_fonts`
- `app_spacing.dart` — spacing constants, multiples of 4
- `app_radius.dart` — corner radius constants
- `app_accent.dart` — `ThemeExtension<AppAccent>` definitions (see Section 2)

### Type scale (use `google_fonts`, try **Inter**, **Manrope**, or **Sora**)
| Token | Size | Weight | Usage |
|---|---|---|---|
| displayLarge | 32 | 700 | Onboarding/empty states |
| headlineMedium | 22 | 700 | Screen titles |
| titleMedium | 18 | 600 | Habit name |
| streakCount | 24–28 | 800 | Streak number — use `tabularFigures` |
| bodyMedium | 14 | 500 | General text |
| labelSmall | 12 | 500 | Meta/category text, muted color |

### Spacing scale
`4, 8, 12, 16, 24, 32, 48` — no arbitrary values in widget code.

### Radius scale
`12` (cards), `20` (sheets/dialogs), `999` (pills/badges/chips).

---

## 2. Multiple Accent Color Themes

Implement via `ThemeExtension` so each theme carries a **full palette**, not just a swapped `primaryColor`.

```dart
class AppAccent extends ThemeExtension<AppAccent> {
  final Color primary;
  final Color primaryContainer;
  final Color glow;
  final Color gradientStart;
  final Color gradientEnd;

  const AppAccent({
    required this.primary,
    required this.primaryContainer,
    required this.glow,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  AppAccent copyWith({...}) => ...;

  @override
  AppAccent lerp(ThemeExtension<AppAccent>? other, double t) => ...;
}
```

### Required themes (from existing roadmap notes)
| Name | Primary | Glow | Gradient |
|---|---|---|---|
| Cyber Violet | `#8B5CF6` | `#A78BFA` | `#7C3AED → #C084FC` |
| Neon Emerald | `#10B981` | `#34D399` | `#059669 → #6EE7B7` |
| Solar Amber | `#F59E0B` | `#FBBF24` | `#D97706 → #FCD34D` |
| Midnight Ruby | `#EF4444` | `#F87171` | `#B91C1C → #FCA5A5` |

### Behavior
- Store selected theme name in a Hive `settingsBox` (key: `accentTheme`).
- Wrap app root in a Riverpod provider (`accentThemeProvider`) that rebuilds `MaterialApp`'s theme when changed.
- Add a **theme picker UI in Settings**: tappable circular swatches (not a dropdown), selected swatch shows a glow ring + checkmark, animate selection with a scale bounce.
- Persist across app restarts (already-existing dark theme should remain the base; accent only changes primary/accent colors, not light/dark mode).

---

## 3. Streak Tier Visual System

Each streak tier gets a consistent color + glow used across HabitCard, StatsScreen, and MilestoneBadgesSheet:

| Tier | Days | Emoji | Color |
|---|---|---|---|
| Ember | 1–6 | 🔥 | `#F97316` |
| Plasma | 7–29 | 💜🔥 | `#A855F7` |
| Golden Crown | 30–49 | 🔱🔥 | `#EAB308` |
| Diamond | 50–99 | 💎🔥 | `#06B6D4` |
| Mythic Ruby | 100+ | 👑🔥 | `#DC2626` |

Implement a pure helper function `getTierColor(int streak) -> Color` and `getTierGlow(int streak) -> Color` in `lib/theme/streak_tiers.dart`, used everywhere tier visuals are needed (avoid duplicating tier logic in widgets).

---

## 4. Screen-by-Screen Requirements

### 4.1 HabitCard (highest priority — seen most often)
- Card border or subtle outer glow colored by current tier (`getTierGlow`)
- Streak number uses `tabularFigures` font feature so digits don't jitter on update
- Animate streak count changes with a count-up tween (`TweenAnimationBuilder<int>`, ~400ms, easeOutCubic)
- Tap-to-complete feedback:
  - `HapticFeedback.mediumImpact()`
  - Scale-bounce animation (0.95 → 1.0, ~150ms)
  - Brief glow/particle burst on the card itself (separate from the full milestone confetti)
  - Consider a 2–3 second undo window after marking complete (long-press or snackbar "Undo") instead of instant irreversible lock-in

### 4.2 HomeScreen
- Staggered entrance animation for habit cards on load (`flutter_animate`, ~50ms stagger per card)
- Empty state: illustration + headline + clear "Add your first habit" CTA — not a blank list
- Search/sort controls should feel lightweight — collapse into an icon that expands, not permanent screen real estate

### 4.3 StatsScreen / Calendar
- Heatmap: smooth color interpolation between "not done" and tier color, not hard color buckets
- Day-of-week bar chart: staggered bar grow-in animation on screen load
- Monthly calendar: month-switch transition should slide/fade, not hard-cut

### 4.4 MilestoneBadgesSheet (the dopamine moment — invest here)
- Expand to near-full-screen modal (not a small bottom sheet) for milestone celebrations
- Badge illustration large and central, background uses tier gradient
- Confetti particle burst on entrance
- Single clear dismiss action ("Nice!" / "Share")

### 4.5 Settings
- Accent theme picker (Section 2)
- Group settings into clear sections with consistent list-tile styling

---

## 5. Motion Guidelines

- Micro-interactions (taps, toggles): **150–300ms**
- Screen transitions: **300–500ms max**
- Easing: prefer `Curves.easeOutCubic` for entrances, `Curves.easeInOutCubic` for transitions
- Never block user input during animations — all animations should be non-blocking/optimistic

---

## 6. Recommended Packages

| Purpose | Package |
|---|---|
| Fonts | `google_fonts` |
| Micro-animations / staggering | `flutter_animate` |
| Icons (more distinctive than Material default) | `phosphor_flutter` or `lucide_icons` |
| Confetti (if not keeping custom painter) | `confetti` |
| Haptics | Built-in `HapticFeedback` |

Do not introduce packages outside this list without checking `pubspec.yaml` compatibility with existing Flutter SDK constraint (`>=3.10.3`).

---

## 7. Implementation Order

1. Design tokens (`lib/theme/` — colors, typography, spacing, radius)
2. Accent theme system + Settings picker
3. Streak tier color/glow helper (`streak_tiers.dart`)
4. HabitCard visual + interaction polish (core loop — highest impact)
5. HomeScreen entrance animations + empty state
6. StatsScreen/calendar animation polish
7. MilestoneBadgesSheet full-screen redesign

---

## 8. Constraints / Non-Goals

- Do not modify Hive schema, streak calculation logic, or notification scheduling as part of this pass.
- Keep 100% offline behavior — no network calls introduced for fonts/icons at runtime (bundle assets or use packages that ship fonts locally).
- Maintain `flutter analyze` at 0 errors/0 warnings after changes.
- Dark theme remains the base theme; accent themes only change primary/highlight colors, not overall light/dark mode.
