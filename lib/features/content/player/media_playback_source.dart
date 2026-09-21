import '../../../data/models/models.dart';

/// Describe QUÉ reproducir, sin saber de dónde salió — mediaId de la
/// sección Contenido hoy, o el contenido embebido de una actividad
/// `GameType.MEDIA` en el futuro (ver `GameData` en
/// `lib/data/models/models.dart`). [MediaPlayerController] solo conoce
/// esta clase, nunca `MediaItem`/`StreamResources` directamente, para que
/// una actividad futura pueda construir su propio `MediaPlaybackSource`
/// sin pasar por `MediaService`.
class MediaPlaybackSource {
  final String url;
  final String? espSubtitlesUrl;
  final String? mazSubtitlesUrl;
  final String? posterUrl;
  final String title;

  const MediaPlaybackSource({
    required this.url,
    required this.title,
    this.espSubtitlesUrl,
    this.mazSubtitlesUrl,
    this.posterUrl,
  });

  /// El backend nombra cada objeto de media como
  /// `media_{tipo}_{id}.{webm|mp3}` (`MediaService.java` del backend:
  /// video → `.webm`, audio → `.mp3`), así que la extensión antes de la
  /// query string (el token PAR de OCI) es una señal fiable. No se deduce
  /// del tamaño del `VideoPlayerController` como hacía la pantalla
  /// anterior (`controller.value.size == 0`): eso solo se sabe DESPUÉS de
  /// `initialize()`, y hasta entonces la portada de audio no podía
  /// mostrarse.
  bool get isAudio {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.mp3') ||
        path.endsWith('.m4a') ||
        path.endsWith('.aac') ||
        path.endsWith('.wav') ||
        path.endsWith('.ogg');
  }

  factory MediaPlaybackSource.fromStream(
    StreamResources stream, {
    MediaItem? item,
  }) {
    return MediaPlaybackSource(
      url: stream.url,
      espSubtitlesUrl: stream.espSubtitlesUrl,
      mazSubtitlesUrl: stream.mazSubtitlesUrl,
      posterUrl: item?.overviewImage,
      title: item?.title ?? 'Contenido multimedia',
    );
  }
}
