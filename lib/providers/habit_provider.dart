import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

final habitBoxProvider = Provider<Box<Habit>>((ref) {
  return Hive.box<Habit>('habits');
});

final habitsProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final box = ref.watch(habitBoxProvider);
  return HabitNotifier(box);
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  final Box<Habit> _box;

  HabitNotifier(this._box) : super(_box.values.toList());

  void addHabit(String name, String icon) {
    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
    );
    _box.put(habit.id, habit);
    state = _box.values.toList();
  }

void toggleHabit(String id) {
  final habit = _box.get(id);
  if (habit == null) return;

  final today = DateTime.now();
  final alreadyDone = habit.completedDates.any((d) =>
      d.year == today.year && d.month == today.month && d.day == today.day);

  if (alreadyDone) {
    // Undo — remove today's completion
    habit.completedDates.removeWhere((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
  } else {
    // Complete — add today
    habit.completedDates.add(today);
  }

  _updateStreak(habit);
  habit.save();
  state = _box.values.toList();
}

void _updateStreak(Habit habit) {
  if (habit.completedDates.isEmpty) {
    habit.currentStreak = 0;
    return;
  }

  final dates = habit.completedDates
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  // If most recent completion isn't today or yesterday, streak is 0
  final today = DateTime.now();
  final todayNormalized = DateTime(today.year, today.month, today.day);
  final diff = todayNormalized.difference(dates.first).inDays;
  if (diff > 1) {
    habit.currentStreak = 0;
    return;
  }

  int streak = 1;
  for (int i = 0; i < dates.length - 1; i++) {
    final diff = dates[i].difference(dates[i + 1]).inDays;
    if (diff == 1) {
      streak++;
    } else {
      break;
    }
  }

  habit.currentStreak = streak;
  if (streak > habit.longestStreak) {
    habit.longestStreak = streak;
  }
}

  void deleteHabit(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  bool isCompletedToday(Habit habit) {
    final today = DateTime.now();
    return habit.completedDates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
  }
}