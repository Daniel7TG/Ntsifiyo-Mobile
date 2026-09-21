import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import 'coyote_controller.dart';

/// Envuelve una pantalla con el coyote acompañante flotante
/// (mirror de `CoyoteCompanion` montado en MainLayout.jsx).
class CoyoteOverlay extends StatelessWidget {
  final Widget child;
  const CoyoteOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const Positioned(left: 0, right: 0, bottom: 0, child: _CoyoteLayer()),
      ],
    );
  }
}

class _CoyoteLayer extends ConsumerStatefulWidget {
  const _CoyoteLayer();

  @override
  ConsumerState<_CoyoteLayer> createState() => _CoyoteLayerState();
}

class _CoyoteLayerState extends ConsumerState<_CoyoteLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _smokeController;

  @override
  void initState() {
    super.initState();
    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          ref.read(coyoteProvider.notifier).dismiss();
          _smokeController.reset();
        }
      });
  }

  @override
  void dispose() {
    _smokeController.dispose();
    super.dispose();
  }

  void _onTapCoyote() {
    if (_smokeController.isAnimating) return;
    _smokeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final coyote = ref.watch(coyoteProvider);
    final hasMessage = coyote.message.isNotEmpty;

    if (!coyote.isVisible && !_smokeController.isAnimating) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        alignment:
            coyote.onLeft ? Alignment.bottomLeft : Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: GestureDetector(
            onTap: _onTapCoyote,
            child: AnimatedBuilder(
              animation: _smokeController,
              builder: (context, child) {
                final progress = _smokeController.value;
                final opacity = (1.0 - progress * 1.6).clamp(0.0, 1.0);
                final scale = (1.0 - progress * 0.25).clamp(0.0, 1.0);

                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: coyote.onLeft
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              alignment: Alignment.bottomCenter,
                              child: hasMessage
                                  ? _Bubble(
                                      message: coyote.message,
                                      pointLeft: coyote.onLeft,
                                    )
                                  : const SizedBox(width: 0, height: 0),
                            ),
                            const SizedBox(height: 4),
                            _CoyoteImage(
                              emotion: coyote.emotion,
                              onLeft: coyote.onLeft,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (progress > 0.0 && progress < 1.0)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: SmokeEffectPainter(progress: progress),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Renderizador de partículas de humo que se expanden y desvanecen al tocar el coyote.
class SmokeEffectPainter extends CustomPainter {
  final double progress;

  SmokeEffectPainter({required this.progress});

  static const List<({double dx, double dy, double radius, double speed})>
      _particles = [
    (dx: 0.0, dy: -20.0, radius: 24.0, speed: 1.2),
    (dx: -25.0, dy: -10.0, radius: 20.0, speed: 1.0),
    (dx: 25.0, dy: -15.0, radius: 22.0, speed: 1.1),
    (dx: -35.0, dy: -30.0, radius: 18.0, speed: 1.3),
    (dx: 30.0, dy: -35.0, radius: 19.0, speed: 1.25),
    (dx: -10.0, dy: -45.0, radius: 25.0, speed: 1.4),
    (dx: 15.0, dy: -50.0, radius: 21.0, speed: 1.35),
    (dx: -45.0, dy: -5.0, radius: 16.0, speed: 0.9),
    (dx: 45.0, dy: -8.0, radius: 17.0, speed: 0.95),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in _particles) {
      final currentDx = p.dx * (0.3 + progress * p.speed);
      final currentDy = p.dy * (0.3 + progress * p.speed);
      final currentRadius = p.radius * (0.5 + progress * 1.2);

      final particleCenter = center + Offset(currentDx, currentDy);

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.75)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, currentRadius * 0.4);

      canvas.drawCircle(particleCenter, currentRadius, paint);

      final innerPaint = Paint()
        ..color = const Color(0xFFE2E8F0).withValues(alpha: opacity * 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, currentRadius * 0.2);

      canvas.drawCircle(particleCenter, currentRadius * 0.6, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SmokeEffectPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CoyoteImage extends StatelessWidget {
  final CoyoteEmotion emotion;
  final bool onLeft;

  const _CoyoteImage({required this.emotion, required this.onLeft});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Transform.flip(
        key: ValueKey('${emotion.name}-$onLeft'),
        // Mirando siempre hacia el centro de la pantalla.
        flipX: !onLeft,
        child: Image.asset(
          emotion.asset,
          height: 104,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Burbuja de diálogo con pico hacia el coyote.
class _Bubble extends StatelessWidget {
  final String message;
  final bool pointLeft;

  const _Bubble({required this.message, required this.pointLeft});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          pointLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.primary, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: darken(AppColors.primary, 0.25),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.35,
              color: AppColors.textMain,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: pointLeft ? 28 : 0,
            right: pointLeft ? 0 : 28,
          ),
          child: CustomPaint(
            size: const Size(16, 9),
            painter: _BubbleTailPainter(),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
