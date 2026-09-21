import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/services/misc_services.dart';
import '../../shared/immersive_chrome.dart';
import '../../shared/widgets/states.dart';
import 'player/media_playback_source.dart';
import 'player/media_player_controller.dart';
import 'player/media_player_view.dart';

/// Envoltorio del reproductor: resuelve `mediaId` contra `MediaService` y
/// delega TODA la lógica de reproducción/subtítulos a
/// [MediaPlayerController] + [MediaPlayerView] (`lib/features/content/player/`).
/// Esa separación es deliberada — es la pieza que se podrá incrustar en una
/// futura actividad `GameType.MEDIA` sin pasar por esta pantalla ni por
/// `MediaService`, construyendo su propio [MediaPlaybackSource] a partir
/// del contenido de la actividad.
///
/// Este archivo solo añade lo que es específico de "pantalla completa
/// dentro del árbol de navegación": el `AppBar`, y el modo horizontal
/// inmersivo para video (mirror de `MapScreen`, ver
/// `lib/shared/immersive_chrome.dart`).
class MediaPlayerScreen extends ConsumerStatefulWidget {
  final int? mediaId;
  final MediaItem? item;

  const MediaPlayerScreen({super.key, required this.mediaId, this.item});

  @override
  ConsumerState<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends ConsumerState<MediaPlayerScreen> {
  MediaPlayerController? _controller;
  Object? _resolveError;
  bool _fullscreen = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final mediaId = widget.mediaId;
    if (mediaId == null) {
      setState(() => _resolveError = StateError('Contenido no encontrado.'));
      return;
    }
    try {
      final stream =
          await ref.read(mediaServiceProvider).getMediaStream(mediaId);
      final source =
          MediaPlaybackSource.fromStream(stream, item: widget.item);
      final controller = MediaPlayerController(source);
      await controller.load();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      if (!mounted) return;
      setState(() => _resolveError = e);
    }
  }

  Future<void> _setFullscreen(bool value) async {
    if (value) {
      await enterImmersiveLandscape();
    } else {
      await exitImmersiveLandscape();
    }
    if (!mounted) return;
    setState(() => _fullscreen = value);
  }

  @override
  void dispose() {
    // Por si se sale de la pantalla estando en horizontal inmersivo: la app
    // no debe quedar atascada fuera de vertical.
    if (_fullscreen) exitImmersiveLandscape();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (controller == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(widget.item?.title ?? 'Reproductor')),
        body: _resolveError != null
            ? ErrorState(
                message: 'No se pudo cargar el contenido. Intenta más tarde.',
                onRetry: () {
                  setState(() => _resolveError = null);
                  _resolve();
                },
              )
            : const SizedBox.shrink(),
      );
    }

    if (_fullscreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _setFullscreen(false);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: MediaPlayerView(
              controller: controller,
              fullscreen: true,
              onToggleFullscreen: () => _setFullscreen(false),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(widget.item?.title ?? 'Reproductor')),
      body: MediaPlayerView(
        controller: controller,
        onToggleFullscreen: () => _setFullscreen(true),
      ),
    );
  }
}
