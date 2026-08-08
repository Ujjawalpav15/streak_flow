import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/streak_tiers.dart';
import '../theme/app_accent.dart';
import 'dot_matrix_heatmap.dart';

class HabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const HabitCard({super.key, required this.habit, this.onEdit, this.onTap});

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _scaleController.reverse().then((_) {
      _scaleController.forward();
    });
    ref.read(habitsProvider.notifier).toggleHabit(widget.habit.id);
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final notifier = ref.read(habitsProvider.notifier);
    final isCompleted = notifier.isCompletedToday(habit);
    final cs = AppColorScheme.of(context);
    final tierColor = StreakTiers.getTierColor(habit.currentStreak);
    final tierEmoji = StreakTiers.getTierEmoji(habit.currentStreak);
    final accent = Theme.of(context).extension<AppAccent>()!;

    final now = DateTime.now();
    // 2 rows of 15 columns = 30 days
    final rangeEnd = DateTime(now.year, now.month, now.day);
    final rangeStart = DateTime(now.year, now.month, now.day - 29);

    return GestureDetector(
      onLongPress: () => _showHabitOptionsSheet(context, ref, habit, accent),
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surface, // elevated surface lighter than background
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tierEmoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${habit.currentStreak} Days Streak',
                        style: AppTypography.labelMedium().copyWith(
                          color: tierColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    habit.name,
                    style: AppTypography.titleMedium().copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Right column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Checkmark button
                GestureDetector(
                  onTap: _handleTap,
                  child: ScaleTransition(
                    scale: _scaleController,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? LinearGradient(
                                colors: [tierColor, tierColor.withValues(alpha: 0.7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isCompleted ? null : cs.onSurface.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? Colors.transparent : cs.onSurfaceDim,
                          width: 2,
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: tierColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle_outlined,
                        color: isCompleted ? Colors.black : cs.onSurfaceDim,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Heatmap
                DotMatrixHeatmap(
                  completedDates: habit.completedDates,
                  rangeStart: rangeStart,
                  rangeEnd: rangeEnd,
                  columns: 15,
                  dotSize: 6.0,
                  dotSpacing: 3.0,
                  activeColor: tierColor,
                  inactiveColor: cs.onSurface.withValues(alpha: 0.15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHabitOptionsSheet(
      BuildContext context, WidgetRef ref, Habit habit, AppAccent accent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorScheme.of(context).surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (context) {
        final cs = AppColorScheme.of(context);
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(habit.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    habit.name,
                    style: AppTypography.titleLarge(),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 28),

              // Options
              ListTile(
                leading: Icon(Icons.edit, color: accent.primary),
                title: Text('Edit Habit', style: AppTypography.bodyMedium()),
                onTap: () {
                  Navigator.pop(context);
                  if (widget.onEdit != null) widget.onEdit!();
                },
              ),
              if (habit.freezeCount > 0)
                ListTile(
                  leading: const Icon(Icons.ac_unit, color: Colors.cyan),
                  title: Text('Use Streak Freeze Shield',
                      style: AppTypography.bodyMedium()),
                  subtitle: Text(
                    'Protect yesterday\'s missed streak',
                    style: AppTypography.labelSmall()
                        .copyWith(color: cs.onSurfaceDim),
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
                title: Text('Delete Habit',
                    style: AppTypography.bodyMedium()
                        .copyWith(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref, habit);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        final cs = AppColorScheme.of(context);
        return AlertDialog(
          backgroundColor: cs.surface,
          title: Text('Delete Habit', style: AppTypography.titleLarge()),
          content: Text(
            'Are you sure you want to delete "${habit.name}"? This action cannot be undone.',
            style: AppTypography.bodyMedium().copyWith(color: cs.onSurfaceMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: AppTypography.labelLarge()
                      .copyWith(color: cs.onSurfaceMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                ref.read(habitsProvider.notifier).deleteHabit(habit.id);
                Navigator.pop(context);
              },
              child: Text('Delete',
                  style: AppTypography.labelLarge().copyWith(color: cs.onSurface)),
            ),
          ],
        );
      },
    );
  }
}