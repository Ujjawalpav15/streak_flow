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
- **Non-Functional Requirements (NFR)**:
  - **NFR-1 Privacy & Storage**: 100% local device storage using Hive DB. No accounts, no servers, zero telemetry.
  - **NFR-2 Performance**: Instant state updates under 16ms (60 FPS rendering).
  - **NFR-3 Reliability**: Non-blocking startup, automatic Hive disk corruption recovery, and zero crash guarantees across app backgrounding, timezone shifts, and device restarts.

#### 2. System Architecture & Layered MVVM
```text
+---------------------------------------------------------------------------------+
|                                PRESENTATION LAYER                               |
| HomeScreen | StatsScreen | InteractiveMonthlyCalendar | WeekdayAnalyticsChart   |
| HabitCard | MilestoneBadgesSheet | CelebrationDialog | SettingsSheet            |
+---------------------------------------------------------------------------------+
                                      | (Riverpod Ref)
                                      v
+---------------------------------------------------------------------------------+
|                                APPLICATION LAYER                                |
|  HabitsNotifier (StateNotifier) | Category Filter | Search & Sort Providers    |
+---------------------------------------------------------------------------------+
                                      | (CRUD, Streak Logic & Backup)
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
- [x] **Loss Aversion Gaming Mechanics**:
  - Streak Flame Tiers: Ember (`🔥`), Plasma (`💜🔥`), Golden Crown (`🔱🔥`), Diamond (`💎🔥`), Mythic Ruby (`👑🔥`).
  - "Streak at Risk!" Warning Banner alerting users before midnight.
  - Duolingo-style Streak Freeze shields (`🧊 2 Freezes`) protecting missed streaks.
- [x] **Custom Emoji Keyboard System**: Integrated dual preset quick chips + custom emoji keyboard input field supporting 100% of Unicode compound emojis (skin tones, genders, activities).
- [x] **Milestone Unlock Badges**: Created `MilestoneBadgesSheet` for 7, 30, 50, and 100-day streaks.
- [x] **Confetti Celebration Particle Painter**: Built custom Flutter particle painter throwing celebratory confetti sparkles across the screen upon achieving milestone streaks.
- [x] **Interactive Monthly Grid Calendar**: Added month switcher (`‹ August 2026 ›`) with day history inspection bottom sheet.
- [x] **Day-of-Week Analytics Chart**: Built interactive bar chart displaying completion breakdown across Mon-Sun, highlighting the user's strongest day.
- [x] **Search & Multi-Mode Sorting**: Added search bar with instant real-time filtering and sort dropdown (*Default*, *Uncompleted First*, *Highest Streak*, *Longest Record*, *Alphabetical*).
- [x] **Offline Data Backup & Restore**: Export full habit history to clipboard as JSON, import/restore from JSON string.
- [x] **Local Push Notifications System**: Integrated `flutter_local_notifications` singleton `NotificationService` with Android 13+ permissions in `AndroidManifest.xml`, daily evening reminders, and on-demand test notifications.
- [x] **Code Quality & Verification**: 100% clean `flutter analyze` score (0 errors, 0 warnings).

---

## 🔥 Key Features Summary

1. **Snapchat / Duolingo Style Streak Tiers**:
   - 🟢 **1–6 Days**: Ember Flame (`🔥`)
   - 🟣 **7–29 Days**: Plasma Flame (`💜🔥`) — *First Spark Badge*
   - 🔱 **30–49 Days**: Golden Crown (`🔱🔥`) — *Monthly Warrior Badge*
   - 💎 **50–99 Days**: Diamond Cyan (`💎🔥`) — *Half-Century Legend Badge*
   - 👑 **100+ Days**: Mythic Ruby (`👑🔥`) — *Centurion Master Badge*
2. **Custom Emoji Selection**:
   - Select quick preset emojis or type/paste any custom emoji from your phone's native Gboard/Apple keyboard.
3. **Interactive Monthly Grid Calendar**:
   - Month switcher (`‹ August 2026 ›`) with day-by-day status indicators (`🧊` freeze, glowing completion markers). Tap any date cell to inspect habits completed on that date.
4. **Day-of-Week Analytics Chart**:
   - Displays completion breakdown across Monday through Sunday, highlighting your strongest day.
5. **"Streak at Risk!" Warning Banner**:
   - Automatically detects active streaks uncompleted in the evening and alerts you before midnight.
6. **Streak Freeze Shields (Duolingo Style)**:
   - Provides up to 2 freeze shields (`🧊`) per habit to protect streaks during unexpected life emergencies.
7. **Milestone Confetti Celebrations**:
   - Built-in particle painter confetti animations when reaching milestone streaks (7, 30, 50, 100 days).
8. **Offline JSON Backup & Restore**:
   - Copy full habit history to clipboard as JSON or restore from JSON string without external servers.

---

## 💡 Future Recommendations & Enhancement Roadmap

1. **Android Home Screen Widget (`home_widget` package)**:
   - Allow users to pin a StreakFlow widget on their Android home screen to check off daily habits without opening the app.
2. **Custom Reminder Time per Habit**:
   - Enable users to set custom reminder times (e.g. 7:30 AM Morning Exercise vs 9:00 PM Evening Reading) per habit.
3. **Haptic Feedback**:
   - Add subtle haptic vibration feedback when checking off a habit or applying a streak freeze.
4. **Theme Accent Color Picker**:
   - Allow users to customize app accent colors (Cyber Violet, Neon Emerald, Solar Amber, Midnight Ruby).

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
