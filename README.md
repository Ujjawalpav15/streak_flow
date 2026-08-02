# ⚡ Streak Flow (streak_app)

A sleek, modern, offline-first Habit & Streak Tracker built with Flutter. Keep track of your daily habits, build long-term consistency, and visualize your progress with clean statistics and GitHub-style heatmaps.

---

## 📱 Features

- **Habit Tracking & Daily Check-ins**: Easily toggle daily habit completion with full-card tap gestures and smooth animations.
- **Dynamic Streak Calculation**: Automatically calculates current consecutive streaks and tracks your all-time longest streaks.
- **Midnight & Daylight-Saving Resilient**: Re-computes streaks on app resume and normalizes dates to UTC to prevent broken streaks across time zones.
- **Visual Analytics & Heatmaps**: Integrated completion heatmaps (`flutter_heatmap_calendar`) with explicit 90-day scrollable ranges to visualize your consistency over time.
- **Fast Offline Storage**: Powered by Hive for lightning-fast, zero-delay local persistence with safe adapter registration checks.
- **Dark Mode UI**: Designed with a modern, dark aesthetic with deep purple accents, full emoji support (including complex skin tone compound emojis), and input validation.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter SDK](https://flutter.dev) (Dart ^3.10.3)
- **State Management**: [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod) (`StateNotifierProvider`, `ConsumerWidget`)
- **Local Database**: [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter)
- **Heatmap Calendar**: [flutter_heatmap_calendar](https://pub.dev/packages/flutter_heatmap_calendar)
- **Utilities**: `uuid`, `intl`

### 📂 Directory Structure

```text
lib/
├── main.dart             # Entry point, Hive init (isAdapterRegistered check) & lifecycle listener
├── models/               # Hive Data Models
│   ├── habit.dart        # Habit model (@HiveType)
│   └── habit.g.dart      # Auto-generated Hive Adapter
├── providers/            # Riverpod State Management
│   └── habit_provider.dart # HabitNotifier for CRUD & streak calculation algorithms
├── screens/              # App Screens & Views
│   ├── home_screen.dart  # Habits dashboard, input validation dialog, emoji picker support
│   └── stats_screen.dart # Detailed statistics, badges & 90-day heatmaps
└── widgets/              # Reusable UI Widgets
    └── habit_card.dart   # Card widget (full-card tap toggle, long-press delete gesture)
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.10.3 or higher)
- Dart SDK
- Android Studio / Xcode / VS Code with Flutter extension

### Installation & Setup

1. **Navigate to the project directory:**
   ```bash
   cd streak_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters (if modifying models):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📊 Project Progress & Bug Fix Log

- [x] **Hive Adapter Safety Check**: Added `if (!Hive.isAdapterRegistered(0))` in `main.dart` to prevent hot restart crashes.
- [x] **Emoji Truncation Fix**: Increased `maxLength` on emoji input in `HomeScreen` to allow compound emojis (e.g. 🏃‍♀️, 🏋️‍♂️).
- [x] **Dialog Validation**: Added input error validation in `Add Habit` dialog when the name field is empty.
- [x] **Touch Target Enhancement**: Expanded `HabitCard` tap area so tapping anywhere on the card toggles completion, and long pressing anywhere opens the delete dialog.
- [x] **HeatMap Range Boundary**: Configured `startDate` (90 days prior) and `endDate` (today) in `StatsScreen` for stable rendering.
- [x] Local storage setup with Hive (`HabitAdapter`)
- [x] Riverpod state management setup
- [x] Habit CRUD (Create, Read, Delete)
- [x] Dynamic streak calculation algorithm (current & longest streak)
- [x] Date normalization (UTC day difference handling)
- [x] App lifecycle observer for auto-refreshing expired streaks on resume
- [ ] Habit Editing (Edit Name/Icon)
- [ ] Daily Push Reminders & Notifications (`flutter_local_notifications` integration)
- [ ] "Streak Freeze" / Grace Days system
- [ ] Milestone Celebrations & Badges (Confetti animations)
- [ ] Custom habit schedules (Flexible days/week)
- [ ] Habit Categories / Tags & Filters
- [ ] Data Export/Import (JSON / CSV backup)

---

## 💡 Planned Roadmap & Unique Features

1. **Habit Editing**: Edit existing habit title, emoji, and select custom accent colors per habit.
2. **Notifications & Reminders**: Implement scheduled daily reminders using `flutter_local_notifications`.
3. **Streak Freeze System**: Allow 1-2 grace days per month so emergencies don't destroy long streaks.
4. **Milestone Confetti & Badges**: Trigger particle/confetti animations upon reaching streak milestones (7, 30, 100 days).
5. **Flexible Frequencies**: Allow weekly target goals (e.g. 3x per week) or specific active days (e.g., Weekdays only).
