import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emociones del coyote (mirror de los PNG de la web: assets/images/coyote/).
enum CoyoteEmotion {
  saludo,
  esperando,
  pensando,
  celebracion,
  triste,
  sorpresa;

  String get asset => 'assets/coyote/$name.webp';
}

class CoyoteState {
  final CoyoteEmotion emotion;
  final String message;
  final bool onLeft;

  const CoyoteState({
    this.emotion = CoyoteEmotion.esperando,
    this.message = '',
    this.onLeft = true,
  });

  CoyoteState copyWith({
    CoyoteEmotion? emotion,
    String? message,
    bool? onLeft,
  }) =>
      CoyoteState(
        emotion: emotion ?? this.emotion,
        message: message ?? this.message,
        onLeft: onLeft ?? this.onLeft,
      );
}

/// Estado del coyote acompañante (mirror de CoyoteContext.jsx).
class CoyoteController extends Notifier<CoyoteState> {
  Timer? _timer;

  @override
  CoyoteState build() {
    ref.onDispose(() => _timer?.cancel());
    return const CoyoteState();
  }

  /// Muestra un mensaje. Pasada `duration`, la burbuja se limpia y el coyote
  /// vuelve a su pose de espera (igual que la web).
  void speak(
    String message, {
    CoyoteEmotion emotion = CoyoteEmotion.esperando,
    Duration duration = const Duration(seconds: 15),
  }) {
    _timer?.cancel();
    state = state.copyWith(message: message, emotion: emotion);
    if (duration > Duration.zero) {
      _timer = Timer(duration, () {
        state = state.copyWith(
            message: '', emotion: CoyoteEmotion.esperando);
      });
    }
  }

  /// Reacción a un acierto/error dentro de un juego.
  void triggerReaction({required bool correct}) {
    if (correct) {
      speak('¡Excelente! ¡Sigue así!',
          emotion: CoyoteEmotion.celebracion,
          duration: const Duration(seconds: 2));
    } else {
      speak('¡Oh! No te preocupes, ¡inténtalo de nuevo!',
          emotion: CoyoteEmotion.triste,
          duration: const Duration(seconds: 2));
    }
  }

  /// El coyote se teletransporta al otro lado cuando estorba.
  void toggleSide() => state = state.copyWith(onLeft: !state.onLeft);

  void clear() {
    _timer?.cancel();
    state = state.copyWith(message: '', emotion: CoyoteEmotion.esperando);
  }
}

final coyoteProvider =
    NotifierProvider<CoyoteController, CoyoteState>(CoyoteController.new);
