import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';

/// Anillo de progreso (mirror de ProgressRing.jsx).
class ProgressRing extends StatelessWidget {
  final double value;
  final double max;
  final double size;
  final double strokeWidth;
  final Color color;
  final Widget? centerLabel;
  final String? semanticLabel;

  const ProgressRing({
    super.key,
    required this.value,
    required this.max,
    this.size = 150,
    this.strokeWidth = 12,
    this.color = AppColors.warning,
    this.centerLabel,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    final trackColor = context.palette.borderLight;
    final ringColor = adaptBrand(context, color);

    return Semantics(
      label: semanticLabel,
      value: '${(progress * 100).round()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, animated, _) => CustomPaint(
            painter: _RingPainter(
              progress: animated,
              strokeWidth: strokeWidth,
              color: ringColor,
              trackColor: trackColor,
            ),
            child: Center(child: centerLabel),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}
