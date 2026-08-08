import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';
import '../theme/streak_tiers.dart';

class MilestoneBadgesSheet extends StatefulWidget {
  final List<Habit> habits;

  const MilestoneBadgesSheet({super.key, required this.habits});

  @override
  State<MilestoneBadgesSheet> createState() => _MilestoneBadgesSheetState();
}

class _MilestoneBadgesSheetState extends State<MilestoneBadgesSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  int get highestStreak {
    if (widget.habits.isEmpty) return 0;
    return widget.habits
        .map((h) => h.longestStreak)
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxStreak = highestStreak;
    final accent = Theme.of(context).extension<AppAccent>()!;

    final badges = [
      _BadgeInfo(
        title: 'First Spark',
        targetDays: 7,
        icon: '🥉',
        description: 'Achieve a 7-day streak on any habit',
        unlocked: maxStreak >= 7,
        tierColor: StreakTiers.getTierColor(7),
        tierGlow: StreakTiers.getTierGlow(7),
      ),
      _BadgeInfo(
        title: 'Monthly Warrior',
        targetDays: 30,
        icon: '🥈',
        description: 'Maintain consistency for 30 full days',
        unlocked: maxStreak >= 30,
        tierColor: StreakTiers.getTierColor(30),
        tierGlow: StreakTiers.getTierGlow(30),
      ),
      _BadgeInfo(
        title: 'Half-Century Legend',
        targetDays: 50,
        icon: '🥇',
        description: 'Reach an extraordinary 50-day streak',
        unlocked: maxStreak >= 50,
        tierColor: StreakTiers.getTierColor(50),
        tierGlow: StreakTiers.getTierGlow(50),
      ),
      _BadgeInfo(
        title: 'Centurion Master',
        targetDays: 100,
        icon: '👑',
        description: 'Unlock mythic status with a 100-day streak',
        unlocked: maxStreak >= 100,
        tierColor: StreakTiers.getTierColor(100),
        tierGlow: StreakTiers.getTierGlow(100),
      ),
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.sheet),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Milestone Badges',
                        style: AppTypography.headlineMedium(),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.onSurfaceMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your highest streak record: $maxStreak days 🔥',
                style: AppTypography.bodyMedium(color: AppColors.onSurfaceMuted),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Badges list with staggered entrance
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: badges.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    final progress =
                        (maxStreak / badge.targetDays).clamp(0.0, 1.0);

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + index * 80),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: badge.unlocked
                              ? badge.tierColor.withValues(alpha: 0.12)
                              : AppColors.surface,
                          borderRadius: AppRadius.cardRadius,
                          border: Border.all(
                            color: badge.unlocked
                                ? badge.tierColor.withValues(alpha: 0.6)
                                : AppColors.onSurfaceDim,
                            width: badge.unlocked ? 1.5 : 1.0,
                          ),
                          boxShadow: badge.unlocked
                              ? [
                                  BoxShadow(
                                    color:
                                        badge.tierGlow.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            // Badge icon
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: badge.unlocked
                                    ? badge.tierColor.withValues(alpha: 0.2)
                                    : AppColors.onSurfaceDim
                                        .withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                boxShadow: badge.unlocked
                                    ? [
                                        BoxShadow(
                                          color: badge.tierGlow
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                badge.icon,
                                style: TextStyle(
                                  fontSize: 28,
                                  color:
                                      badge.unlocked ? null : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),

                            // Badge details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        badge.title,
                                        style: AppTypography.titleMedium(
                                          color: badge.unlocked
                                              ? AppColors.onSurface
                                              : AppColors.onSurfaceMuted,
                                        ).copyWith(fontSize: 16),
                                      ),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: badge.unlocked
                                              ? badge.tierColor
                                              : AppColors.onSurfaceDim,
                                          borderRadius: AppRadius.pillRadius,
                                        ),
                                        child: Text(
                                          badge.unlocked
                                              ? 'UNLOCKED'
                                              : '${(progress * 100).toInt()}%',
                                          style: TextStyle(
                                            color: badge.unlocked
                                                ? Colors.black
                                                : AppColors.onSurfaceMuted,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    badge.description,
                                    style: AppTypography.labelSmall(),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppSpacing.xs),
                                    child: TweenAnimationBuilder<double>(
                                      tween:
                                          Tween(begin: 0.0, end: progress),
                                      duration:
                                          const Duration(milliseconds: 800),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, animValue, _) {
                                        return LinearProgressIndicator(
                                          value: animValue,
                                          backgroundColor: AppColors
                                              .onSurfaceDim
                                              .withValues(alpha: 0.3),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            badge.unlocked
                                                ? badge.tierColor
                                                : accent.primary,
                                          ),
                                          minHeight: 6,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
  final Color tierColor;
  final Color tierGlow;

  _BadgeInfo({
    required this.title,
    required this.targetDays,
    required this.icon,
    required this.description,
    required this.unlocked,
    required this.tierColor,
    required this.tierGlow,
  });
}
