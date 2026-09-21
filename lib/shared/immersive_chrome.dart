import 'package:flutter/services.dart';

/// Cambia a horizontal inmersivo (sin barras de sistema) y de vuelta a
/// vertical. Extraído de `map_screen.dart` (`enterMapChrome`/
/// `exitMapChrome`, que ahora delegan aquí) para que cualquier pantalla que
/// necesite horizontal a pantalla completa —el mapa, el reproductor de
/// contenido con video— comparta la misma implementación en vez de
/// duplicar las llamadas a `SystemChrome`.
///
/// Quien la use es responsable de llamar a [exitImmersiveLandscape] en su
/// propio `dispose()`, para no dejar la app atascada en horizontal si se
/// sale de la pantalla mientras el modo inmersivo está activo.
Future<void> enterImmersiveLandscape() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

Future<void> exitImmersiveLandscape() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values);
}
