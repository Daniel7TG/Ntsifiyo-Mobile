import 'package:flutter/material.dart';

import '../../app/palette.dart';

/// Estado de carga para los pocos casos donde el contenido no tiene una
/// forma reconocible que esqueletizar (verificar correo, preparar un
/// reproductor, guardar el resultado de una partida): el coyote caminando
/// en vez de un `CircularProgressIndicator` genérico.
///
/// Si el sistema pide reducir movimiento, se queda directamente en el
/// fotograma quieto (`assets/coyote/esperando.webp`) sin reproducir la animación.
class CoyoteLoadingIndicator extends StatelessWidget {
  final String message;
  final double size;

  const CoyoteLoadingIndicator({
    super.key,
    this.message = 'Cargando...',
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          reduceMotion
              ? Image.asset('assets/coyote/esperando.webp', height: size)
              : Image.asset(
                  'assets/coyote/animations/walking.webp',
                  height: size,
                  gaplessPlayback: true,
                ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: context.palette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
