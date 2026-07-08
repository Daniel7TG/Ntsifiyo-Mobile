import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../app/theme.dart';

/// Muestra la imagen de una palabra (ruta local precargada o URL remota).
class WordImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final double? width;
  final double? height;

  const WordImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p == null || p.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: AppColors.borderLight,
        child: const Icon(Icons.image_not_supported,
            color: AppColors.textLight),
      );
    }
    if (p.startsWith('http')) {
      return Image.network(p,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.borderLight,
                child: const Icon(Icons.broken_image,
                    color: AppColors.textLight),
              ));
    }
    if (p.startsWith('assets/')) {
      return Image.asset(p, fit: fit, width: width, height: height);
    }
    return Image.file(File(p),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.borderLight,
              child:
                  const Icon(Icons.broken_image, color: AppColors.textLight),
            ));
  }
}

/// Reproductor global simple para audios de palabras.
final _audioPlayer = AudioPlayer();

Future<void> playWordAudio(String? path) async {
  if (path == null || path.isEmpty) return;
  try {
    await _audioPlayer.stop();
    if (path.startsWith('http')) {
      await _audioPlayer.setUrl(path);
    } else if (path.startsWith('assets/')) {
      await _audioPlayer.setAsset(path);
    } else {
      await _audioPlayer.setFilePath(path);
    }
    await _audioPlayer.play();
  } catch (_) {
    // Audio no disponible: silencioso, como la web.
  }
}

/// Botón redondo de audio (mirror del botón volume_up de la web).
class WordAudioButton extends StatelessWidget {
  final String? audioPath;
  final double size;
  final Color color;

  const WordAudioButton({
    super.key,
    required this.audioPath,
    this.size = 40,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = audioPath != null && audioPath!.isNotEmpty;
    return GestureDetector(
      onTap: enabled ? () => playWordAudio(audioPath) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.12)
              : AppColors.borderLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? color.withValues(alpha: 0.3)
                : AppColors.border,
            width: 2,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                      color: darken(color, 0.25),
                      offset: const Offset(0, 3),
                      blurRadius: 0)
                ]
              : null,
        ),
        child: Icon(
          enabled ? Icons.volume_up : Icons.volume_off,
          size: size * 0.5,
          color: enabled ? color : AppColors.textLight,
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
  final VoidCallback? onTap;
  final GameCardState cardState;
  final bool disabled;

  const GameCardWidget({
    super.key,
    this.text,
    this.imagePath,
    this.audioPath,
    this.onTap,
    this.cardState = GameCardState.none,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (cardState) {
      GameCardState.correct => AppColors.success,
      GameCardState.incorrect => AppColors.error,
      GameCardState.none => AppColors.border,
    };
    final bgColor = switch (cardState) {
      GameCardState.correct => AppColors.success.withValues(alpha: 0.08),
      GameCardState.incorrect => AppColors.error.withValues(alpha: 0.08),
      GameCardState.none => Colors.white,
    };

    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    final hasAudio = audioPath != null && audioPath!.isNotEmpty;
    final hasText = text != null && text!.isNotEmpty;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: cardState == GameCardState.none
                  ? const Color(0xFFCBD5E1)
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
                  child: WordImage(path: imagePath),
                ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasText)
                      Flexible(
                        child: Text(
                          text!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    if (hasText && hasAudio) const SizedBox(width: 8),
                    if (hasAudio)
                      WordAudioButton(audioPath: audioPath, size: 34),
                    if (!hasText && !hasAudio && !hasImage)
                      const Icon(Icons.help_outline,
                          color: AppColors.textLight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feedback flotante de acierto/error (mirror de GameAlert.jsx).
void showGameFeedback(BuildContext context, {required bool correct}) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
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
  Future.delayed(const Duration(milliseconds: 1200), entry.remove);
}
