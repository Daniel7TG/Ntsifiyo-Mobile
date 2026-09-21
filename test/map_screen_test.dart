import 'dart:typed_data';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jnatrjo_mobile/app/map_zones.dart';
import 'package:jnatrjo_mobile/app/theme.dart';
import 'package:jnatrjo_mobile/features/map/map_geometry.dart';
import 'package:jnatrjo_mobile/features/map/map_screen.dart';
import 'package:jnatrjo_mobile/features/progress/progress_providers.dart';

void main() {
  test('la silueta descarta transparencias y límites fuera de la imagen', () {
    const zone = MapZone('TEST', 'Lugar', '', 10, 20, 100, 100);
    final mask = ZoneMask(
      2,
      2,
      Uint8List.fromList([
        0,
        0,
        0,
        0,
        255,
        255,
        255,
        255,
        0,
        0,
        0,
        255,
        0,
        0,
        0,
        0,
      ]),
    );
    expect(mask.contains(zone, const Offset(15, 25)), isFalse);
    expect(mask.contains(zone, const Offset(90, 25)), isTrue);
    expect(mask.contains(zone, const Offset(15, 95)), isTrue);
    expect(mask.contains(zone, const Offset(110, 25)), isFalse);
    expect(mask.contains(zone, const Offset(15, 120)), isFalse);
  });

  test('reubica botones cuando sus tamaños generan colisiones', () {
    const canvas = Size(900, 500);
    final rects = placeMapLabels(canvas, List.filled(9, const Size(210, 60)));
    for (var i = 0; i < rects.length; i++) {
      expect((Offset.zero & canvas).contains(rects[i].topLeft), isTrue);
      expect((Offset.zero & canvas).contains(rects[i].bottomRight), isTrue);
      for (var j = i + 1; j < rects.length; j++) {
        expect(rects[i].inflate(9.9).overlaps(rects[j]), isFalse);
      }
    }
  });

  for (final viewport in [
    const Size(568, 320),
    const Size(844, 390),
    const Size(1280, 800),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('botones separados y hover en $viewport, texto $scale', (
        tester,
      ) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [zoneProgressProvider.overrideWithValue({})],
            child: MaterialApp(
              theme: buildAppTheme(Brightness.light),
              home: MediaQuery(
                data: MediaQueryData(
                  size: viewport,
                  textScaler: TextScaler.linear(scale),
                ),
                child: const MapScreen(),
              ),
            ),
          ),
        );
        await tester.pump();
        final rects = [
          for (final zone in mapZones)
            tester.getRect(
              find
                  .ancestor(
                    of: find.text(zone.label),
                    matching: find.byType(LayoutId),
                  )
                  .first,
            ),
        ];
        for (var i = 0; i < rects.length; i++) {
          for (var j = i + 1; j < rects.length; j++) {
            expect(rects[i].inflate(9.9).overlaps(rects[j]), isFalse);
          }
        }
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(0, 0));
        await mouse.moveTo(rects.first.center);
        await tester.pump(const Duration(milliseconds: 160));
        final highlights = tester.widgetList<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(highlights.where((widget) => widget.opacity == 1).length, 1);
        await mouse.moveTo(const Offset(0, 0));
        await tester.pump(const Duration(milliseconds: 160));
        expect(
          tester
              .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
              .every((w) => w.opacity == 0),
          isTrue,
        );
        await mouse.removePointer();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
