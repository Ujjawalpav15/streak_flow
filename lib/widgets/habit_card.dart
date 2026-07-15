import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(habitsProvider.notifier);
    final isCompleted = notifier.isCompletedToday(habit);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.deepPurple : Colors.white10,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(habit.icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🔥 ${habit.currentStreak} day streak',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onLongPress: () => _confirmDelete(context, ref),
            child: GestureDetector(
              onTap: () => ref
    .read(habitsProvider.notifier)
    .toggleHabit(habit.id),
child: AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: isCompleted ? Colors.deepPurple : Colors.white10,
    shape: BoxShape.circle,
  ),
  child: Icon(
    isCompleted ? Icons.check : Icons.circle_outlined,
    color: isCompleted ? Colors.white : Colors.white54,
    size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Habit',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${habit.name}"?',
          style: const TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(habitsProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}