import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import '../widgets/interactive_monthly_calendar.dart';
import '../widgets/weekday_analytics_chart.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';
import '../theme/streak_tiers.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final accent = Theme.of(context).extension<AppAccent>()!;
    final cs = AppColorScheme.of(context);

    int activeStreaks = habits.where((h) => h.currentStreak > 0).length;
    int highestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
    int totalCheckIns = habits.fold(0, (sum, h) => sum + h.completedDates.length);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
        title: Text(
          'Analytics & Calendars',
          style: AppTypography.headlineMedium(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accent.primary,
          indicatorWeight: 3,
          labelColor: cs.onSurface,
          unselectedLabelColor: cs.onSurfaceMuted,
          labelStyle: AppTypography.bodyMedium(),
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Monthly Calendar'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Analytics & Heatmaps'),
          ],
        ),
      ),
      body: habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📊', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No Statistics Yet',
                    style: AppTypography.headlineMedium(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add a habit from the home dashboard\nto start tracking your progress!',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(color: cs.onSurfaceMuted),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Interactive Monthly Calendar & Day-of-Week Chart
                ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    InteractiveMonthlyCalendar(habits: habits),
                    const SizedBox(height: AppSpacing.lg),
                    WeekdayAnalyticsChart(habits: habits),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),

                // TAB 2: Analytics Grid, Heatmaps & Habit Breakdowns
                ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Overview Analytics Grid with stagger
                    Row(
                      children: [
                        _OverviewCard(
                          label: 'Active Streaks',
                          value: '$activeStreaks',
                          emoji: '🔥',
                          color: accent.primary,
                          delay: 0,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _OverviewCard(
                          label: 'Best Record',
                          value: '$highestStreak',
                          emoji: '🏆',
                          color: StreakTiers.getTierColor(highestStreak),
                          delay: 80,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _OverviewCard(
                          label: 'Total Check-ins',
                          value: '$totalCheckIns',
                          emoji: '✅',
                          color: const Color(0xFF10B981),
                          delay: 160,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'Habit Breakdown & 90-Day Heatmaps',
                      style: AppTypography.titleMedium(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // List of Habit Stat Cards
                    ...habits.asMap().entries.map((entry) =>
                        _HabitStatCard(habit: entry.value, index: entry.key)),
                  ],
                ),
              ],
            ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;
  final int delay;

  const _OverviewCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = AppColorScheme.of(context);
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 500 + delay),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return Transform.translate(
            offset: Offset(0, 16 * (1 - animValue)),
            child: Opacity(
              opacity: animValue,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.streakCount(color: cs.onSurface).copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall(color: cs.onSurfaceMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitStatCard extends StatelessWidget {
  final Habit habit;
  final int index;
  const _HabitStatCard({required this.habit, this.index = 0});

  Map<DateTime, int> _buildDataset() {
    final Map<DateTime, int> dataset = {};
    for (final date in habit.completedDates) {
      final key = DateTime(date.year, date.month, date.day);
      dataset[key] = 1;
    }
    return dataset;
  }

  @override
  Widget build(BuildContext context) {
    final dataset = _buildDataset();
    final tierColor = StreakTiers.getTierColor(habit.currentStreak);
    final tierGlow = StreakTiers.getTierGlow(habit.currentStreak);
    final cs = AppColorScheme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xl),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: tierColor.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: tierGlow.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(habit.icon, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: AppTypography.titleMedium(),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${StreakTiers.getTierEmoji(habit.currentStreak)} ${StreakTiers.getTierTitle(habit.currentStreak)}',
                        style: AppTypography.labelSmall(color: tierColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Streak stats row
            Row(
              children: [
                _StatBadge(
                  label: 'Current Streak',
                  value: '${habit.currentStreak}',
                  emoji: '🔥',
                  color: tierColor,
                ),
                const SizedBox(width: AppSpacing.md),
                _StatBadge(
                  label: 'Longest Record',
                  value: '${habit.longestStreak}',
                  emoji: '🏆',
                  color: StreakTiers.getTierColor(habit.longestStreak),
                ),
                const SizedBox(width: AppSpacing.md),
                _StatBadge(
                  label: 'Total Days',
                  value: '${habit.completedDates.length}',
                  emoji: '✅',
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Heatmap Calendar
            Text(
              '90-Day Completion Heatmap',
              style: AppTypography.labelSmall(color: cs.onSurfaceMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            HeatMap(
              startDate: DateTime.now().subtract(const Duration(days: 90)),
              endDate: DateTime.now(),
              datasets: dataset,
              colorMode: ColorMode.color,
              defaultColor: cs.surfaceVariant,
              textColor: cs.onSurfaceMuted,
              showColorTip: false,
              showText: true,
              scrollable: true,
              size: 18,
              colorsets: {
                1: tierColor,
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = AppColorScheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.streakCount(color: cs.onSurface).copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall(color: cs.onSurfaceMuted).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}