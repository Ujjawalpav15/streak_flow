import 'package:flutter/material.dart';
import '../models/habit.dart';

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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📊 Day-of-Week Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (maxVal > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.deepPurpleAccent),
                  ),
                  child: Text(
                    '🔥 Strongest: ${dayNames[strongestWeekday - 1]}',
                    style: const TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final count = counts[weekday] ?? 0;
                final heightFactor =
                    maxCount == 0 ? 0.0 : (count / maxCount).clamp(0.05, 1.0);
                final isStrongest = weekday == strongestWeekday && count > 0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        color: isStrongest ? Colors.amber : Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 22,
                      height: 70 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isStrongest
                              ? [Colors.amber.shade400, Colors.deepOrange]
                              : [
                                  Colors.deepPurpleAccent,
                                  Colors.deepPurple.shade900
                                ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isStrongest
                            ? [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                )
                              ]
                            : [],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: isStrongest ? Colors.amber : Colors.white54,
                        fontSize: 11,
                        fontWeight: isStrongest
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
