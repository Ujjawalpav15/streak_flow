# ⚡ StreakFlow — Personal Habit Streak Tracker

**StreakFlow** is a sleek, modern, offline-first personal habit streak tracking application built with **Flutter**, **Riverpod**, **SharedPreferences**, and **Hive** for Android.

Designed around the psychological principle of **loss aversion** (similar to streak mechanics in Duolingo, Snapchat, and Clash Royale), StreakFlow motivates users to stay consistent with daily habits—like running, coding, studying, and exercising—by tapping into the desire not to break an active streak.

---

## 🎨 Design System & Theme Engine

### 1. Dynamic Light, Dark & System Theme Modes
StreakFlow includes a complete dynamic theme engine powered by Flutter `ThemeExtension<AppColorScheme>`:
- **Light Theme Mode**: Warm off-white backgrounds (`#FFF9F2`), crisp white surface cards, dark readable typography (`#2B2118`), and soft borders (`#F0E4D4`).
- **Dark Theme Mode**: Deep dark backgrounds (`#0B0E14`), surface elevation (`#161B26`), and high-contrast typography.
- **System Mode**: Follows system-wide dark/light preferences automatically.

### 2. Multiple Accent Theme Palettes
Customize the application accent color dynamically:
- 💜 **Cyber Violet** (`#8B5CF6`)
- 💚 **Neon Emerald** (`#10B981`)
- 💛 **Solar Amber** (`#F59E0B`)
- ❤️ **Midnight Ruby** (`#EF4444`)

---

## 👤 Comprehensive User Profile & Customization

- **Profile Customization**: Personalize your profile with your Name, Age, Short Bio, Main Habit Goal, and Profile Image using `image_picker`.
- **Top Bar Sync**: Your custom profile photo displays in the top-left header of the main dashboard for quick access to your profile.
- **Glassmorphic Progress & Streak Summary**:
  - **Daily Goal Progress**: Visual progress bar showing today's habit completion ratio & percentage badge.
  - **Live Metrics**: Active Streaks count (`🔥`), Peak Record (`🏆`), and Total Check-ins (`✅`).
- **Dedicated Settings & Data Page**: Accessible directly from the Profile page via a sleek chevron tile.

---

## 🏗️ Architecture & Layered Structure

```text
+---------------------------------------------------------------------------------+
|                                PRESENTATION LAYER                               |
| HomeScreen | StatsScreen | ProfileScreen | SettingsDataScreen                  |
| InteractiveMonthlyCalendar | WeekdayAnalyticsChart | MilestoneBadgesSheet       |
| HabitCard | CelebrationDialog | GlassmorphicStreakSummaryCard                   |
+---------------------------------------------------------------------------------+
                                      | (Riverpod Ref & Theme Extensions)
                                      v
+---------------------------------------------------------------------------------+
|                                DESIGN SYSTEM & THEMES                           |
| AppColors | AppColorScheme (Light & Dark) | AppTypography (Inter) | AppRadius    |
| AppSpacing | AppAccent (Cyber Violet, Neon Emerald, Solar Amber, Midnight Ruby) |
+---------------------------------------------------------------------------------+
                                      | (Riverpod State)
                                      v
+---------------------------------------------------------------------------------+
|                                APPLICATION LAYER                                |
| HabitsNotifier (StateNotifier) | UserProfileNotifier | AccentThemeNotifier      |
| ThemeModeNotifier | Search & Sort Providers                                    |
+---------------------------------------------------------------------------------+
                                      | (CRUD, Persistence & Streak Logic)
                                      v
+---------------------------------------------------------------------------------+
|                              DATA & DOMAIN LAYER                                |
| Habit Model (@HiveType) | UserProfile Model | Hive Box<Habit> | SharedPreferences |
| NotificationService | BackupService                                             |
+---------------------------------------------------------------------------------+
```

---

## 📝 Completed Features & Implementation Log

- [x] **Core Database & Persistence**: Hive database (`HabitAdapter`) storing habit ID, name, icon, current/longest streaks, completed dates, categories, and streak freezes.
- [x] **User Profile System**: Riverpod stateNotifier + SharedPreferences for profile name, age, bio, goal, and profile photo selection via `image_picker`.
- [x] **Glassmorphic Summary Card**: Replaced blocky stat squares with a sleek glassmorphic card with a daily completion progress bar, active streak count, and peak record metrics.
- [x] **Full Light & Dark Theme Support**: Dynamic theme system (`AppColorScheme`) supporting Light, Dark, and System Auto modes across every screen, widget, dialog, and bottom sheet.
- [x] **Multiple Accent Colors**: Swatch picker for Cyber Violet, Neon Emerald, Solar Amber, and Midnight Ruby accent themes.
- [x] **Dedicated Settings & Data Screen**: Pushed as a clean secondary screen containing theme options, backup tools, and test notifications.
- [x] **Loss Aversion Gaming Mechanics**:
  - Snapchat / Duolingo style flame tiers (Ember `🔥`, Plasma `💜🔥`, Golden Crown `🔱🔥`, Diamond `💎🔥`, Mythic Ruby `👑🔥`).
  - "Streak at Risk!" warning banner for uncompleted habits.
  - Streak Freeze shields (`🧊`) to protect missed streaks.
- [x] **Interactive Monthly Grid Calendar**: Month switcher with day history bottom sheet and completion/freeze markers.
- [x] **Day-of-Week Analytics Chart**: Mon–Sun completion breakdown chart highlighting your strongest day.
- [x] **Custom Emoji Keyboard System**: Quick preset chips + custom emoji keyboard input field.
- [x] **Milestone Unlock Badges & Confetti**: Staggered milestone cards (7, 30, 50, 100 days) + celebratory confetti overlay dialog.
- [x] **Search & Multi-Mode Sorting**: Real-time search + sorting (*Default*, *Uncompleted First*, *Highest Streak*, *Longest Record*, *Alphabetical*).
- [x] **Offline Data Backup & Restore**: Export full habit history as JSON string to clipboard; import and restore from JSON string.
- [x] **Local Push Notifications**: `flutter_local_notifications` daily evening reminders & on-demand test notifications.
- [x] **Clean Code Verification**: 100% clean `flutter analyze` score (0 errors, 0 warnings).

---

## 🔥 Key Features Summary

1. **Snapchat / Duolingo Style Streak Tiers**:
   - 🟢 **1–6 Days**: Ember Flame (`🔥`)
   - 🟣 **7–29 Days**: Plasma Flame (`💜🔥`) — *First Spark Badge*
   - 🔱 **30–49 Days**: Golden Crown (`🔱🔥`) — *Monthly Warrior Badge*
   - 💎 **50–99 Days**: Diamond Cyan (`💎🔥`) — *Half-Century Legend Badge*
   - 👑 **100+ Days**: Mythic Ruby (`👑🔥`) — *Centurion Master Badge*
2. **Dynamic Light & Dark Themes**:
   - Toggle seamlessly between Light Mode, Dark Mode, or System Auto with custom card surfaces, background colors, and typography readability.
3. **Personal User Profile & Photo**:
   - Edit name, age, short bio, and main habit goal. Upload a profile photo via `image_picker` synced across the profile and home header.
4. **Interactive Monthly Grid Calendar**:
   - Month switcher (`‹ August 2026 ›`) with day status indicators (`🧊` freeze, glowing completion markers). Tap any date cell to inspect habits completed on that date.
5. **Day-of-Week Analytics Chart**:
   - Staggered bar chart displaying completion breakdown across Monday through Sunday.
6. **"Streak at Risk!" Warning Banner**:
   - Automatically detects active streaks uncompleted in the evening and alerts you before midnight.
7. **Streak Freeze Shields (Duolingo Style)**:
   - Provides freeze shields (`🧊`) per habit to protect streaks during unexpected emergencies.
8. **Milestone Confetti Celebrations**:
   - Elastic bounce dialog with custom particle painter confetti animations when reaching milestone streaks (7, 30, 50, 100 days).
9. **Offline JSON Backup & Restore**:
   - Export full habit history to clipboard as JSON or restore from JSON string without external servers.

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

## 📜 License
Personal open-source habit tracking project. Built with Flutter.
