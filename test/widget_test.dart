import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:streak_app/main.dart';
import 'package:streak_app/models/habit.dart';
import 'package:streak_app/providers/habit_provider.dart';

void main() {
  late Box<Habit> box;

  setUpAll(() async {
    Hive.registerAdapter(HabitAdapter());
    // In-memory backend (bytes:) — a file-backed box deadlocks when writes
    // are triggered inside testWidgets' fake-async zone, because the write
    // continuations are captured by the fake zone and never run, leaving
    // the backend's write lock wedged for every later test.
    box = await Hive.openBox<Habit>('habits', bytes: Uint8List(0));
  });

  // The memory backend doesn't support clear(); delete keys instead.
  setUp(() async {
    await box.deleteAll(box.keys.toList());
  });

  tearDownAll(() => Hive.close());

  group('HabitNotifier streaks', () {
    DateTime daysAgo(int n) => DateTime.now().subtract(Duration(days: n));

    test('consecutive days ending today give a live streak', () {
      final notifier = HabitNotifier(box);
      final habit = Habit(
        id: 'h1',
        name: 'Run',
        icon: '🏃',
        completedDates: [daysAgo(2), daysAgo(1), daysAgo(0)],
      );
      box.put(habit.id, habit);
      notifier.toggleHabit('h1'); // undo today
      notifier.toggleHabit('h1'); // redo today

      expect(habit.currentStreak, 3);
      expect(habit.longestStreak, 3);
    });

    test('a missed day breaks the current streak but longest survives',
        () async {
      final habit = Habit(
        id: 'h2',
        name: 'Read',
        icon: '📚',
        completedDates: [daysAgo(4), daysAgo(3), daysAgo(2)],
      );
      await box.put(habit.id, habit);

      // Notifier recomputes streaks on creation.
      HabitNotifier(box);

      expect(habit.currentStreak, 0);
      expect(habit.longestStreak, 3);
    });

    test('undoing an accidental completion also rolls back longest streak',
        () async {
      final habit = Habit(id: 'h3', name: 'Gym', icon: '💪');
      await box.put(habit.id, habit);

      final notifier = HabitNotifier(box);
      notifier.toggleHabit('h3');
      expect(habit.currentStreak, 1);
      expect(habit.longestStreak, 1);

      notifier.toggleHabit('h3'); // undo
      expect(habit.currentStreak, 0);
      expect(habit.longestStreak, 0);
    });
  });

  testWidgets('shows empty state, then adds and completes a habit',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('My Streaks'), findsOneWidget);
    expect(find.textContaining('No habits yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Running');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('🔥 0 day streak'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pumpAndSettle();

    expect(find.text('🔥 1 day streak'), findsOneWidget);
  });

  testWidgets('recomputes streaks when the app resumes',
      (WidgetTester tester) async {
    final habit = Habit(
      id: 'stale',
      name: 'Meditate',
      icon: '🧘',
      completedDates: [
        DateTime.now().subtract(const Duration(days: 3)),
        DateTime.now().subtract(const Duration(days: 2)),
      ],
    );
    await box.put(habit.id, habit);

    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // The notifier already refreshed on creation; force a stale value back
    // in, as if the app sat in memory across midnight, so we can verify
    // the resume handler refreshes it again.
    habit.currentStreak = 2;
    habit.save();

    // Go through inactive rather than paused: paused disables frame
    // scheduling on the test binding, which makes pumping hang.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(habit.currentStreak, 0);
    expect(find.text('🔥 0 day streak'), findsOneWidget);
  });
}
