# ⚡ StreakFlow — Personal Habit Streak Tracker

**StreakFlow** is a sleek, modern, offline-first personal habit streak tracking application built with **Flutter**, **Riverpod**, and **Hive** for Android.

Designed around the psychological principle of **loss aversion** (similar to streak mechanics in Duolingo, Snapchat, and Clash Royale), StreakFlow motivates users to stay consistent with daily habits—like running, coding, studying, and exercising—by tapping into the desire not to break an active streak.

---

## 🎓 Academic Project Context (ENEX 386)

This project serves as the semester implementation for **ENEX 386: Software Systems Engineering**. It adheres to rigorous software engineering standards, featuring modular architecture, offline-first persistence, JSON backup & restore capabilities, comprehensive test specifications, and academic documentation.

### 📄 Academic & Software Engineering Documentation

#### 1. Software Requirements Specification (SRS) Highlights
- **User Personas**: Self-motivated individuals, students, developers, and fitness enthusiasts seeking distraction-free, offline habit consistency.
- **Functional Requirements (FR)**:
  - **FR-1**: Offline Habit CRUD operations with custom names, custom keyboard emojis + quick presets, categories, search, and multi-mode sorting.
  - **FR-2**: Dynamic streak calculation algorithm with UTC day normalization.
  - **FR-3**: Loss aversion triggers ("Streak at Risk!" warning banner & push notifications).
  - **FR-4**: Duolingo-style "Streak Freeze" shield mechanics (`🧊`) to protect streaks during emergencies.
  - **FR-5**: Interactive Monthly Grid Calendar with day history inspection, Day-of-Week breakdown chart, 90-day heatmap, and milestone unlock badges (7, 30, 50, 100 days).
  - **FR-6**: Local JSON Data Backup & Restore for offline data portability.
  - **FR-7**: Local Push Notification system (`flutter_local_notifications`) with non-blocking startup & permission handling.
  - **FR-8**: Gamified Design System with 4 accent themes (Cyber Violet, Neon Emerald, Solar Amber, Midnight Ruby), micro-animations, tier-based glow effects, and haptic feedback.
- **Non-Functional Requirements (NFR)**:
  - **NFR-1 Privacy & Storage**: 100% local device storage using Hive DB. No accounts, no servers, zero telemetry.
  - **NFR-2 Performance**: Instant state updates under 16ms (60 FPS rendering) with smooth non-blocking micro-animations.
  - **NFR-3 Reliability**: Non-blocking startup, automatic Hive disk corruption recovery, and zero crash guarantees across app backgrounding, timezone shifts, and device restarts.

#### 2. System Architecture & Layered MVVM
```text
+---------------------------------------------------------------------------------+
|                                PRESENTATION LAYER                               |
| HomeScreen | StatsScreen | InteractiveMonthlyCalendar | WeekdayAnalyticsChart   |
| HabitCard | MilestoneBadgesSheet | CelebrationDialog | SettingsSheet            |
+---------------------------------------------------------------------------------+
                                      | (Riverpod Ref & Design Tokens)
                                      v
+---------------------------------------------------------------------------------+
|                                DESIGN SYSTEM & THEME                            |
| AppColors | AppTypography (Inter) | AppSpacing | AppRadius | AppAccent | Tiers   |
+---------------------------------------------------------------------------------+
                                      | (Riverpod State)
                                      v
+---------------------------------------------------------------------------------+
|                                APPLICATION LAYER                                |
|  HabitsNotifier (StateNotifier) | AccentThemeNotifier | Search & Sort Providers |
+---------------------------------------------------------------------------------+
                                      | (CRUD, Streak Logic & Persistence)
                                      v
+---------------------------------------------------------------------------------+
|                              DATA & DOMAIN LAYER                                |
| Habit Model (@HiveType) | Hive Box<Habit> | NotificationService | BackupService |
+---------------------------------------------------------------------------------+
```

---

## 📝 Complete Progress Tracking Log

- [x] **Core Database & Models**: Implemented Hive database (`HabitAdapter`) with `@HiveType(typeId: 0)` storing ID, name, icon, current streak, longest streak, completed dates, category, freeze count, and frozen dates.
- [x] **Bulletproof Non-Blocking Startup**: Configured `main.dart` with automatic Hive disk corruption recovery and non-blocking asynchronous notification initialization to guarantee zero black screens.
- [x] **Design System Token Architecture**:
  - `AppColors` — Semantic tokens for backgrounds, surfaces, and warning gradients.
  - `AppTypography` — Typography scale built on Google Fonts **Inter** with `tabularFigures` support for jitter-free streak counters.
  - `AppSpacing` — 4-pixel grid spacing scale (`xs=4` through `xxxl=48`).
  - `AppRadius` — Consistent corner radii (`card=12`, `sheet=20`, `pill=999`).
  - `StreakTiers` — Tier color, glow, and emoji mapping helpers.
- [x] **Multiple Accent Theme System**: Built `ThemeExtension<AppAccent>` with 4 vibrant palettes:
  - 💜 **Cyber Violet** (`#8B5CF6`)
  - 💚 **Neon Emerald** (`#10B981`)
  - 💛 **Solar Amber** (`#F59E0B`)
  - ❤️ **Midnight Ruby** (`#EF4444`)
  - Persisted in Hive settings box with interactive swatch picker in Settings.
- [x] **Loss Aversion Gaming Mechanics**:
  - Streak Flame Tiers: Ember (`🔥`), Plasma (`💜🔥`), Golden Crown (`🔱🔥`), Diamond (`💎🔥`), Mythic Ruby (`👑🔥`).
  - "Streak at Risk!" Warning Banner alerting users before midnight.
  - Duolingo-style Streak Freeze shields (`🧊 2 Freezes`) protecting missed streaks.
- [x] **Interactive Micro-Interactions & Haptics**:
  - `HapticFeedback.mediumImpact()` on tap.
  - 150ms Scale-bounce spring animation on `HabitCard`.
  - Staggered card entrance animations on `HomeScreen`.
- [x] **Custom Emoji Keyboard System**: Integrated dual preset quick chips + custom emoji keyboard input field supporting 100% of Unicode compound emojis.
- [x] **Milestone Unlock Badges & Confetti**:
  - `MilestoneBadgesSheet` for 7, 30, 50, and 100-day streaks with staggered slide-in cards.
  - `CelebrationDialog` with elastic bounce entrance and accent particle confetti overlay.
- [x] **Interactive Monthly Grid Calendar**: Added month switcher (`‹ August 2026 ›`) with animated transitions, accent color interpolation, and day history bottom sheet.
- [x] **Day-of-Week Analytics Chart**: Built bar chart with staggered grow-in animations displaying completion breakdown across Mon-Sun.
- [x] **Search & Multi-Mode Sorting**: Added real-time search and multi-mode sort dropdown (*Default*, *Uncompleted First*, *Highest Streak*, *Longest Record*, *Alphabetical*).
- [x] **Offline Data Backup & Restore**: Export full habit history to clipboard as JSON, import/restore from JSON string.
- [x] **Local Push Notifications System**: Integrated `flutter_local_notifications` singleton `NotificationService` with Android 13+ permissions, daily evening reminders, and on-demand test notifications.
- [x] **Code Quality & Verification**: 100% clean `flutter analyze` score (0 errors, 0 warnings, 0 info hints).

---

## 🔥 Key Features Summary

1. **Snapchat / Duolingo Style Streak Tiers**:
   - 🟢 **1–6 Days**: Ember Flame (`🔥`)
   - 🟣 **7–29 Days**: Plasma Flame (`💜🔥`) — *First Spark Badge*
   - 🔱 **30–49 Days**: Golden Crown (`🔱🔥`) — *Monthly Warrior Badge*
   - 💎 **50–99 Days**: Diamond Cyan (`💎🔥`) — *Half-Century Legend Badge*
   - 👑 **100+ Days**: Mythic Ruby (`👑🔥`) — *Centurion Master Badge*
2. **Multiple Accent Themes & Swatch Picker**:
   - Switch between Cyber Violet, Neon Emerald, Solar Amber, and Midnight Ruby accent themes with animated glow swatches.
3. **Custom Emoji Selection**:
   - Select quick preset emojis or type/paste any custom emoji from your native keyboard.
4. **Interactive Monthly Grid Calendar**:
   - Month switcher (`‹ August 2026 ›`) with day-by-day status indicators (`🧊` freeze, glowing completion markers). Tap any date cell to inspect habits completed on that date.
5. **Day-of-Week Analytics Chart**:
   - Staggered bar chart displaying completion breakdown across Monday through Sunday, highlighting your strongest day.
6. **"Streak at Risk!" Warning Banner**:
   - Automatically detects active streaks uncompleted in the evening and alerts you before midnight.
7. **Streak Freeze Shields (Duolingo Style)**:
   - Provides up to 2 freeze shields (`🧊`) per habit to protect streaks during unexpected life emergencies.
8. **Milestone Confetti Celebrations**:
   - Elastic bounce dialog with custom particle painter confetti animations when reaching milestone streaks (7, 30, 50, 100 days).
9. **Offline JSON Backup & Restore**:
   - Copy full habit history to clipboard as JSON or restore from JSON string without external servers.

---

## 💡 Future Recommendations & Enhancement Roadmap

1. **Android Home Screen Widget (`home_widget` package)**:
   - Allow users to pin a StreakFlow widget on their Android home screen to check off daily habits without opening the app.
2. **Custom Reminder Time per Habit**:
   - Enable users to set custom reminder times (e.g. 7:30 AM Morning Exercise vs 9:00 PM Evening Reading) per habit.
3. **Streak Sharing Image Generator**:
   - Generate shareable milestone badge card graphics to export to social media.

---

## 🚀 Getting Started & Installation

### Prerequisites
- [Flutter SDK](https://flutter.dev) (`>=3.10.3`)
- Dart SDK
- Android Studio / VS Code with Flutter extension

### Build & Run Instructions

1. **Navigate to Project Directory:**
   ```bash
   cd streak_app
   ```

2. **Fetch Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters (If modifying models):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Launch on Connected Android Device or Emulator:**
   ```bash
   flutter run
   ```

---

## 🧪 Verification & Testing Suite

- **Unit Tests**: Test `_updateStreak()` streak calculation logic across consecutive days, missed days, and leap years.
- **State Tests**: Verify Riverpod `HabitNotifier` state updates on habit completion, edit, and deletion.
- **Backup Tests**: Verify JSON serializer and deserializer integrity.
- **Lifecycle Edge Cases**: Validate app resume behaviour when passing midnight.

---

## 📜 License & Academic Attribution
Created for **ENEX 386 Software Systems Engineering**. Open source for personal study and habit building.
