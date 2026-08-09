# 📘 StreakFlow — Technical Documentation & Project Details

> **Project Name**: StreakFlow — Personal Habit Streak & Behavioral Consistency Tracker  
> **Framework**: Flutter (Dart `^3.10.3`)  
> **Architecture**: Clean Layered Architecture + Riverpod State Management  
> **Database**: Hive NoSQL (`hive: ^2.2.3`) & SharedPreferences  
> **Target Platform**: Android & iOS  

---

## 📋 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Psychological Foundation: Loss Aversion in Habit Tracking](#2-psychological-foundation-loss-aversion-in-habit-tracking)
3. [System Architecture & Layer Breakdown](#3-system-architecture--layer-breakdown)
4. [State Management Architecture (Riverpod)](#4-state-management-architecture-riverpod)
5. [Data Models & Local Storage (Hive & SharedPreferences)](#5-data-models--local-storage-hive--sharedpreferences)
6. [Design System & Dynamic Theme Engine](#6-design-system--dynamic-theme-engine)
7. [Feature Specification & Workflow Protocols](#7-feature-specification--workflow-protocols)
8. [Notification & Backup Pipeline](#8-notification--backup-pipeline)
9. [Brand Identity & Visual Asset Pipeline](#9-brand-identity--visual-asset-pipeline)
10. [Verification, Benchmarks & Code Health](#10-verification-benchmarks--code-health)
11. [Future Roadmap & Project Expansion](#11-future-roadmap--project-expansion)

---

## 1. Executive Summary

**StreakFlow** is an offline-first, privacy-focused mobile application built to tackle habit drop-off and inconsistency. Traditional habit trackers often suffer from low long-term engagement because completing a task daily feels like an isolated chore. StreakFlow transforms habit building into an engaging experience by utilizing **streak mechanics**, **visual flame evolution**, **streak protection shields**, **milestone unlock rewards**, and **visual analytics**.

By running 100% locally with Hive NoSQL database and SharedPreferences, StreakFlow requires no cloud account setup, internet connectivity, or data collection—ensuring absolute privacy and instant app performance.

---

## 2. Psychological Foundation: Loss Aversion in Habit Tracking

### 2.1 The Loss Aversion Principle
In behavioral economics, **loss aversion** refers to the cognitive bias where the psychological pain of losing something is twice as powerful as the pleasure of gaining it.

### 2.2 Application in StreakFlow
1. **Streak Tiers & Progression**: As a user's streak increases, their habit evolves through visual flame tiers:
   - **Ember (`🔥`)**: 1–6 Days — Initial momentum spark.
   - **Plasma (`💜🔥`)**: 7–29 Days — Unlocks *First Spark Badge*.
   - **Golden Crown (`🔱🔥`)**: 30–49 Days — Unlocks *Monthly Warrior Badge*.
   - **Diamond (`💎🔥`)**: 50–99 Days — Unlocks *Half-Century Legend Badge*.
   - **Mythic Ruby (`👑🔥`)**: 100+ Days — Unlocks *Centurion Master Badge*.

2. **The "Streak at Risk!" Urgency Factor**:
   If an active habit (`streak > 0`) is uncompleted by evening hours, a warning banner appears on the dashboard along with a push notification, leveraging loss aversion to prompt completion before midnight.

3. **Streak Freeze Shields (`🧊`)**:
   Users can apply a Streak Freeze shield to safeguard their hard-earned active streak during unexpected life emergencies, illness, or rest days.

---

## 3. System Architecture & Layer Breakdown

StreakFlow is structured into four distinct, loosely coupled layers to guarantee maintainability, testability, and clean code separation:

```text
+---------------------------------------------------------------------------------+
|                                PRESENTATION LAYER                               |
| SplashScreen | HomeScreen | StatsScreen | ProfileScreen | SettingsDataScreen   |
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

## 4. State Management Architecture (Riverpod)

State management is powered by **Riverpod (`flutter_riverpod: ^2.5.1`)**, ensuring immutable state flow, compile-time safety, and reactivity across all widgets.

### Key Providers:
* `habitsProvider` (`StateNotifierProvider<HabitsNotifier, List<Habit>>`):
  Manages complete habit CRUD operations, check-in toggles, streak incrementation, streak freeze application, and midnight refresh algorithms.
* `userProfileProvider` (`StateNotifierProvider<UserProfileNotifier, UserProfile>`):
  Manages user profile data (name, age, bio, goal, photo path) synchronized with `SharedPreferences`.
* `accentThemeProvider` (`StateNotifierProvider<AccentThemeNotifier, AppAccent>`):
  Controls active accent swatch (`Cyber Violet`, `Neon Emerald`, `Solar Amber`, `Midnight Ruby`).
* `themeModeProvider` (`StateNotifierProvider<ThemeModeNotifier, ThemeMode>`):
  Manages Light, Dark, or System theme mode preferences.
* `searchedAndSortedHabitsProvider` (`Provider<List<Habit>>`):
  Combines search query state and sort option selection (*Default*, *Uncompleted First*, *Highest Streak*, *Longest Record*, *Alphabetical*).

---

## 5. Data Models & Local Storage (Hive & SharedPreferences)

### 5.1 Hive Model: `Habit` (`typeId: 0`)

```dart
@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final String icon;
  @HiveField(3) final int currentStreak;
  @HiveField(4) final int longestStreak;
  @HiveField(5) final List<String> completedDates; // YYYY-MM-DD format
  @HiveField(6) final String category;
  @HiveField(7) final int streakFreezes;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.completedDates,
    this.category = 'General',
    this.streakFreezes = 1,
  });
}
```

### 5.2 Key-Value SharedPreferences Storage
* `user_profile_name`: String
* `user_profile_age`: String
* `user_profile_bio`: String
* `user_profile_goal`: String
* `user_profile_image`: String (local file URI)
* `app_accent_name`: String (`Cyber Violet`, `Neon Emerald`, `Solar Amber`, `Midnight Ruby`)
* `app_theme_mode`: String (`light`, `dark`, `system`)

---

## 6. Design System & Dynamic Theme Engine

StreakFlow includes a complete custom design system constructed with Flutter `ThemeExtension`:

### 6.1 Color Palettes
* **Dark Theme (`AppColorScheme.dark`)**:
  - Background: `#0B0E14`
  - Surface Card: `#161B26`
  - Surface Variant: `#1C2230`
  - Text Primary: `#FFFFFF`
  - Outline: `Colors.white12`
* **Light Theme (`AppColorScheme.light`)**:
  - Background: `#FFF9F2` (Warm Off-White)
  - Surface Card: `#FFFFFF` (Crisp White)
  - Surface Variant: `#FFF3E6`
  - Text Primary: `#2B2118`
  - Outline: `#F0E4D4`

### 6.2 Accent Swatches (`AppAccent`)
* **Cyber Violet**: `#8B5CF6` (Glow: `#A78BFA`, Gradient: `#7C3AED` -> `#C084FC`)
* **Neon Emerald**: `#10B981` (Glow: `#34D399`, Gradient: `#059669` -> `#6EE7B7`)
* **Solar Amber**: `#F59E0B` (Glow: `#FBBF24`, Gradient: `#D97706` -> `#FCD34D`)
* **Midnight Ruby**: `#EF4444` (Glow: `#F87171`, Gradient: `#B91C1C` -> `#FCA5A5`)

### 6.3 Typography & Geometry
* **Font Family**: Google Fonts Inter (`GoogleFonts.interTextTheme`)
* **Card Border Radius**: `AppRadius.cardRadius` (16px)
* **Pill Radius**: `AppRadius.pill` (100px)

---

## 7. Feature Specification & Workflow Protocols

1. **Habit Creation Workflow**:
   Users enter a habit name, select or input an emoji icon, select a category chip, and initialize a 0-day habit with 1 default Streak Freeze shield (`🧊`).

2. **Daily Check-in & Streak Increment**:
   Toggling check-in registers today's date (`YYYY-MM-DD`). If yesterday was completed, `currentStreak` increments by 1. If `currentStreak` exceeds `longestStreak`, `longestStreak` updates automatically.

3. **Milestone Celebrations**:
   When reaching 7, 30, 50, or 100 days, a celebration dialog triggers featuring elastic bounce animations and custom particle confetti graphics.

4. **Interactive Heatmap Calendar**:
   Monthly grid display with month navigation buttons. Dates are color-coded based on completion status or freeze shields used. Tap any cell to view detailed habit history for that day.

---

## 8. Notification & Backup Pipeline

### 8.1 Local Notification Service (`flutter_local_notifications`)
* Schedules evening push reminders automatically.
* Provides a **Test Notification Button** inside Settings & Data screen to verify system alert delivery.

### 8.2 JSON Backup & Restore Protocol
* **Export**: Serializes all habits from Hive box into a structured JSON string and copies directly to the system clipboard.
* **Import**: Validates JSON string format, updates Hive storage, and triggers a full state refresh across all Riverpod listeners.

---

## 9. Brand Identity & Visual Asset Pipeline

* **Brand Logo SVG (`assets/images/app_logo.svg`)**:
  512×512 clean vector artwork featuring an Ember Flame shell, Cyber Violet flow ribbon, and an Emerald Green completion badge on a dark square canvas.
* **Native App Launcher Icon (`assets/images/app_logo.png`)**:
  512×512 PNG asset compiled via `flutter_launcher_icons` into all native Android density buckets (`mipmap-hdpi` to `mipmap-xxxhdpi`) and iOS AppIcon catalog.
* **Splash Screen (`lib/screens/splash_screen.dart`)**:
  Single-phase startup screen with ambient logo glow, progress bar, and automatic navigation to `HomeScreen`.

---

## 10. Verification, Benchmarks & Code Health

* **Clean Code Score**: 100% clean `flutter analyze` score (**0 errors, 0 warnings**).
* **Database Initialization Safety**: Wrapped inside a fallback recovery block to prevent startup crashes.
* **Asset Verification**: All assets registered inside `pubspec.yaml`.

---

## 11. Future Roadmap & Project Expansion

1. **Per-Habit Custom Notification Timers**: Allow individual reminder schedules per habit.
2. **Streak Shop & Inventory**: Spend earned streak coins on freeze shields or theme customizations.
3. **Home Screen Widgets (`home_widget`)**: Interactive Android/iOS home screen widget for 1-tap check-ins.
4. **Cloud Backup Sync**: Supabase / Firebase integration for optional cross-device synchronization.

---
*Documentation generated for StreakFlow v1.0.0 Project Release & Submission.*
