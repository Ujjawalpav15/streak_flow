import 'package:flutter/material.dart';
import '../models/habit.dart';

class MilestoneBadgesSheet extends StatelessWidget {
  final List<Habit> habits;

  const MilestoneBadgesSheet({super.key, required this.habits});

  int get highestStreak {
    if (habits.isEmpty) return 0;
    return habits
        .map((h) => h.longestStreak)
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final maxStreak = highestStreak;

    final badges = [
      _BadgeInfo(
        title: 'First Spark',
        targetDays: 7,
        icon: '🥉',
        description: 'Achieve a 7-day streak on any habit',
        unlocked: maxStreak >= 7,
        color: Colors.amber.shade700,
      ),
      _BadgeInfo(
        title: 'Monthly Warrior',
        targetDays: 30,
        icon: '🥈',
        description: 'Maintain consistency for 30 full days',
        unlocked: maxStreak >= 30,
        color: Colors.purpleAccent,
      ),
      _BadgeInfo(
        title: 'Half-Century Legend',
        targetDays: 50,
        icon: '🥇',
        description: 'Reach an extraordinary 50-day streak',
        unlocked: maxStreak >= 50,
        color: Colors.cyanAccent,
      ),
      _BadgeInfo(
        title: 'Centurion Master',
        targetDays: 100,
        icon: '👑',
        description: 'Unlock mythic status with a 100-day streak',
        unlocked: maxStreak >= 100,
        color: Colors.pinkAccent,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF131722),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🏆', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 10),
                  Text(
                    'Milestone Badges',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your highest streak record: $maxStreak days 🔥',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: badges.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final badge = badges[index];
                final progress = (maxStreak / badge.targetDays).clamp(0.0, 1.0);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: badge.unlocked
                        ? badge.color.withValues(alpha: 0.12)
                        : const Color(0xFF1C2230),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: badge.unlocked
                          ? badge.color.withValues(alpha: 0.6)
                          : Colors.white10,
                      width: badge.unlocked ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: badge.unlocked
                              ? badge.color.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badge.icon,
                          style: TextStyle(
                            fontSize: 28,
                            color: badge.unlocked
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  badge.title,
                                  style: TextStyle(
                                    color: badge.unlocked
                                        ? Colors.white
                                        : Colors.white60,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badge.unlocked
                                        ? badge.color
                                        : Colors.white12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    badge.unlocked
                                        ? 'UNLOCKED'
                                        : '${(progress * 100).toInt()}%',
                                    style: TextStyle(
                                      color: badge.unlocked
                                          ? Colors.black
                                          : Colors.white54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge.description,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    badge.color),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeInfo {
  final String title;
  final int targetDays;
  final String icon;
  final String description;
  final bool unlocked;
  final Color color;

  _BadgeInfo({
    required this.title,
    required this.targetDays,
    required this.icon,
    required this.description,
    required this.unlocked,
    required this.color,
  });
}
