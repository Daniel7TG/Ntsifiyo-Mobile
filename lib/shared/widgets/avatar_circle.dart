import 'package:flutter/material.dart';

import '../../app/avatar_config.dart';

/// Avatar circular recortado a la cara — mirror de AvatarCard.jsx.
///
/// Los avatares son ilustraciones de cuerpo completo; se amplían desde
/// el punto de la cara (48% horizontal, 26% vertical) con un factor de
/// 2.1× para que el recorte circular quede centrado en la cara.
class AvatarCircle extends StatelessWidget {
  final int avatarId;
  final double radius;
  final bool ring;
  final Color? ringColor;

  const AvatarCircle({
    super.key,
    required this.avatarId,
    this.radius = 20,
    this.ring = false,
    this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: ring
            ? Border.all(
                color: ringColor ?? Colors.white,
                width: radius > 24 ? 3 : 2,
              )
            : null,
        boxShadow: ring
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Transform.scale(
        scale: 2.1,
        alignment: const Alignment(-0.04, -0.48), // 48% X, 26% Y
        child: Image.asset(
          avatarAssetPath(avatarId),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
