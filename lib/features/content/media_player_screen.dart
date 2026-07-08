import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../app/theme.dart';
import '../../data/models/models.dart';
import '../../data/services/misc_services.dart';
import '../../shared/widgets/states.dart';

/// Reproductor con subtítulos bilingües (mirror de MediaPlayerView.jsx).
/// Muestra siempre el texto mazahua; el español se puede alternar.
class MediaPlayerScreen extends ConsumerStatefulWidget {
  final int mediaId;
  final MediaItem? item;

  const MediaPlayerScreen({super.key, required this.mediaId, this.item});

  @override
  ConsumerState<MediaPlayerScreen> createState() =>
      _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends ConsumerState<MediaPlayerScreen> {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;
  bool _showSpanish = false;

  List<SubtitleLine> _mazSubs = [];
  List<SubtitleLine> _espSubs = [];
  String _mazText = '...';
  String _espText = '...';
  Timer? _subTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stream =
          await ref.read(mediaServiceProvider).getMediaStream(widget.mediaId);
      if (stream.url.isEmpty) {
        throw Exception('El contenido no tiene un recurso reproducible.');
      }

      // Subtítulos: lista embebida (maz+esp juntos) o archivos VTT por idioma.
      if (stream.subtitles.isNotEmpty) {
        _mazSubs = stream.subtitles;
        _espSubs = stream.subtitles;
      } else {
        if ((stream.mazSubtitlesUrl ?? '').isNotEmpty) {
          _mazSubs = await _fetchVtt(stream.mazSubtitlesUrl!, isMaz: true);
        }
        if ((stream.espSubtitlesUrl ?? '').isNotEmpty) {
          _espSubs = await _fetchVtt(stream.espSubtitlesUrl!, isMaz: false);
        }
      }

      final controller =
          VideoPlayerController.networkUrl(Uri.parse(stream.url));
      await controller.initialize();
      controller.play();

      _subTimer = Timer.periodic(
          const Duration(milliseconds: 250), (_) => _updateSubtitles());

      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar el contenido. Intenta más tarde.';
        _loading = false;
      });
    }
  }

  /// Parser mínimo de WebVTT → SubtitleLine.
  Future<List<SubtitleLine>> _fetchVtt(String url,
      {required bool isMaz}) async {
    try {
      final response = await Dio().get<String>(url,
          options: Options(responseType: ResponseType.plain));
      final lines = (response.data ?? '').split(RegExp(r'\r?\n'));
      final cues = <SubtitleLine>[];
      for (var i = 0; i < lines.length; i++) {
        if (!lines[i].contains('-->')) continue;
        final parts = lines[i].split('-->');
        final start = _parseVttTime(parts[0].trim());
        final end = _parseVttTime(parts[1].trim().split(' ').first);
        final textLines = <String>[];
        var j = i + 1;
        while (j < lines.length && lines[j].trim().isNotEmpty) {
          textLines.add(lines[j]);
          j++;
        }
        final text = textLines.join('\n');
        cues.add(SubtitleLine(
          mazahuaText: isMaz ? text : null,
          spanishText: isMaz ? null : text,
          timeStart: start,
          timeEnd: end,
        ));
      }
      return cues;
    } catch (_) {
      return [];
    }
  }

  int _parseVttTime(String raw) {
    final parts = raw.split(':');
    try {
      if (parts.length == 3) {
        return (double.parse(parts[0]) * 3600 +
                double.parse(parts[1]) * 60 +
                double.parse(parts[2].replaceAll(',', '.')))
            .floor();
      }
      if (parts.length == 2) {
        return (double.parse(parts[0]) * 60 +
                double.parse(parts[1].replaceAll(',', '.')))
            .floor();
      }
    } catch (_) {}
    return 0;
  }

  void _updateSubtitles() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final seconds = controller.value.position.inSeconds;

    String pick(List<SubtitleLine> subs, bool maz) {
      for (final s in subs) {
        if (seconds >= s.timeStart && seconds < s.timeEnd) {
          final text = maz ? s.mazahuaText : s.spanishText;
          if (text != null && text.isNotEmpty) return text;
        }
      }
      return '...';
    }

    final maz = pick(_mazSubs, true);
    final esp = pick(_espSubs, false);
    if (maz != _mazText || esp != _espText) {
      setState(() {
        _mazText = maz;
        _espText = esp;
      });
    }
  }

  @override
  void dispose() {
    _subTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  bool get _isAudio {
    final controller = _controller;
    if (controller == null) return true;
    final size = controller.value.size;
    return size.width == 0 || size.height == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.item?.title ?? 'Reproductor'),
        actions: [
          IconButton(
            tooltip: _showSpanish
                ? 'Ocultar español'
                : 'Mostrar traducción al español',
            icon: Icon(
              Icons.translate,
              color: _showSpanish ? AppColors.primary : AppColors.textLight,
            ),
            onPressed: () => setState(() => _showSpanish = !_showSpanish),
          ),
        ],
      ),
      body: _loading
          ? const LoadingState(message: 'Preparando el contenido...')
          : _error != null
              ? ErrorState(message: _error!)
              : _buildPlayer(),
    );
  }

  Widget _buildPlayer() {
    final controller = _controller!;

    return Column(
      children: [
        // Área de video / portada de audio
        Expanded(
          child: Center(
            child: _isAudio
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.accentPink.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.accentPink, width: 3),
                        ),
                        child: const Icon(Icons.music_note,
                            size: 80, color: AppColors.accentPink),
                      ),
                    ],
                  )
                : AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
          ),
        ),

        // Subtítulos bilingües
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Column(
            children: [
              Text(
                _mazText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              if (_showSpanish) ...[
                const SizedBox(height: 6),
                Text(
                  _espText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Controles
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, _) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: AppColors.border,
                    backgroundColor: AppColors.borderLight,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _fmt(value.position),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                  IconButton(
                    iconSize: 52,
                    color: AppColors.primary,
                    icon: Icon(value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled),
                    onPressed: () => value.isPlaying
                        ? controller.pause()
                        : controller.play(),
                  ),
                  Text(
                    _fmt(value.duration),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  String _fmt(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
