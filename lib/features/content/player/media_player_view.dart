import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../app/palette.dart';
import '../../../app/theme.dart';
import '../../../core/api/error_messages.dart';
import '../../../core/storage/media_cache_key.dart';
import '../../../shared/widgets/coyote_loading.dart';
import '../../../shared/widgets/states.dart';
import '../logic/vtt_parser.dart';
import 'media_player_controller.dart';

/// Widget de presentación puro del reproductor: sin `Scaffold`, sin
/// `AppBar`, sin navegación — solo un [MediaPlayerController]. Es la pieza
/// pensada para incrustarse en una futura actividad `GameType.MEDIA`;
/// `MediaPlayerScreen` es hoy su único envoltorio (resuelve el `mediaId` y
/// gestiona la pantalla completa alrededor de este widget).
///
/// Mazahua se muestra siempre; español es un interruptor explícito del
/// usuario (`MediaPlayerController.toggleSpanish`), nunca al revés.
class MediaPlayerView extends StatelessWidget {
  final MediaPlayerController controller;

  /// En modo pantalla completa el video ocupa todo el espacio disponible
  /// y los subtítulos/controles se superponen con un scrim, en vez de
  /// repartirse en una columna.
  final bool fullscreen;
  final VoidCallback? onToggleFullscreen;

  const MediaPlayerView({
    super.key,
    required this.controller,
    this.fullscreen = false,
    this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const CoyoteLoadingIndicator(
            message: 'Preparando el contenido...',
          );
        }
        if (controller.error != null) {
          return ErrorState(
            message: friendlyErrorMessage(controller.error!),
            onRetry: controller.load,
          );
        }
        return fullscreen ? _buildFullscreen(context) : _buildNormal(context);
      },
    );
  }

  Widget _buildNormal(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Center(child: _MediaSurface(controller: controller))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SubtitleBox(controller: controller),
        ),
        const SizedBox(height: 12),
        _Controls(
          controller: controller,
          onToggleFullscreen: onToggleFullscreen,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFullscreen(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(child: _MediaSurface(controller: controller)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SubtitleBox(controller: controller, onDark: true),
                    _Controls(
                      controller: controller,
                      onToggleFullscreen: onToggleFullscreen,
                      onDark: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Video o portada de audio, según [MediaPlayerController.hasVideo].
class _MediaSurface extends StatelessWidget {
  final MediaPlayerController controller;
  const _MediaSurface({required this.controller});

  @override
  Widget build(BuildContext context) {
    final video = controller.video;
    if (!controller.hasVideo || video == null) {
      return _AudioCover(posterUrl: controller.source.posterUrl);
    }
    return AspectRatio(
      aspectRatio: video.value.aspectRatio,
      child: VideoPlayer(video),
    );
  }
}

class _AudioCover extends StatelessWidget {
  final String? posterUrl;
  const _AudioCover({this.posterUrl});

  @override
  Widget build(BuildContext context) {
    if ((posterUrl ?? '').isEmpty) return const _AudioDisc();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.kidCard),
      child: CachedNetworkImage(
        imageUrl: posterUrl!,
        cacheKey: mediaCacheKey(posterUrl!),
        width: 220,
        height: 220,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const _AudioDisc(),
      ),
    );
  }
}

class _AudioDisc extends StatelessWidget {
  const _AudioDisc();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.accentPink.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: adaptBrand(context, AppColors.accentPink),
          width: 3,
        ),
      ),
      child: Icon(
        Icons.music_note,
        size: 80,
        color: adaptBrand(context, AppColors.accentPink),
      ),
    );
  }
}

/// Caja de subtítulos: mazahua siempre visible, español solo si el
/// controlador lo tiene activado y hay pista disponible.
class _SubtitleBox extends StatelessWidget {
  final MediaPlayerController controller;
  final bool onDark;
  const _SubtitleBox({required this.controller, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final mazStyle = TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w800,
      fontSize: 18,
      color: onDark ? Colors.white : adaptBrand(context, AppColors.primary),
    );
    final espStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: onDark ? Colors.white70 : context.palette.textMuted,
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ProgressiveSubtitle(
          key: ValueKey('maz-${controller.mazCue}'),
          cue: controller.mazCue,
          style: mazStyle,
        ),
        if (controller.showSpanish && controller.hasSpanish) ...[
          const SizedBox(height: 6),
          _ProgressiveSubtitle(
            key: ValueKey('esp-${controller.espCue}'),
            cue: controller.espCue,
            style: espStyle,
          ),
        ],
      ],
    );

    if (onDark) {
      return Padding(padding: const EdgeInsets.only(bottom: 8), child: content);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.palette.border, width: 2),
      ),
      child: content,
    );
  }
}

/// Revela las palabras del cue activo progresivamente a lo largo de su
/// ventana de tiempo (mirror de ProgressiveSubtitle en MediaPlayerView.jsx).
/// Sin cue activo se reserva la altura pero no se pinta ningún texto — ya
/// no se muestra un `'...'` de relleno.
class _ProgressiveSubtitle extends StatefulWidget {
  final SubtitleCue? cue;
  final TextStyle style;

  const _ProgressiveSubtitle({super.key, required this.cue, required this.style});

  @override
  State<_ProgressiveSubtitle> createState() => _ProgressiveSubtitleState();
}

class _ProgressiveSubtitleState extends State<_ProgressiveSubtitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final cue = widget.cue;
    final cueDuration = cue == null
        ? const Duration(seconds: 3)
        : cue.end - cue.start;
    // 95% del cue para que la animación termine antes de que llegue el
    // siguiente.
    final ms = (cueDuration.inMilliseconds * 0.95).clamp(200, 60000).toInt();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.cue?.text ?? '';
    if (text.isEmpty) {
      // Reserva la altura de una línea para que la caja no salte al
      // aparecer/desaparecer el cue.
      return Text(' ', style: widget.style);
    }

    final words = text.split(RegExp(r'\s+'))..removeWhere((w) => w.isEmpty);
    if (words.isEmpty) {
      return Text(text, textAlign: TextAlign.center, style: widget.style);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final revealed = (_controller.value * words.length).ceil();
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              for (var i = 0; i < words.length; i++)
                TextSpan(
                  text: i == 0 ? words[i] : ' ${words[i]}',
                  style: widget.style.copyWith(
                    color: (widget.style.color ?? AppColors.textMain)
                        .withValues(alpha: i < revealed ? 1 : 0.25),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Barra de progreso + play/pause + ±10s + interruptor de español +
/// pantalla completa.
class _Controls extends StatelessWidget {
  final MediaPlayerController controller;
  final VoidCallback? onToggleFullscreen;
  final bool onDark;

  const _Controls({
    required this.controller,
    this.onToggleFullscreen,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final video = controller.video;
    final mutedColor = onDark ? Colors.white70 : context.palette.textMuted;
    final primary = onDark ? Colors.white : adaptBrand(context, AppColors.primary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (video != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VideoProgressIndicator(
              video,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: primary,
                bufferedColor: onDark ? Colors.white38 : context.palette.border,
                backgroundColor:
                    onDark ? Colors.white24 : context.palette.borderLight,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_fmt(controller.position),
                style: TextStyle(fontSize: 12, color: mutedColor)),
            IconButton(
              tooltip: 'Retroceder 10 segundos',
              color: primary,
              icon: const Icon(Icons.replay_10),
              onPressed: () => controller.seekBy(const Duration(seconds: -10)),
            ),
            IconButton(
              iconSize: 52,
              color: primary,
              icon: Icon(controller.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled),
              onPressed: controller.togglePlayPause,
            ),
            IconButton(
              tooltip: 'Adelantar 10 segundos',
              color: primary,
              icon: const Icon(Icons.forward_10),
              onPressed: () => controller.seekBy(const Duration(seconds: 10)),
            ),
            Text(_fmt(controller.duration),
                style: TextStyle(fontSize: 12, color: mutedColor)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Español',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: mutedColor)),
            Switch(
              value: controller.showSpanish,
              onChanged: controller.hasSpanish
                  ? (_) => controller.toggleSpanish()
                  : null,
              activeTrackColor: adaptBrand(context, AppColors.success),
            ),
            if (controller.hasVideo && onToggleFullscreen != null)
              IconButton(
                tooltip: onDark ? 'Salir de pantalla completa' : 'Pantalla completa',
                color: primary,
                icon: Icon(onDark ? Icons.fullscreen_exit : Icons.fullscreen),
                onPressed: onToggleFullscreen,
              ),
          ],
        ),
      ],
    );
  }

  String _fmt(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
