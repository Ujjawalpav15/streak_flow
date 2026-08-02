import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import '../widgets/interactive_monthly_calendar.dart';
import '../widgets/weekday_analytics_chart.dart';

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

    int activeStreaks = habits.where((h) => h.currentStreak > 0).length;
    int highestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
    int totalCheckIns = habits.fold(0, (sum, h) => sum + h.completedDates.length);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Analytics & Calendars',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurpleAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Monthly Calendar'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Analytics & Heatmaps'),
          ],
        ),
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'No habit statistics available yet.\nAdd a habit from the home dashboard!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 15),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Interactive Monthly Calendar & Day-of-Week Chart
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Interactive Monthly Calendar View
                    InteractiveMonthlyCalendar(habits: habits),
                    const SizedBox(height: 18),

                    // Day-of-Week Analytics Chart
                    WeekdayAnalyticsChart(habits: habits),
                    const SizedBox(height: 18),
                  ],
                ),

                // TAB 2: Analytics Grid, Heatmaps & Habit Breakdowns
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Overview Analytics Grid
                    Row(
                      children: [
                        _OverviewCard(
                          label: 'Active Streaks',
                          value: '$activeStreaks 🔥',
                          color: Colors.deepPurpleAccent,
                        ),
                        const SizedBox(width: 12),
                        _OverviewCard(
                          label: 'Best Record',
                          value: '$highestStreak 🏆',
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 12),
                        _OverviewCard(
                          label: 'Total Check-ins',
                          value: '$totalCheckIns ✅',
                          color: Colors.tealAccent.shade700,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Habit Breakdown & 90-Day Heatmaps',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // List of Habit Stat Cards
                    ...habits.map((habit) => _HabitStatCard(habit: habit)),
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
  final Color color;

  const _OverviewCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitStatCard extends StatelessWidget {
  final Habit habit;
  const _HabitStatCard({required this.habit});

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
    final streakColor = habit.streakColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(habit.icon, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${habit.streakFlameIcon} ${habit.streakTierTitle}',
                    style: TextStyle(
                      color: streakColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Streak stats row
          Row(
            children: [
              _StatBadge(
                label: 'Current Streak',
                value: '${habit.currentStreak} 🔥',
                color: streakColor,
              ),
              const SizedBox(width: 10),
              _StatBadge(
                label: 'Longest Record',
                value: '${habit.longestStreak} 🏆',
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 10),
              _StatBadge(
                label: 'Total Days',
                value: '${habit.completedDates.length} ✅',
                color: Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Heatmap Calendar
          const Text(
            '90-Day Completion Heatmap',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 10),
          HeatMap(
            startDate: DateTime.now().subtract(const Duration(days: 90)),
            endDate: DateTime.now(),
            datasets: dataset,
            colorMode: ColorMode.color,
            defaultColor: const Color(0xFF232B3C),
            textColor: Colors.white54,
            showColorTip: false,
            showText: true,
            scrollable: true,
            size: 18,
            colorsets: {
              1: streakColor,
            },
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}