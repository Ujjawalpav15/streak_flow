import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  final VoidCallback? onEdit;

  const HabitCard({super.key, required this.habit, this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(habitsProvider.notifier);
    final isCompleted = notifier.isCompletedToday(habit);
    final streakColor = habit.streakColor;

    return GestureDetector(
      onLongPress: () => _showHabitOptionsSheet(context, ref),
      onTap: () => notifier.toggleHabit(habit.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? streakColor.withValues(alpha: 0.1)
              : const Color(0xFF161B26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? streakColor.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.08),
            width: isCompleted ? 2.0 : 1.2,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: streakColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Emoji container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? streakColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                habit.icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 16),

            // Main habit details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          habit.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: Colors.white38,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Category Tag Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          habit.category,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Streak Flame Badge
                      Text(
                        '${habit.streakFlameIcon} ${habit.currentStreak} day streak',
                        style: TextStyle(
                          color: streakColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '• ${habit.streakTierTitle}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (habit.freezeCount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '🧊 ${habit.freezeCount} Freeze Shields',
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Interactive Checkbox Button
            GestureDetector(
              onTap: () => notifier.toggleHabit(habit.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? LinearGradient(
                          colors: [
                            streakColor,
                            streakColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isCompleted ? null : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? Colors.transparent
                        : Colors.white24,
                    width: 2,
                  ),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: streakColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle_outlined,
                  color: isCompleted ? Colors.black : Colors.white38,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHabitOptionsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(habit.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  habit.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 28),

            // Options
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.deepPurpleAccent),
              title: const Text('Edit Habit',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                if (onEdit != null) onEdit!();
              },
            ),
            if (habit.freezeCount > 0)
              ListTile(
                leading: const Icon(Icons.ac_unit, color: Colors.cyan),
                title: const Text('Use Streak Freeze Shield',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text(
                  'Protect yesterday\'s missed streak',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                onTap: () {
                  final used = ref
                      .read(habitsProvider.notifier)
                      .useStreakFreeze(habit.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor:
                          used ? Colors.cyan.shade900 : Colors.red.shade900,
                      content: Text(
                        used
                            ? '🧊 Streak Freeze Applied!'
                            : 'Could not apply streak freeze.',
                      ),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title:
                  const Text('Delete Habit', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2433),
        title: const Text('Delete Habit', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${habit.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(habitsProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}