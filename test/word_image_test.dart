import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/app/theme.dart';
import 'package:jnatrjo_mobile/features/games/widgets/game_widgets.dart';

/// WordImage lee `context.palette` (AppPalette, un ThemeExtension propio de
/// la app): un MaterialApp con el ThemeData por defecto no lo registra y el
/// `!` de esa extensión revienta en build. Hay que usar `buildAppTheme`.
Widget _wrap(Widget child) =>
    MaterialApp(theme: buildAppTheme(Brightness.light), home: child);

void main() {
  group('WordImage', () {
    testWidgets(
        'prioriza la ruta real de disco sobre el asset fabricado por '
        'wordId (bug: antes mostraba _broken si assets/dictionary/img/'
        '\$wordId.webp no existía, aunque el archivo real sí)',
        (tester) async {
      // Sin I/O real: basta con que la ruta no sea 'assets/'/'http' para
      // que WordImage la trate como ruta de disco; no hace falta que el
      // archivo exista para verificar QUÉ ImageProvider elige construir.
      const realPath = 'C:/game_media/3f2a1b9c.webp';

      await tester.pumpWidget(_wrap(const WordImage(
        path: realPath,
        // Un id que deliberadamente no está en el bundle: si el widget
        // prefiriera el fallback fabricado, apuntaría a un asset
        // inexistente en vez de a la ruta real.
        wordId: 987654321,
      )));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<FileImage>());
      expect((image.image as FileImage).file.path, realPath);
    });

    testWidgets('sin ruta real, cae al asset fabricado por wordId',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const WordImage(path: null, wordId: 5))); // 5 = abeja

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName,
          'assets/dictionary/img/5.webp');
    });
  });
}
