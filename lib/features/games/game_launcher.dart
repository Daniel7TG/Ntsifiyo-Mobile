import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/theme.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/coyote_loading.dart';
import 'game_session.dart';

/// Inicia una actividad/juego cambiando inmediatamente a orientación vertical (portrait)
/// y mostrando una pantalla de carga con la animación del coyote caminando.
///
/// El `Navigator`/`GoRouter`/`ScaffoldMessenger` se capturan **antes** del
/// primer `await`: si el llamador desmonta su propio `context` durante la
/// carga (p.ej. una hoja modal que se cierra con `Navigator.pop` justo antes
/// de llamar a esta función), un `if (!context.mounted) return;` a mitad de
/// camino dejaba el diálogo `PopScope(canPop: false)` huérfano — un coyote
/// "Preparando la actividad..." imposible de cerrar. Con las referencias ya
/// capturadas, el cierre del diálogo en el `finally` no depende de que
/// `context` siga vivo.
Future<void> launchGameWithLoading(
  BuildContext context,
  WidgetRef ref, {
  GameSummaryDto? game,
  int? assignmentId,
  String? gameTypeId,
}) async {
  // 1. Cambiar la orientación inmediatamente a vertical (portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: SystemUiOverlay.values,
  );

  if (!context.mounted) return;

  // Capturados ahora: siguen siendo válidos aunque `context` se desmonte
  // durante los `await` de abajo.
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);

  // 2. Mostrar la pantalla/diálogo de carga con el coyote caminando en vertical
  bool loadingOpen = true;

  showGeneralDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierLabel: 'Cargando actividad',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, anim1, anim2) {
      return PopScope(
        canPop: false,
        child: GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CoyoteLoadingIndicator(
                      message: 'Preparando la actividad...',
                      size: 160,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      game?.title ?? 'Cargando contenido...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  },
  );

  try {
    // 3. Descargar/Cargar el contenido del juego o asignación
    if (game != null) {
      await ref.read(gameSessionProvider.notifier).startFromGame(game);
    } else if (assignmentId != null) {
      await ref.read(gameSessionProvider.notifier).startFromAssignment(assignmentId);
    } else {
      throw Exception('Actividad no especificada');
    }

    // Determinar tipo de juego
    final targetTypeId = gameTypeId ??
        (game != null
            ? gameInfoFor(game.gameType).id
            : 'quiz');

    // 4. Cerrar la pantalla de carga (ver `finally`) y 5. ir a la vista del
    // juego, en ese orden: cerrar primero deja el diálogo fuera del stack
    // antes de empujar la ruta del juego.
    if (loadingOpen) {
      rootNavigator.pop();
      loadingOpen = false;
    }
    // `await` es necesario: el Future de `push` no resuelve hasta que esa
    // ruta se popea (el jugador sale del juego), y llamadores como
    // `MapScreen._openZone` dependen de esperar hasta ese momento para
    // volver a entrar en modo inmersivo.
    await router.push('/games/$targetTypeId/jugar');
  } catch (e) {
    messenger?.showSnackBar(
      SnackBar(content: Text('No se pudo iniciar la actividad: $e')),
    );
  } finally {
    // Red de seguridad: si algo entre el `showGeneralDialog` y aquí lanzó
    // antes de llegar al cierre normal, el diálogo no debe quedar huérfano.
    if (loadingOpen) {
      rootNavigator.pop();
      loadingOpen = false;
    }
  }
}
