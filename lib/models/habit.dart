import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late int currentStreak;

  @HiveField(4)
  late int longestStreak;

  @HiveField(5)
  late List<DateTime> completedDates;

  @HiveField(6)
  late String category;

  @HiveField(7)
  late int freezeCount;

  @HiveField(8)
  late List<DateTime> frozenDates;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    this.currentStreak = 0,
    this.longestStreak = 0,
    List<DateTime>? completedDates,
    this.category = 'General',
    this.freezeCount = 2,
    List<DateTime>? frozenDates,
  })  : completedDates = completedDates ?? [],
        frozenDates = frozenDates ?? [];

  /// Flame emoji & tier label based on streak length (Loss Aversion Gaming Mechanics)
  String get streakFlameIcon {
    if (currentStreak >= 100) return '👑🔥'; // Mythic Cosmic
    if (currentStreak >= 50) return '💎🔥';  // Diamond
    if (currentStreak >= 30) return '🔱🔥';  // Gold
    if (currentStreak >= 7) return '💜🔥';   // Plasma
    if (currentStreak >= 1) return '🔥';     // Ember
    return '❄️';                             // Inactive
  }

  /// Color palette associated with current streak tier
  Color get streakColor {
    if (currentStreak >= 100) return const Color(0xFFF43F5E); // Mythic Ruby
    if (currentStreak >= 50) return const Color(0xFF06B6D4);  // Diamond Cyan
    if (currentStreak >= 30) return const Color(0xFFF59E0B);  // Gold
    if (currentStreak >= 7) return const Color(0xFFA855F7);   // Purple Plasma
    if (currentStreak >= 1) return const Color(0xFFFF6B00);   // Neon Orange
    return Colors.grey.shade600;
  }

  /// Tier Title
  String get streakTierTitle {
    if (currentStreak >= 100) return 'Centurion Master';
    if (currentStreak >= 50) return 'Half-Century Legend';
    if (currentStreak >= 30) return 'Monthly Warrior';
    if (currentStreak >= 7) return 'First Spark';
    if (currentStreak >= 1) return 'Building Momentum';
    return 'Start Your Streak';
  }
}