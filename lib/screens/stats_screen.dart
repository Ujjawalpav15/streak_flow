import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'No habits yet.\nAdd one from the home screen!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _HabitStatCard(habit: habit);
              },
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

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(habit.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                habit.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 12),
              _StatBadge(
                label: 'Longest Streak',
                value: '${habit.longestStreak} 🏆',
                color: Colors.orange.shade800,
              ),
              const SizedBox(width: 12),
              _StatBadge(
                label: 'Total Days',
                value: '${habit.completedDates.length} ✅',
                color: Colors.teal.shade700,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Heatmap
          const Text(
            'Completion History',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 10),
          HeatMap(
            startDate: DateTime.now().subtract(const Duration(days: 90)),
            endDate: DateTime.now(),
            datasets: dataset,
            colorMode: ColorMode.color,
            defaultColor: const Color(0xFF2C2C2C),
            textColor: Colors.white54,
            showColorTip: false,
            showText: true,
            scrollable: true,
            size: 18,
            colorsets: const {
              1: Colors.deepPurple,
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
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
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