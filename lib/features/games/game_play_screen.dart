import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/under_construction.dart';
import '../coyote/coyote_companion.dart';
import '../coyote/coyote_controller.dart';
import '../coyote/coyote_messages.dart';
import 'game_session.dart';
import 'views/questionnaire_game_view.dart';
import 'views/intruso_game_view.dart';
import 'views/memorama_game_view.dart';
import 'views/memoria_rapida_game_view.dart';
import 'views/pares_game_view.dart';
import 'views/loteria_game_view.dart';
import 'views/laberinto_game_view.dart';
import 'views/tripas_game_view.dart';
import 'views/sopa_letras_game_view.dart';

/// Despacha la sesión de juego activa a la vista del tipo correspondiente
/// (equivalente a las rutas /games/{type}/jugar/:activityId de la web).
class GamePlayScreen extends ConsumerStatefulWidget {
  final String gameTypeId;

  const GamePlayScreen({super.key, required this.gameTypeId});

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen> {
  @override
  void initState() {
    super.initState();
    // El coyote explica el juego al entrar (mirror de MainLayout.jsx).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(coyoteProvider.notifier).speak(
            coyoteGameInstruction(widget.gameTypeId),
            emotion: CoyoteEmotion.pensando,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);

    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Juego')),
        body: ErrorState(
          message:
              'No hay datos de la actividad. Regresa al panel para iniciar.',
          onRetry: () => context.pop(),
        ),
      );
    }

    void exit() {
      ref.read(gameSessionProvider.notifier).clear();
      ref.read(coyoteProvider.notifier).clear();
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/juegos');
      }
    }

    // Igual que la web: la ruta decide el juego a montar. El gameType del
    // response es solo fallback (el backend no siempre lo incluye).
    final byRoute = activityConfig.values
        .where((g) => g.id == widget.gameTypeId)
        .map((g) => g.type);
    final type = byRoute.isNotEmpty
        ? byRoute.first
        : (session.data.gameType ?? '');

    final view = switch (type) {
      ActivityTypes.questionnaire ||
      ActivityTypes.fillBlank =>
        QuestionnaireGameView(session: session, onExit: exit),
      ActivityTypes.intruder =>
        IntrusoGameView(session: session, onExit: exit),
      ActivityTypes.memoryGame =>
        MemoramaGameView(session: session, onExit: exit),
      ActivityTypes.fastMemory =>
        MemoriaRapidaGameView(session: session, onExit: exit),
      ActivityTypes.pairs => ParesGameView(session: session, onExit: exit),
      ActivityTypes.lottery => LoteriaGameView(session: session, onExit: exit),
      ActivityTypes.maze => LaberintoGameView(session: session, onExit: exit),
      ActivityTypes.catLines => TripasGameView(session: session, onExit: exit),
      ActivityTypes.findTheWord =>
        SopaLetrasGameView(session: session, onExit: exit),
      _ => UnderConstructionScreen(title: gameInfoFor(type).title),
    };

    return CoyoteOverlay(child: view);
  }
}
