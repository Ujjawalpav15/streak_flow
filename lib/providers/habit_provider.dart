import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

final habitBoxProvider = Provider<Box<Habit>>((ref) {
  return Hive.box<Habit>('habits');
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final habitsProvider =
    StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final box = ref.watch(habitBoxProvider);
  return HabitNotifier(box);
});

final filteredHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitsProvider);
  final category = ref.watch(selectedCategoryProvider);
  if (category == 'All') return habits;
  return habits.where((h) => h.category == category).toList();
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  final Box<Habit> _box;

  HabitNotifier(this._box) : super(const []) {
    refreshAllStreaks();
  }

  /// Recomputes streaks for every habit so values stored on a previous day
  /// don't display stale. Evaluates streak freeze shields if enabled.
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

  void addHabit(String name, String icon, {String category = 'General'}) {
    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      category: category,
      freezeCount: 2,
    );
    _box.put(habit.id, habit);
    state = _box.values.toList();
  }

  void editHabit(String id, String name, String icon, String category) {
    final habit = _box.get(id);
    if (habit == null) return;

    habit.name = name;
    habit.icon = icon;
    habit.category = category;
    habit.save();
    state = _box.values.toList();
  }

  void toggleHabit(String id) {
    final habit = _box.get(id);
    if (habit == null) return;

    final today = DateTime.now();
    final alreadyDone = habit.completedDates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);

    if (alreadyDone) {
      // Undo completion for today
      habit.completedDates.removeWhere((d) =>
          d.year == today.year && d.month == today.month && d.day == today.day);
    } else {
      // Mark completed today
      habit.completedDates.add(today);
    }

    _updateStreak(habit);
    habit.save();
    state = _box.values.toList();
  }

  /// Use a Streak Freeze shield to save yesterday's missed streak
  bool useStreakFreeze(String id) {
    final habit = _box.get(id);
    if (habit == null || habit.freezeCount <= 0) return false;

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final alreadyFrozen = habit.frozenDates.any((d) =>
        d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day);

    if (!alreadyFrozen) {
      habit.freezeCount -= 1;
      habit.frozenDates.add(yesterday);
      habit.completedDates.add(yesterday);
      _updateStreak(habit);
      habit.save();
      state = _box.values.toList();
      return true;
    }
    return false;
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

  /// Streak calculation algorithm considering consecutive UTC days
  void _updateStreak(Habit habit) {
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

    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final daysSinceLast = today.difference(dates.last).inDays;

    habit.currentStreak = daysSinceLast > 1 ? 0 : run;
    if (longest > habit.longestStreak) {
      habit.longestStreak = longest;
    }
  }
}