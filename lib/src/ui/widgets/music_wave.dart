import 'dart:math';
import 'package:flutter/material.dart';

class MusicWave extends StatefulWidget {
  const MusicWave({super.key});

  @override
  State<MusicWave> createState() => _MusicWaveState();
}

class _MusicWaveState extends State<MusicWave>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: EqualizerPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class EqualizerPainter extends CustomPainter {
  final double animation;

  EqualizerPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xffC084FC), Color(0xffA855F7), Color(0xff6D28D9)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeCap = StrokeCap.round;

    const int barCount = 9;

    final double spacing = size.width / (barCount + 1);
    final double barWidth = spacing * 0.45;

    for (int i = 0; i < barCount; i++) {
      double phase = animation * 2 * pi + i * 0.8;

      // Height changes independently
      double factor = (sin(phase) + 1) / 2;

      double height = 20 + factor * (size.height * (0.35 + (i % 3) * 0.12));

      double x = spacing * (i + 1);

      double top = (size.height - height) / 2;
      double bottom = top + height;

      paint.strokeWidth = barWidth;

      // Glow
      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        Paint()
          ..color = const Color(0xffB026FF).withOpacity(0.25)
          ..strokeWidth = barWidth + 10
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      // Main bar
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant EqualizerPainter oldDelegate) => true;
}
