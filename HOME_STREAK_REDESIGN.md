# StreakFlow — Home Screen & Streak Detail Redesign Spec

> Feed this file to the coding agent working on StreakFlow.
> Reference images: a mobile streak-tracker UI (warm orange gradient, dot-matrix heatmaps) and a desktop habit dashboard (used only for layout/pattern inspiration — not a literal clone target). This spec describes what to actually build.
>
> **Scope**: New Home screen layout, new Streak Detail view, new dot-matrix heatmap component, new empty state, new bottom nav, and an optional "Dashboard" pattern for the existing Stats screen. Do not change data models or streak calculation logic — this is presentation-layer only.

---

## 0. What to take from each reference, and what to skip

**Take from the mobile reference (primary):**
- Warm gradient header with greeting + streak badge + notification bell
- White card list, each card = one habit, showing streak count, progress fraction, and a small per-habit dot-matrix heatmap
- Tapping a card opens a detail view with a large flame counter, weekly day-row, goal stats, full heatmap, and an "Edit Streak" CTA
- Empty state: centered flame icon in a dashed circle with a "+" and a decorative dot-matrix background

**Take from the desktop dashboard (secondary — patterns only, not literal features):**
- Personalized greeting header pattern ("Happy Tuesday 👋" style — adapt to "Good Morning, {name}")
- Small calendar widget pattern (already have `interactive_monthly_calendar.dart` — no rebuild needed)
- Card-grid analytics layout pattern for the Stats screen
- "Wrapped" recap card concept (e.g. "Habits Wrapped 2026") — fun optional addition, not required
- **Do not build**: weather widget, Spotify/music integration, running-competition map, social "X people love this" cards — none of these fit an offline-only habit app's scope.

---

## 1. Color & Theme

Add a new accent theme option (alongside the existing Cyber Violet / Neon Emerald / Solar Amber / Midnight Ruby) called **Streak Orange**, matching the reference:

| Token | Value |
|---|---|
| primary | `#FF7A3D` |
| primaryContainer | `#FFB088` |
| glow | `#FFA366` |
| gradientStart | `#FF6B35` |
| gradientEnd | `#FF9A56` |
| background (light card surfaces on dark theme) | keep app's existing dark background token |
| card background | `#FFFFFF` at 6–8% opacity over dark background, or full white card on a lifted surface — see Section 3 |

If the user selects **Streak Orange**, the Home screen header (Section 3) uses `gradientStart → gradientEnd` as a full-bleed background gradient behind the greeting + streak badge, matching the reference image's warm orange wash.

This is additive — add it to `app_accent.dart` using the same `ThemeExtension` pattern as the other four themes. Do not remove or replace existing themes.

---

## 2. New Component: Dot-Matrix Heatmap

Build a reusable widget: `lib/widgets/dot_matrix_heatmap.dart`

### API
```dart
class DotMatrixHeatmap extends StatelessWidget {
  final List<DateTime> completedDates;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int columns;          // e.g. 15 for card-mini, more for full view
  final double dotSize;       // e.g. 6.0 mini, 10.0 full
  final double dotSpacing;    // e.g. 3.0
  final Color activeColor;    // tier color or accent primary
  final Color inactiveColor;  // low-opacity neutral, e.g. onSurface at 8%
}
```

### Visual spec
- Grid of small rounded-square dots (not circles — matches reference), `borderRadius: 2`
- Completed days: solid `activeColor`
- Missed days: `inactiveColor` (faint, barely visible)
- Future/not-yet-reached days: same as missed, or slightly more transparent to distinguish "hasn't happened yet" from "missed" (optional refinement — use `activeColor.withOpacity(0.05)` for future vs `0.12` for missed-in-past, if you want the distinction)
- No labels, no gridlines, no axis — purely decorative/glanceable, exactly like the reference

### Two size variants
1. **Mini** (used inside `HabitCard`, right-aligned, ~60x40px area, 2 rows visible)
2. **Full** (used in Streak Detail screen, wider grid showing more history, ~full card width)

---

## 3. Home Screen Redesign

File: `lib/screens/home_screen.dart` (modify existing)

### 3.1 Header section (new)
Replace the current top-of-screen layout with:

```
┌─────────────────────────────────────────┐
│  [avatar]              [🔥 streak] [🔔]  │  ← gradient background
│                                            │
│  Good Morning, {userName}                 │
│  Keep the streak alive, spark your        │
│  daily motivation.                        │
└─────────────────────────────────────────┘
```

- Background: `gradientStart → gradientEnd` (diagonal, ~135°) when Streak Orange theme active; falls back to the current app's base gradient/solid color for other themes
- Left: circular avatar placeholder (user has no auth/profile system — use a generic icon avatar, or omit if no user-identity concept exists in the app; do not add account/login features)
- Right: a pill-shaped **total active streak badge** (flame icon + count, e.g. "🔥 16") showing the user's longest currently-active streak across all habits, plus a notification bell icon (opens notification settings or a placeholder if no notification center exists yet)
- Greeting text: "Good Morning" / "Good Afternoon" / "Good Evening" based on time of day, followed by a static motivational line (can rotate through a small fixed list of lines, e.g. "Keep the streak alive, spark your daily motivation.")
- If the app doesn't currently store a display name, default to a generic greeting ("Good Morning!") — do not build a name-entry/onboarding flow as part of this pass unless already planned elsewhere.

### 3.2 Habit list cards (redesign existing `HabitCard`)
Each card:

```
┌───────────────────────────────────────────┐
│ 🔥 5 Days Streak              [✓]          │
│ Read 20 pages habit book                   │
│ 27/60 days completed        ▪▪▪▪▪▪▪▪▪▪▪▪   │
│                              ▫▫▪▪▫▪▪▫▪▪▫▪   │
└───────────────────────────────────────────┘
```

Layout (left to right):
- **Left column**: small flame/tier badge + day count label at top ("5 Days Streak" — small, colored by tier), then the habit name in bold below, then the progress fraction ("27/60 days completed") in muted small text — only show the fraction if the habit has a `milestoneTarget`/goal set; otherwise show just the current streak
- **Right column**: mini `DotMatrixHeatmap` (2 rows), and above/beside it a circular checkbox/checkmark button for marking the habit complete today (reuse existing tap-to-complete interaction, haptics, and scale-bounce from the prior polish pass — do not rebuild that logic)
- Card background: white or near-white surface (elevated card on dark theme — use a lighter surface token, not pure white, to stay consistent with dark theme base), rounded corners (`AppRadius.card`), soft shadow
- Tapping anywhere on the card **except** the checkmark opens the Streak Detail view (Section 4) for that habit

### 3.3 Bottom navigation (redesign)
Four items, icon-only, pill-shaped active-state background:
1. **Flame icon** — Home (habit list) — active by default
2. **Medal icon** — Achievements/Badges screen (surfaces existing `MilestoneBadgesSheet` content as a dedicated tab if not already, or opens it)
3. **Plus icon** (center, visually emphasized — larger or in a filled circle) — Add habit
4. **Person icon** — Settings/Profile (opens `SettingsSheet`)

Active tab: filled/colored icon on a soft rounded pill background using the accent's `primaryContainer`. Inactive tabs: muted/outline icon.

### 3.4 Empty state (redesign)
When no habits exist:
- Centered dashed-outline circle containing a flame icon
- A small orange circular "+" button overlapping the bottom-right of the circle (tappable — opens add-habit flow)
- Below: bold "Tap Here To Start", then muted subtext "Create your first habit and start your journey."
- Background: faint decorative dot-matrix pattern (reuse `DotMatrixHeatmap` with randomized/static demo data at low opacity, or a simpler static decorative dot grid — purely visual, not real data)

---

## 4. New Screen: Streak Detail View

File: `lib/screens/streak_detail_screen.dart` (new) — opened as a full-screen route or a large modal bottom sheet when a `HabitCard` is tapped.

### Layout (top to bottom)
1. **Close/back button** top-right (X icon)
2. **Large flame icon** (outline style, tier-colored), centered
3. **"{N} Days Streak"** — large bold headline
4. **Motivational subtext** — dynamic based on progress toward next milestone, e.g. "Great job! Just {X} more days to earn your trophy." (calculate `X` as days remaining to next milestone tier from `streak_tiers.dart`)
5. **Weekly day-row**: `Sun Mon Tue Wed Thu Fri Sat` labels above a row of small flame icons — filled/colored flame for completed days this week, faint outline flame for not-yet-reached or missed days
6. **Stats row** (two stat blocks side by side):
   - "{goal} Days | Streak Goal" (the habit's `milestoneTarget`)
   - "{completed} Days | Completed"
7. **Time-invested line** (optional, only if the app tracks time-per-completion; otherwise omit — do not fabricate a metric the data model doesn't support): clock icon + "{N} Hours Well Spent On This Streak"
8. **Full `DotMatrixHeatmap`** — wider grid, more history visible than the card-mini version
9. **Bottom action row**: a full-width primary button ("Edit Streak" → opens habit edit flow) plus a secondary icon button (e.g. archive/export icon → opens backup/export for this habit, or omit if not applicable)

### Visual style
- Background: same gradient wash as the Home header (or a softer version of it) fading into the base dark theme lower on the screen
- Cards/stat blocks: white or light elevated surfaces, rounded, consistent with Home cards

---

## 5. Optional: Stats/Dashboard Screen Enhancements

Lower priority — only build after Sections 1–4 are done and verified.

Inspired by the desktop dashboard's *card-grid layout pattern* (not its specific widgets):

- **Analytics summary card**: a colored card showing a single headline stat, e.g. "Positive Habits: +58%" (percentage of habits with an active/growing streak vs. total) — visually similar to the dashboard's green "Positive Habits +58.2%" card
- **"Habits Wrapped" recap card**: a dark, celebratory card (confetti icon, bold "Habits Wrapped {year}" text, a "View" button) that opens a simple end-of-year/end-of-month recap summary (total completions, longest streak, most consistent habit). This is a nice-to-have engagement feature, not required for MVP polish.
- **Favorite habits chart**: you already have `weekday_analytics_chart.dart` — no need to rebuild; just consider restyling its container to match the new card-grid aesthetic (day-tab selector row above the chart, similar to the reference's `Fri 11 | Fri 12 | Fri 13...` tab row) if time allows.

Do not build: weather, Spotify integration, maps, or social proof cards — out of scope for this app.

---

## 6. Implementation Order

1. Add `Streak Orange` accent theme to `app_accent.dart`
2. Build `DotMatrixHeatmap` widget (mini + full variants)
3. Redesign `HabitCard` layout (Section 3.2)
4. Redesign Home screen header + empty state (Sections 3.1, 3.4)
5. Redesign bottom navigation (Section 3.3)
6. Build new `StreakDetailScreen` (Section 4)
7. Wire up card tap → navigate to `StreakDetailScreen`
8. (Optional, later) Stats/Dashboard card-grid enhancements (Section 5)

---

## 7. Constraints / Non-Goals

- Do not add user accounts, login, profile photos from a server, or any networked feature (weather, Spotify, maps) — the app is offline-only per its existing NFRs.
- Do not fabricate data fields the Hive model doesn't have (e.g. "hours spent") — only display metrics the app actually tracks. If a reference element needs data you don't store, either omit it or flag it back to me before building.
- Reuse existing tap-to-complete logic, haptics, and animation work from the prior UI polish pass — don't duplicate that logic inside the new card layout.
- Keep `flutter analyze` at 0 errors after each step; verify before moving to the next section.
- Test both the new `Streak Orange` theme and at least one existing theme (e.g. Neon Emerald) to confirm the new components adapt correctly to theme changes, not just the orange reference colors.
