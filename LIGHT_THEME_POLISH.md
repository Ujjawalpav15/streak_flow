# StreakFlow — Light Theme & Visual Warmth Polish Spec

> Feed this to the coding agent. Adds a full Light theme mode (toggle in Settings) alongside the existing dark theme, and fixes the current dark theme feeling flat/"black and blue" by using accent gradients and warmer surface tones instead of plain dark-blue-gray everywhere.
>
> Reference: a cream/warm-toned mobile dashboard (rounded circular calendar day cells with orange progress rings, pill-shaped primary buttons, soft cream promo cards). This spec adapts the *style language*, not a literal 1:1 clone.

---

## 1. Add Light Theme Mode

### 1.1 Theme mode toggle
- Add a `ThemeMode` setting (System / Light / Dark) stored in the existing `settingsBox` (Hive), key: `themeMode`
- Add a segmented control or three-option picker in `SettingsSheet` (below or near the existing accent color picker) — options: "Light", "Dark", "System"
- Wire `MaterialApp`'s `themeMode` property in `main.dart` to this setting via the existing theme provider pattern (same provider style used for accent theme)
- Default to "Dark" if the setting has never been set (preserve current behavior for existing users)

### 1.2 Light theme color tokens
Add a `lightColorScheme` (or equivalent) alongside the existing dark tokens in `app_colors.dart`. Do not remove or rename existing dark tokens — add light equivalents with the same token names, switched via `Theme.of(context).brightness` or the existing color token access pattern.

| Token | Light value |
|---|---|
| background | `#FFF9F2` (warm cream, not pure white) |
| surface (cards) | `#FFFFFF` |
| surfaceVariant | `#FFF3E6` |
| onSurface (primary text) | `#2B2118` (warm dark brown-black, not pure black) |
| onSurfaceMuted | `#8A7B6C` |
| onSurfaceDim | `#B5A899` |
| divider/outline | `#F0E4D4` |

Each accent theme (Cyber Violet, Neon Emerald, Solar Amber, Midnight Ruby, Streak Orange if built) should still apply its `primary`/`glow`/`gradient` colors on top of whichever base (light or dark) is active — accent choice and light/dark mode are independent settings, not tied together.

### 1.3 Component-level light adjustments
- Cards: white surface, soft drop shadow (`0 2px 8px rgba(0,0,0,0.06)`) instead of the dark theme's glow-based elevation
- Status bar / app bar icons: switch to dark icons on light background (check `SystemUiOverlayStyle`)
- Empty states, dot-matrix heatmap `inactiveColor`: needs a light-appropriate faint tone (e.g. `onSurfaceDim` at low opacity) rather than the dark theme's version — the heatmap should not use a hardcoded dark-only inactive color

---

## 2. Fix "flat black and blue" feeling in the existing Dark theme

This is independent of the light theme work — apply regardless of which mode is active when Dark is selected.

- Audit current dark surface colors: if cards/backgrounds are using a flat blue-gray (e.g. Material default dark surface), replace with a warmer neutral dark tone — e.g. background `#12100E`, surface `#1C1917` (warm near-black, slight brown undertone) instead of blue-tinted grays
- Increase use of the **accent gradient** (already defined per theme in `app_accent.dart`) on the header and key CTA buttons, rather than flat solid accent color — this is likely already partially done from the earlier header work; extend the same gradient treatment to the primary "Add Habit"/"New Habit" button and any other primary CTA
- Card elevation in dark mode should read as a **subtle glow** in the accent color at low opacity (e.g. `accent.primary.withOpacity(0.06)` box-shadow) rather than a flat solid border — reinforces the "gamified/energetic" feel rather than a generic dark admin panel look

---

## 3. Calendar day cells — circular ring style (Stats screen)

In `interactive_monthly_calendar.dart`, redesign day cells to match the reference's circular treatment:
- Each day cell is a circle (not a square/rounded-rect)
- Days with a completed habit: circle filled or ringed in the accent primary color (use a colored ring/outline for partial completion, filled circle for full completion if the day tracks multiple habits — otherwise just filled for single-habit completion)
- Today's date: distinct treatment (e.g. solid filled accent circle) regardless of completion status, matching the reference's "30" highlighted cell
- Non-current-month days (if shown): muted/faded circles
- Keep existing month-switch navigation and tap-to-inspect-day behavior — only change the visual cell style, not the interaction logic

---

## 4. Primary CTA buttons — pill style

Update primary action buttons (Add Habit, Save, Edit Streak, etc.) to:
- Full pill shape (`borderRadius: 999`)
- Filled with accent gradient (light mode) or accent gradient at appropriate opacity (dark mode)
- Bold, centered label text with adequate padding (don't let buttons feel cramped)

Apply consistently — don't redesign one button and leave others in the old style.

---

## 5. Implementation Order (keep each step small and verifiable)

1. Add `lightColorScheme` tokens to `app_colors.dart` (no UI changes yet, just the token definitions)
2. Add `themeMode` setting + toggle UI in `SettingsSheet`, wire to `MaterialApp` in `main.dart`
3. Test switching Light/Dark/System — confirm base surfaces/text switch correctly app-wide before styling further
4. Fix dark theme's flat blue-gray surfaces → warm dark tones (Section 2)
5. Redesign calendar day cells to circular ring style (Section 3)
6. Redesign primary CTA buttons to pill/gradient style (Section 4)
7. Fix `DotMatrixHeatmap`'s `inactiveColor` to adapt to light/dark mode instead of being hardcoded

Run `flutter analyze` after each step. Test both Light and Dark mode after step 3 before proceeding — a broken light theme is easy to miss if you only ever test in dark.

---

## 6. Constraints / Non-Goals

- Don't remove the dark theme or make light the default — dark stays default per Section 1.1.
- Don't couple light/dark mode to accent theme selection — they must be independent settings.
- Don't rebuild the calendar's data logic, month navigation, or day-inspection bottom sheet — visual cell style only.
- Keep `flutter analyze` clean after every step.
