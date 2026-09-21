import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../app/palette.dart';
import '../../../app/theme.dart';
import '../../coyote/coyote_controller.dart';

String? _resolveLocalImageAsset(String? path, [int? wordId]) {
  if (path != null && path.isNotEmpty) {
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('img/')) return 'assets/dictionary/$path';
  }
  if (wordId != null && wordId > 0) {
    return 'assets/dictionary/img/$wordId.webp';
  }
  return null;
}

String? _resolveLocalAudioAsset(String? path, [int? wordId]) {
  if (path != null && path.isNotEmpty) {
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('audio/')) return 'assets/dictionary/$path';
  }
  if (wordId != null && wordId > 0) {
    return 'assets/dictionary/audio/$wordId.mp3';
  }
  return null;
}

/// Muestra la imagen de una palabra (ruta local precargada o URL remota).
class WordImage extends StatelessWidget {
  final String? path;
  final int? wordId;
  final BoxFit fit;
  final double? width;
  final double? height;

  const WordImage({
    super.key,
    required this.path,
    this.wordId,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    var p = path;
    final localFallback = _resolveLocalImageAsset(p, wordId);

    if ((p == null || p.isEmpty) && localFallback == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.white,
        child: Icon(Icons.image_not_supported, color: palette.textLight),
      );
    }

    final targetPath = (p != null && p.isNotEmpty) ? p : localFallback!;
    Widget imgWidget;

    if (targetPath.startsWith('http')) {
      imgWidget = CachedNetworkImage(
        imageUrl: targetPath,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => Container(
          color: Colors.white,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: palette.textLight),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          if (localFallback != null) {
            return Image.asset(
              localFallback,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (context, error, stackTrace) => _broken(palette),
            );
          }
          return _broken(palette);
        },
      );
    } else {
      // La ruta real primero, no el asset "adivinado" por wordId: ese
      // fallback solo existe para cuando no hay ruta real que resolver, no
      // para sustituir un medio que sí se descargó a disco (game_media/…).
      final resolved = targetPath;

      if (resolved.startsWith('assets/')) {
        imgWidget = Image.asset(
          resolved,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _broken(palette),
        );
      } else {
        imgWidget = Image.file(
          File(resolved),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            if (localFallback != null) {
              return Image.asset(
                localFallback,
                fit: fit,
                width: width,
                height: height,
                errorBuilder: (context, error, stackTrace) => _broken(palette),
              );
            }
            return _broken(palette);
          },
        );
      }
    }

    return Container(
      width: width,
      height: height,
      color: Colors.white,
      child: imgWidget,
    );
  }

  Widget _broken(AppPalette palette) {
    return Container(
      width: width,
      height: height,
      color: palette.borderLight,
      child: Icon(Icons.broken_image, color: palette.textLight),
    );
  }
}

/// Reproductor global simple para audios de palabras.
final _audioPlayer = AudioPlayer();

Future<void> playWordAudio(String? path, [int? wordId]) async {
  if ((path == null || path.isEmpty) && (wordId == null || wordId <= 0)) return;
  final localFallback = _resolveLocalAudioAsset(path, wordId);
  final p = (path != null && path.isNotEmpty) ? path : localFallback;
  if (p == null || p.isEmpty) return;

  try {
    await _audioPlayer.stop();
    if (p.startsWith('http')) {
      try {
        await _audioPlayer.setUrl(p);
      } catch (_) {
        if (localFallback != null) {
          await _audioPlayer.setAsset(localFallback);
        }
      }
    } else if (p.startsWith('assets/')) {
      await _audioPlayer.setAsset(p);
    } else {
      final file = File(p);
      if (file.existsSync()) {
        await _audioPlayer.setFilePath(p);
      } else if (localFallback != null) {
        await _audioPlayer.setAsset(localFallback);
      }
    }
    await _audioPlayer.play();
  } catch (_) {
    // Audio no disponible: silencioso, como la web.
  }
}

/// Botón redondo de audio (mirror del botón volume_up de la web).
class WordAudioButton extends StatelessWidget {
  final String? audioPath;
  final int? wordId;
  final double size;
  final Color color;

  const WordAudioButton({
    super.key,
    required this.audioPath,
    this.wordId,
    this.size = 40,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fallback = _resolveLocalAudioAsset(audioPath, wordId);
    final enabled = (audioPath != null && audioPath!.isNotEmpty) || fallback != null;
    final adapted = adaptBrand(context, color);
    return Semantics(
      button: true,
      label: enabled ? 'Reproducir audio' : 'Audio no disponible',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                playWordAudio(audioPath, wordId);
              }
            : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: enabled
                ? adapted.withValues(alpha: 0.12)
                : palette.borderLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: enabled ? adapted.withValues(alpha: 0.3) : palette.border,
              width: 2,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                        color: darken(adapted, 0.25),
                        offset: const Offset(0, 3),
                        blurRadius: 0)
                  ]
                : null,
          ),
          child: Icon(
            enabled ? Icons.volume_up : Icons.volume_off,
            size: size * 0.5,
            color: enabled ? adapted : palette.textLight,
          ),
        ),
      ),
    );
  }
}

/// Cuenta regresiva con reloj y barra, que se pone roja al agotarse el tiempo
/// (mirror de .game-top-bar__timer / .timer-low de la web).
class GameTimerBar extends StatelessWidget {
  final int timeLeft;
  final int total;

  /// Segundos restantes a partir de los cuales el reloj se pinta en rojo.
  final int lowTimeThreshold;

  const GameTimerBar({
    super.key,
    required this.timeLeft,
    required this.total,
    this.lowTimeThreshold = 15,
  });

  @override
  Widget build(BuildContext context) {
    final lowTime = timeLeft <= lowTimeThreshold;
    final color = lowTime ? AppColors.error : AppColors.primary;
    final minutes = timeLeft ~/ 60;
    final seconds = (timeLeft % 60).toString().padLeft(2, '0');

    return Semantics(
      label: 'Tiempo restante: $minutes minutos $seconds segundos',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            AnimatedScale(
              scale: lowTime ? 1.15 : 1,
              duration: const Duration(milliseconds: 300),
              child: Icon(Icons.timer, size: 20, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              '$minutes:$seconds',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : timeLeft / total,
                  minHeight: 7,
                  backgroundColor: context.palette.surface,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum GameCardState { none, correct, incorrect }

/// Tarjeta de juego (mirror de GameCard.jsx): texto y/o imagen y/o audio,
/// con estados de acierto/error.
class GameCardWidget extends StatelessWidget {
  final String? text;
  final String? imagePath;
  final String? audioPath;
  final int? wordId;
  final VoidCallback? onTap;
  final GameCardState cardState;
  final bool disabled;

  const GameCardWidget({
    super.key,
    this.text,
    this.imagePath,
    this.audioPath,
    this.wordId,
    this.onTap,
    this.cardState = GameCardState.none,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final borderColor = switch (cardState) {
      GameCardState.correct => AppColors.success,
      GameCardState.incorrect => AppColors.error,
      GameCardState.none => palette.border,
    };
    final bgColor = switch (cardState) {
      GameCardState.correct => AppColors.success.withValues(alpha: 0.08),
      GameCardState.incorrect => AppColors.error.withValues(alpha: 0.08),
      GameCardState.none => palette.surface,
    };

    final hasImage = (imagePath != null && imagePath!.isNotEmpty) ||
        (wordId != null && wordId! > 0);
    final hasAudio = (audioPath != null && audioPath!.isNotEmpty) ||
        (wordId != null && wordId! > 0);
    final hasText = text != null && text!.isNotEmpty;

    return Semantics(
      button: onTap != null,
      enabled: !disabled,
      label: hasText ? text : (hasImage ? 'Tarjeta con imagen' : null),
      child: GestureDetector(
        onTap: disabled
            ? null
            : onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: cardState == GameCardState.none
                    ? palette.shadowNeutral
                    : darken(borderColor, 0.2),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card - 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasImage)
                  AspectRatio(
                    aspectRatio: 1.4,
                    child: WordImage(path: imagePath, wordId: wordId),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasText)
                        Flexible(
                          child: Text(
                            text!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: palette.textMain,
                            ),
                          ),
                        ),
                      if (hasText && hasAudio) const SizedBox(width: 6),
                      if (hasAudio)
                        WordAudioButton(audioPath: audioPath, wordId: wordId, size: 32),
                      if (!hasText && !hasAudio && !hasImage)
                        Icon(Icons.help_outline, color: palette.textLight),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Feedback flotante de acierto/error (mirror de GameAlert.jsx), que además
/// hace reaccionar al coyote como en la web.
void showGameFeedback(BuildContext context, WidgetRef ref,
    {required bool correct}) {
  ref.read(coyoteProvider.notifier).triggerReaction(correct: correct);
  HapticFeedback.mediumImpact();
  if (!correct) {
    // Un golpe extra: el error necesita distinguirse del acierto al tacto,
    // no solo en pantalla.
    Future.delayed(
        const Duration(milliseconds: 80), HapticFeedback.mediumImpact);
  }

  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  var removed = false;
  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.paddingOf(context).top + 60,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: correct ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: darken(
                        correct ? AppColors.success : AppColors.error, 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(correct ? Icons.check_circle : Icons.cancel,
                      color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    correct ? '¡Correcto!' : '¡Incorrecto!',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 16,
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
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1200), () {
    // El jugador puede salir de la pantalla de juego antes de que expire
    // el temporizador; sin esta guarda, entry.remove() se llama sobre un
    // OverlayEntry ya desmontado.
    if (removed || !entry.mounted) return;
    removed = true;
    entry.remove();
  });
}
