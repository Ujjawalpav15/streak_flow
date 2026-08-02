import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class BackupService {
  static String exportHabitsToJson(Box<Habit> box) {
    final habitsList = box.values.map((habit) {
      return {
        'id': habit.id,
        'name': habit.name,
        'icon': habit.icon,
        'currentStreak': habit.currentStreak,
        'longestStreak': habit.longestStreak,
        'completedDates': habit.completedDates
            .map((d) => d.toIso8601String())
            .toList(),
        'category': habit.category,
        'freezeCount': habit.freezeCount,
        'frozenDates': habit.frozenDates
            .map((d) => d.toIso8601String())
            .toList(),
      };
    }).toList();

    final data = {
      'app': 'StreakFlow',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habitsList,
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<int> importHabitsFromJson(
      Box<Habit> box, String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> habitsList = data['habits'] ?? [];

    int count = 0;
    for (final item in habitsList) {
      final id = item['id'] as String;
      final name = item['name'] as String;
      final icon = item['icon'] as String;
      final currentStreak = (item['currentStreak'] as int?) ?? 0;
      final longestStreak = (item['longestStreak'] as int?) ?? 0;
      final category = (item['category'] as String?) ?? 'General';
      final freezeCount = (item['freezeCount'] as int?) ?? 2;

      final completedDates = ((item['completedDates'] as List?) ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList();

      final frozenDates = ((item['frozenDates'] as List?) ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList();

      final habit = Habit(
        id: id,
        name: name,
        icon: icon,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        completedDates: completedDates,
        category: category,
        freezeCount: freezeCount,
        frozenDates: frozenDates,
      );

      await box.put(id, habit);
      count++;
    }
    return count;
  }
}
