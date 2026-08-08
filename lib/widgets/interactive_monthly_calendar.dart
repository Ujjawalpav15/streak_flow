import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';
import '../theme/streak_tiers.dart';

class InteractiveMonthlyCalendar extends StatefulWidget {
  final List<Habit> habits;

  const InteractiveMonthlyCalendar({super.key, required this.habits});

  @override
  State<InteractiveMonthlyCalendar> createState() =>
      _InteractiveMonthlyCalendarState();
}

class _InteractiveMonthlyCalendarState
    extends State<InteractiveMonthlyCalendar> {
  late DateTime _selectedMonth;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _isTransitioning = true;
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isTransitioning = false);
    });
  }

  void _nextMonth() {
    setState(() {
      _isTransitioning = true;
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isTransitioning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<AppAccent>()!;
    final cs = AppColorScheme.of(context);
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday; // 1 = Mon

    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: cs.onSurfaceDim.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Month Switcher Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left_rounded,
                    color: cs.onSurfaceMuted),
                onPressed: _previousMonth,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  monthName,
                  key: ValueKey(monthName),
                  style: AppTypography.titleMedium(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceMuted),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Weekday Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 36,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Day Grid Matrix with animated fade
          AnimatedOpacity(
            opacity: _isTransitioning ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (firstWeekday - 1) + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) {
                  return const SizedBox.shrink();
                }

                final dayNumber = index - (firstWeekday - 1) + 1;
                final targetDate = DateTime(
                    _selectedMonth.year, _selectedMonth.month, dayNumber);

                // Calculate habits completed or frozen on targetDate
                final completedHabits = widget.habits.where((h) {
                  return h.completedDates.any((d) =>
                      d.year == targetDate.year &&
                      d.month == targetDate.month &&
                      d.day == targetDate.day);
                }).toList();

                final frozenHabits = widget.habits.where((h) {
                  return h.frozenDates.any((d) =>
                      d.year == targetDate.year &&
                      d.month == targetDate.month &&
                      d.day == targetDate.day);
                }).toList();

                final isToday = DateTime.now().year == targetDate.year &&
                    DateTime.now().month == targetDate.month &&
                    DateTime.now().day == targetDate.day;

                final totalHabits = widget.habits.length;
                final completedRatio = totalHabits == 0
                    ? 0.0
                    : (completedHabits.length / totalHabits);

                // Smooth color interpolation between not-done and accent color
                Color cellColor = cs.onSurfaceDim.withValues(alpha: 0.15);
                if (completedHabits.isNotEmpty) {
                  cellColor = Color.lerp(
                    accent.gradientStart.withValues(alpha: 0.3),
                    accent.primary,
                    completedRatio,
                  )!;
                } else if (frozenHabits.isNotEmpty) {
                  cellColor = const Color(0xFF164E63); // Subtle cyan
                }

                return GestureDetector(
                  onTap: () => _showDayDetailSheet(
                    context,
                    targetDate,
                    completedHabits,
                    frozenHabits,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(
                        color: isToday
                            ? accent.glow
                            : (completedHabits.isNotEmpty
                                ? accent.primary.withValues(alpha: 0.4)
                                : Colors.transparent),
                        width: isToday ? 1.8 : 1.0,
                      ),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: accent.glow.withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: isToday
                                  ? accent.glow
                                  : (completedHabits.isNotEmpty
                                      ? cs.onSurface
                                      : cs.onSurfaceMuted),
                              fontWeight: isToday || completedHabits.isNotEmpty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          if (frozenHabits.isNotEmpty)
                            const Text('🧊', style: TextStyle(fontSize: 8))
                          else if (completedHabits.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: accent.glow,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetailSheet(
    BuildContext context,
    DateTime date,
    List<Habit> completedHabits,
    List<Habit> frozenHabits,
  ) {
    final accent = Theme.of(context).extension<AppAccent>()!;
    final dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final totalHabits = widget.habits.length;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorScheme.of(context).surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (context) {
        final cs = AppColorScheme.of(context);
        return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📅 Day History',
                  style: AppTypography.headlineMedium().copyWith(fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: cs.onSurfaceMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              dateFormatted,
              style: AppTypography.labelSmall(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Completion Summary Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: completedHabits.isNotEmpty
                    ? accent.primary.withValues(alpha: 0.15)
                    : cs.onSurfaceDim.withValues(alpha: 0.2),
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: completedHabits.isNotEmpty
                      ? accent.primary
                      : cs.onSurfaceDim,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    completedHabits.length == totalHabits && totalHabits > 0
                        ? '🌟'
                        : (completedHabits.isNotEmpty ? '⚡' : '💤'),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      '${completedHabits.length} of $totalHabits habits completed on this day.',
                      style: AppTypography.bodyMedium(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // List of completed habits
            if (completedHabits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'No habits were marked complete on this date.',
                  style: AppTypography.bodyMedium(color: cs.onSurfaceMuted),
                ),
              )
            else
              ...completedHabits.map((habit) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Text(habit.icon,
                        style: const TextStyle(fontSize: 22)),
                    title: Text(
                      habit.name,
                      style: AppTypography.bodyMedium(),
                    ),
                    subtitle: Text(
                      '${StreakTiers.getTierEmoji(habit.currentStreak)} ${habit.currentStreak} day streak',
                      style: AppTypography.labelSmall(
                          color: StreakTiers.getTierColor(habit.currentStreak)),
                    ),
                    trailing: const Icon(Icons.check_circle_rounded,
                        color: Colors.greenAccent),
                  )),
          ],
        ),
        );
      },
    );
  }
}
