import 'package:flutter/material.dart';

import '../../app/palette.dart';

/// Bloque de esqueleto: un rectángulo que respira entre dos opacidades, en
/// vez del `CircularProgressIndicator` genérico. Da una idea de la forma
/// del contenido mientras carga y acorta la espera percibida.
///
/// Respeta `MediaQuery.disableAnimations` (accesibilidad del sistema):
/// si está activo, se queda estático en la opacidad baja.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 6,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.palette.borderLight;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget box(double opacity) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: base.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );

    if (reduceMotion) return box(1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => box(0.5 + _controller.value * 0.5),
    );
  }
}

/// Fila de tarjeta con ícono cuadrado + dos líneas de texto, el patrón más
/// común de la app (KidCard con Row + Column de dos Text). Cubre la mayoría
/// de las listas: asignaciones, actividades, juegos por unidad.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SkeletonBox(width: 40, height: 40, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: double.infinity, height: 13),
                SizedBox(height: 6),
                SkeletonBox(width: 90, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rejilla 2×N de tarjetas (categorías del diccionario, hub de juegos).
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final double aspectRatio;
  final EdgeInsetsGeometry padding;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.aspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: aspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonBox(borderRadius: 20),
    );
  }
}
