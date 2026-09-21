import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import '../../app/map_zones.dart';

/// Máscara de la silueta: el margen transparente nunca captura otra zona.
class ZoneMask {
  final int width, height;
  final Uint8List rgba;

  const ZoneMask(this.width, this.height, this.rgba);

  static Future<ZoneMask> load(String asset) async {
    final bytes = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    try {
      final frame = await codec.getNextFrame();
      try {
        final data = await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        return ZoneMask(
          frame.image.width,
          frame.image.height,
          data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  bool contains(MapZone zone, Offset point) {
    if (!zone.contains(point.dx, point.dy)) return false;
    final x = ((point.dx - zone.x) / zone.w * width).floor();
    final y = ((point.dy - zone.y) / zone.h * height).floor();
    if (x < 0 || y < 0 || x >= width || y >= height) return false;
    return rgba[(y * width + x) * 4 + 3] >= 32;
  }
}

/// Busca el hueco más cercano al ancla usando el tamaño real de cada botón.
/// Los 10 puntos de margen dejan 8 puntos incluso con el zoom mínimo (0.8).
List<Rect> placeMapLabels(Size canvas, List<Size> sizes) {
  final placed = <Rect>[];
  for (var i = 0; i < sizes.length; i++) {
    final zone = mapZones[i];
    final size = sizes[i];
    final anchor = Offset(
      (zone.x + zone.w / 2) / mapImageWidth * canvas.width,
      (zone.y + zone.h / 2) / mapImageHeight * canvas.height,
    );
    Rect candidate(double x, double y) => Rect.fromLTWH(
      x.clamp(10.0, math.max(10.0, canvas.width - size.width - 10)),
      y.clamp(10.0, math.max(10.0, canvas.height - size.height - 10)),
      size.width,
      size.height,
    );
    bool free(Rect rect) =>
        placed.every((other) => !other.inflate(10).overlaps(rect));
    var best = candidate(
      anchor.dx - size.width / 2,
      anchor.dy - size.height / 2,
    );
    if (!free(best)) {
      var distance = double.infinity;
      for (var y = 10.0; y + size.height <= canvas.height - 10; y += 10) {
        for (var x = 10.0; x + size.width <= canvas.width - 10; x += 10) {
          final rect = candidate(x, y);
          final d = (rect.center - anchor).distanceSquared;
          if (d < distance && free(rect)) {
            best = rect;
            distance = d;
          }
        }
      }
      // El lienzo mínimo de MapScreen reserva espacio para las nueve etiquetas.
      assert(
        distance.isFinite,
        'El lienzo no tiene espacio para las etiquetas',
      );
    }
    placed.add(best);
  }
  return placed;
}

class MapLabelLayout extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final sizes = [
      for (var i = 0; i < mapZones.length; i++)
        layoutChild(i, BoxConstraints.loose(size)),
    ];
    final rects = placeMapLabels(size, sizes);
    for (var i = 0; i < rects.length; i++) {
      positionChild(i, rects[i].topLeft);
    }
  }

  @override
  bool shouldRelayout(covariant MapLabelLayout oldDelegate) => true;
}
