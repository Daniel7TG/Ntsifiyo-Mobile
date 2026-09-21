import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../logic/vtt_parser.dart';
import 'media_playback_source.dart';

/// Función inyectable para bajar el contenido de un VTT — por defecto pega
/// directo a la URL (los VTT viven en OCI con un PAR ya autenticado, no
/// necesitan pasar por el `ApiClient`/JWT del backend). Se inyecta en los
/// tests para no depender de red.
typedef SubtitleFetcher = Future<String> Function(String url);

Future<String> _defaultSubtitleFetcher(String url) async {
  final response = await Dio().get<String>(
    url,
    options: Options(
      responseType: ResponseType.plain,
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  return response.data ?? '';
}

/// Controlador de reproducción, sin Riverpod y sin `BuildContext`: es la
/// pieza que se puede incrustar tal cual en una futura actividad
/// `GameType.MEDIA` (`GameData` en `lib/data/models/models.dart`), pasando
/// un [MediaPlaybackSource] propio en vez de resolver un `mediaId` contra
/// `MediaService`. `MediaPlayerScreen` es hoy el único llamador, pero solo
/// hace de envoltorio: resuelve el `mediaId` y delega aquí toda la lógica
/// de reproducción y subtítulos.
class MediaPlayerController extends ChangeNotifier {
  /// El parámetro se llama `fetch` (no `_fetch`) a propósito, para que un
  /// test en otra librería pueda inyectarlo por nombre; un formal
  /// `this._fetch` privado no sería invocable desde fuera de este archivo.
  MediaPlayerController(
    this.source, {
    SubtitleFetcher fetch = _defaultSubtitleFetcher,
    // ignore: prefer_initializing_formals
  }) : _fetch = fetch;

  final MediaPlaybackSource source;
  final SubtitleFetcher _fetch;

  VideoPlayerController? _video;
  VideoPlayerController? get video => _video;

  Timer? _cueTimer;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Object? _error;
  Object? get error => _error;

  SubtitleTrack _mazTrack = SubtitleTrack.empty;
  SubtitleTrack _espTrack = SubtitleTrack.empty;

  bool get hasSpanish => _espTrack.isNotEmpty;
  bool get hasVideo => _video != null && !source.isAudio;

  SubtitleCue? _mazCue;
  SubtitleCue? get mazCue => _mazCue;

  SubtitleCue? _espCue;
  SubtitleCue? get espCue => _espCue;

  bool _showSpanish = false;
  bool get showSpanish => _showSpanish;

  bool get isPlaying => _video?.value.isPlaying ?? false;
  bool get isBuffering => _video?.value.isBuffering ?? false;
  Duration get position => _video?.value.position ?? Duration.zero;
  Duration get duration => _video?.value.duration ?? Duration.zero;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (source.url.isEmpty) {
        throw StateError('El contenido no tiene un recurso reproducible.');
      }

      // Los dos VTT se bajan en paralelo; que uno falle no debe tumbar el
      // video — esa pista de subtítulos simplemente queda vacía.
      final results = await Future.wait([
        _loadTrack(source.mazSubtitlesUrl),
        _loadTrack(source.espSubtitlesUrl),
      ]);
      _mazTrack = results[0];
      _espTrack = results[1];

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(source.url),
      );
      await controller.initialize();
      await controller.play();
      _video = controller;

      _cueTimer = Timer.periodic(
        const Duration(milliseconds: 200),
        (_) => _tickCues(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SubtitleTrack> _loadTrack(String? url) async {
    if (url == null || url.isEmpty) return SubtitleTrack.empty;
    try {
      final contents = await _fetch(url);
      return parseWebVtt(contents);
    } catch (_) {
      return SubtitleTrack.empty;
    }
  }

  void _tickCues() {
    final controller = _video;
    if (controller == null || !controller.value.isInitialized) return;

    final pos = controller.value.position;
    final maz = _mazTrack.cueAt(pos);
    final esp = _espTrack.cueAt(pos);

    if (maz?.text != _mazCue?.text || esp?.text != _espCue?.text) {
      _mazCue = maz;
      _espCue = esp;
      notifyListeners();
    }
  }

  void play() => _video?.play();
  void pause() => _video?.pause();

  void togglePlayPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void seek(Duration position) => _video?.seekTo(position);

  void seekBy(Duration offset) {
    final controller = _video;
    if (controller == null) return;
    final target = controller.value.position + offset;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > controller.value.duration
            ? controller.value.duration
            : target);
    controller.seekTo(clamped);
  }

  /// Solo hace efecto si hay subtítulos en español — por defecto se
  /// muestra siempre mazahua, español es opt-in explícito del usuario.
  void toggleSpanish() {
    if (!hasSpanish) return;
    _showSpanish = !_showSpanish;
    notifyListeners();
  }

  @override
  void dispose() {
    _cueTimer?.cancel();
    _video?.dispose();
    super.dispose();
  }
}
