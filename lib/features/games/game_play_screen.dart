import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/under_construction.dart';
import 'game_session.dart';
import 'views/questionnaire_game_view.dart';
import 'views/memorama_game_view.dart';
import 'views/memoria_rapida_game_view.dart';
import 'views/pares_game_view.dart';
import 'views/loteria_game_view.dart';
import 'views/laberinto_game_view.dart';
import 'views/tripas_game_view.dart';
import 'views/sopa_letras_game_view.dart';

/// Despacha la sesión de juego activa a la vista del tipo correspondiente
/// (equivalente a las rutas /games/{type}/jugar/:activityId de la web).
class GamePlayScreen extends ConsumerWidget {
  final String gameTypeId;

  const GamePlayScreen({super.key, required this.gameTypeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/juegos');
      }
    }

    final type = session.data.gameType ?? '';
    switch (type) {
      case ActivityTypes.questionnaire:
      case ActivityTypes.intruder:
      case ActivityTypes.fillBlank:
        return QuestionnaireGameView(session: session, onExit: exit);
      case ActivityTypes.memoryGame:
        return MemoramaGameView(session: session, onExit: exit);
      case ActivityTypes.fastMemory:
        return MemoriaRapidaGameView(session: session, onExit: exit);
      case ActivityTypes.pairs:
        return ParesGameView(session: session, onExit: exit);
      case ActivityTypes.lottery:
        return LoteriaGameView(session: session, onExit: exit);
      case ActivityTypes.maze:
        return LaberintoGameView(session: session, onExit: exit);
      case ActivityTypes.catLines:
        return TripasGameView(session: session, onExit: exit);
      case ActivityTypes.findTheWord:
        return SopaLetrasGameView(session: session, onExit: exit);
      default:
        return UnderConstructionScreen(title: gameInfoFor(type).title);
    }
  }
}
