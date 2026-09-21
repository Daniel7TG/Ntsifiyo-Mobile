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

  String get asset {
    if (this == CoyoteEmotion.pensando) {
      return 'assets/coyote/animations/thinking.webp';
    }
    if (this == CoyoteEmotion.esperando) {
      return 'assets/coyote/animations/waiting.webp';
    }
    return 'assets/coyote/$name.webp';
  }

  bool get isAnimated =>
      this == CoyoteEmotion.pensando || this == CoyoteEmotion.esperando;
}

class CoyoteState {
  final CoyoteEmotion emotion;
  final String message;
  final bool onLeft;
  final bool isVisible;

  const CoyoteState({
    this.emotion = CoyoteEmotion.esperando,
    this.message = '',
    this.onLeft = true,
    this.isVisible = true,
  });

  CoyoteState copyWith({
    CoyoteEmotion? emotion,
    String? message,
    bool? onLeft,
    bool? isVisible,
  }) =>
      CoyoteState(
        emotion: emotion ?? this.emotion,
        message: message ?? this.message,
        onLeft: onLeft ?? this.onLeft,
        isVisible: isVisible ?? this.isVisible,
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
    state = state.copyWith(message: message, emotion: emotion, isVisible: true);
    if (duration > Duration.zero) {
      _timer = Timer(duration, () {
        if (state.isVisible) {
          state = state.copyWith(
              message: '', emotion: CoyoteEmotion.esperando);
        }
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

  /// El coyote se desvanece con humo al hacer tap.
  void dismiss() {
    _timer?.cancel();
    state = state.copyWith(isVisible: false, message: '');
  }

  /// Restablece la visibilidad del coyote al cambiar de pantalla o tab.
  void resetForNewScreen([
    String? message,
    CoyoteEmotion emotion = CoyoteEmotion.esperando,
  ]) {
    _timer?.cancel();
    state = state.copyWith(
      isVisible: true,
      emotion: emotion,
      message: message ?? '',
    );
    if (message != null && message.isNotEmpty) {
      _timer = Timer(const Duration(seconds: 15), () {
        if (state.isVisible) {
          state = state.copyWith(
              message: '', emotion: CoyoteEmotion.esperando);
        }
      });
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
