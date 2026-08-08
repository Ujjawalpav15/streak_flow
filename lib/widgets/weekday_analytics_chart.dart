import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';

class WeekdayAnalyticsChart extends StatelessWidget {
  final List<Habit> habits;

  const WeekdayAnalyticsChart({super.key, required this.habits});

  Map<int, int> _calculateWeekdayCompletions() {
    // 1 = Monday, 7 = Sunday
    final Map<int, int> weekdayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (final habit in habits) {
      for (final date in habit.completedDates) {
        weekdayCounts[date.weekday] = (weekdayCounts[date.weekday] ?? 0) + 1;
      }
    }
    return weekdayCounts;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<AppAccent>()!;
    final counts = _calculateWeekdayCompletions();
    final maxCount = counts.values.isEmpty
        ? 1
        : counts.values.reduce((a, b) => a > b ? a : b);

    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    int strongestWeekday = 1;
    int maxVal = -1;
    counts.forEach((day, count) {
      if (count > maxVal) {
        maxVal = count;
        strongestWeekday = day;
      }
    });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.onSurfaceDim.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📊 Day-of-Week Breakdown',
                style: AppTypography.titleMedium().copyWith(fontSize: 16),
              ),
              if (maxVal > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: accent.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.pillRadius,
                    border: Border.all(color: accent.primary),
                  ),
                  child: Text(
                    '🔥 Strongest: ${dayNames[strongestWeekday - 1]}',
                    style: AppTypography.labelSmall(color: accent.primary)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Bar Chart with staggered grow-in animation
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final count = counts[weekday] ?? 0;
                final heightFactor =
                    maxCount == 0 ? 0.0 : (count / maxCount).clamp(0.05, 1.0);
                final isStrongest = weekday == strongestWeekday && count > 0;

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: heightFactor),
                  duration: Duration(milliseconds: 600 + index * 80),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedHeight, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Count label
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + index * 60),
                          builder: (context, opacity, child) {
                            return Opacity(opacity: opacity, child: child);
                          },
                          child: Text(
                            '$count',
                            style: AppTypography.labelSmall(
                              color: isStrongest
                                  ? accent.glow
                                  : AppColors.onSurfaceMuted,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Bar
                        Container(
                          width: 24,
                          height: 80 * animatedHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isStrongest
                                  ? [accent.glow, accent.gradientStart]
                                  : [
                                      accent.primary,
                                      accent.gradientStart
                                          .withValues(alpha: 0.5),
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.sm),
                            boxShadow: isStrongest
                                ? [
                                    BoxShadow(
                                      color:
                                          accent.glow.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Day label
                        Text(
                          labels[index],
                          style: AppTypography.labelSmall(
                            color: isStrongest
                                ? accent.glow
                                : AppColors.onSurfaceMuted,
                          ).copyWith(
                            fontWeight: isStrongest
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
