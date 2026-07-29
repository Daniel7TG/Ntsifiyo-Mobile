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

class _CoyoteLayer extends ConsumerWidget {
  const _CoyoteLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coyote = ref.watch(coyoteProvider);
    final hasMessage = coyote.message.isNotEmpty;

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
            // Toque = se teletransporta al otro lado (la web lo hace al pasar
            // el cursor). Mantener pulsado cierra la burbuja.
            onTap: () => ref.read(coyoteProvider.notifier).toggleSide(),
            onLongPress: () => ref.read(coyoteProvider.notifier).clear(),
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
                          message: coyote.message, pointLeft: coyote.onLeft)
                      : const SizedBox(width: 0, height: 0),
                ),
                const SizedBox(height: 4),
                _CoyoteImage(emotion: coyote.emotion, onLeft: coyote.onLeft),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    // Relleno blanco un pixel arriba para continuar la burbuja.
    final inner = Path()
      ..moveTo(2.5, -1)
      ..lineTo(size.width / 2, size.height - 4)
      ..lineTo(size.width - 2.5, -1)
      ..close();
    canvas.drawPath(inner, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter oldDelegate) => false;
}
