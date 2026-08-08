import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';

class CelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String emojiIcon;

  const CelebrationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.emojiIcon,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required String emojiIcon,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CelebrationDialog(
        title: title,
        message: message,
        emojiIcon: emojiIcon,
      ),
    );
  }

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _bounceController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<AppAccent>()!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Confetti particle overlay
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(320, 400),
                    painter: _ConfettiPainter(
                      progress: _confettiController.value,
                      accentColor: accent.primary,
                      glowColor: accent.glow,
                    ),
                  );
                },
              ),

              // Main Dialog Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.gradientStart.withValues(alpha: 0.3),
                      AppColors.surfaceVariant,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sheet + 8),
                  border: Border.all(
                    color: accent.glow.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.glow.withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Large emoji with glow backdrop
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.primary.withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: accent.glow.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.emojiIcon,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineMedium().copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(
                        color: AppColors.onSurfaceMuted,
                      ).copyWith(height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // "Nice!" dismiss button with accent gradient
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accent.gradientStart, accent.gradientEnd],
                          ),
                          borderRadius: AppRadius.cardRadius,
                          boxShadow: [
                            BoxShadow(
                              color: accent.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          'Nice! 🔥',
                          style: AppTypography.titleMedium(
                            color: Colors.white,
                          ).copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color glowColor;
  final Random _random = Random(42);

  _ConfettiPainter({
    required this.progress,
    required this.accentColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      accentColor,
      glowColor,
      const Color(0xFFFBBF24), // Amber
      const Color(0xFFF472B6), // Pink
      const Color(0xFF34D399), // Emerald
      const Color(0xFF60A5FA), // Blue
    ];

    for (int i = 0; i < 50; i++) {
      final color = colors[i % colors.length];
      final paint = Paint()
        ..color = color.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0));

      final startX = size.width / 2;
      final startY = size.height / 2;

      final angle = _random.nextDouble() * 2 * pi;
      final speed = 80 + _random.nextDouble() * 140;
      final currentDistance = speed * progress;

      final dx = startX + cos(angle) * currentDistance;
      final dy = startY + sin(angle) * currentDistance + (progress * 30);

      final particleSize = 3 + _random.nextDouble() * 5;

      // Mix shapes: circles and small rectangles
      if (i % 3 == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(dx, dy),
              width: particleSize * 1.5,
              height: particleSize * 0.6,
            ),
            Radius.circular(particleSize * 0.3),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset(dx, dy), particleSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
