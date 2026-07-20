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

  HabitNotifier(this._box) : super(const []) {
    refreshAllStreaks();
  }

  /// Recomputes streaks for every habit so values stored on a previous
  /// day (e.g. before a missed week) don't display stale. Also called on
  /// app resume, since a streak can expire while the app sits in memory
  /// across midnight.
  void refreshAllStreaks() {
    for (final habit in _box.values) {
      final prevCurrent = habit.currentStreak;
      final prevLongest = habit.longestStreak;
      _updateStreak(habit);
      if (habit.currentStreak != prevCurrent ||
          habit.longestStreak != prevLongest) {
        habit.save();
      }
    }
    state = _box.values.toList();
  }

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
    // Normalize to UTC dates so day differences are exact even across
    // daylight-saving transitions (local midnights can be 23/25h apart).
    final dates = habit.completedDates
        .map((d) => DateTime.utc(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    if (dates.isEmpty) {
      habit.currentStreak = 0;
      habit.longestStreak = 0;
      return;
    }

    int longest = 1;
    int run = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }

    // The trailing run only counts as the current streak if it's still
    // alive, i.e. its last completion was today or yesterday.
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    habit.currentStreak = today.difference(dates.last).inDays > 1 ? 0 : run;
    habit.longestStreak = longest;
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