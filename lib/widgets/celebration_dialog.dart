import 'dart:math';
import 'package:flutter/material.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti particle overlay
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(320, 360),
                painter: _ConfettiPainter(progress: _controller.value),
              );
            },
          ),

          // Main Dialog Card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.emojiIcon,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Keep Going! 🔥',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final Random _random = Random(42);

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.amber,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.cyanAccent,
      Colors.greenAccent,
    ];

    for (int i = 0; i < 40; i++) {
      final color = colors[i % colors.length];
      final paint = Paint()..color = color.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0));

      final startX = size.width / 2;
      final startY = size.height / 2;

      final angle = _random.nextDouble() * 2 * pi;
      final speed = 80 + _random.nextDouble() * 120;
      final currentDistance = speed * progress;

      final dx = startX + cos(angle) * currentDistance;
      final dy = startY + sin(angle) * currentDistance;

      final particleSize = 4 + _random.nextDouble() * 6;
      canvas.drawCircle(Offset(dx, dy), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
