/// Parser de subtítulos WebVTT, puro y sin Flutter (testeado en
/// `test/vtt_parser_test.dart`, igual que los generadores de
/// `lib/features/games/logic/`).
///
/// No se reutiliza `WebVTTCaptionFile` de `package:video_player`: vive en
/// `lib/src/web_vtt.dart` pero el paquete solo exporta
/// `src/closed_caption_file.dart` — importar `src/` violaría
/// `implementation_imports`. Este parser también trabaja en milisegundos
/// completos (no en segundos truncados), a diferencia del parser que traía
/// antes `media_player_screen.dart`, que perdía cualquier cue de menos de
/// un segundo.
library;

/// Una línea de subtítulo con su ventana de tiempo, en milisegundos.
class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleCue({
    required this.start,
    required this.end,
    required this.text,
  });

  /// `start` inclusivo, `end` exclusivo — así dos cues consecutivos sin
  /// solape no compiten por el mismo instante límite.
  bool contains(Duration position) => position >= start && position < end;
}

/// Una pista de subtítulos ya parseada, en un solo idioma.
class SubtitleTrack {
  final List<SubtitleCue> cues;
  const SubtitleTrack(this.cues);

  static const empty = SubtitleTrack([]);

  bool get isEmpty => cues.isEmpty;
  bool get isNotEmpty => cues.isNotEmpty;

  /// El cue activo en `position`, o `null` si no hay ninguno (silencio
  /// entre líneas, o fuera de rango).
  SubtitleCue? cueAt(Duration position) {
    for (final cue in cues) {
      if (cue.contains(position)) return cue;
    }
    return null;
  }
}

const _webVttMetadataTags = {'WEBVTT', 'NOTE', 'REGION', 'STYLE'};

/// Parsea el contenido de un archivo `.vtt`. Nunca lanza: una entrada vacía
/// o corrupta produce [SubtitleTrack.empty] en vez de reventar el
/// reproductor por un archivo de subtítulos mal formado.
SubtitleTrack parseWebVtt(String contents) {
  try {
    final lines = contents.split(RegExp(r'\r\n|\r|\n'));
    final cues = <SubtitleCue>[];

    var i = 0;
    while (i < lines.length) {
      final line = lines[i].trim();

      if (line.isEmpty || !line.contains('-->')) {
        i++;
        continue;
      }

      // La línea de tiempos puede llevar ajustes después
      // (`align:center line:90%`): solo nos interesan los dos timestamps.
      final arrowParts = line.split('-->');
      if (arrowParts.length < 2) {
        i++;
        continue;
      }
      final start = _parseTimestamp(arrowParts[0].trim());
      final endRaw = arrowParts[1].trim().split(RegExp(r'\s+')).first;
      final end = _parseTimestamp(endRaw);
      i++;

      if (start == null || end == null) continue;

      final textLines = <String>[];
      while (i < lines.length && lines[i].trim().isNotEmpty) {
        final textLine = lines[i].trim();
        // Un identificador de cue de texto (no numérico) antes de la línea
        // de tiempos ya se consumió arriba porque no contenía '-->'; aquí
        // solo puede aparecer texto real del cue.
        if (!_webVttMetadataTags.contains(textLine.split(' ').first)) {
          textLines.add(lines[i]);
        }
        i++;
      }

      final text = textLines.join('\n').trim();
      if (text.isNotEmpty) {
        cues.add(SubtitleCue(start: start, end: end, text: text));
      }
    }

    return SubtitleTrack(cues);
  } catch (_) {
    return SubtitleTrack.empty;
  }
}

/// Acepta `hh:mm:ss.mmm`, `mm:ss.mmm` y coma decimal (`,` en vez de `.`,
/// como en SubRip). Devuelve `null` si no se puede interpretar en vez de
/// lanzar, para que un timestamp roto descarte solo ese cue.
Duration? _parseTimestamp(String raw) {
  final normalized = raw.replaceAll(',', '.');
  final parts = normalized.split(':');
  try {
    if (parts.length == 3) {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = double.parse(parts[2]);
      return Duration(
        hours: hours,
        minutes: minutes,
        milliseconds: (seconds * 1000).round(),
      );
    }
    if (parts.length == 2) {
      final minutes = int.parse(parts[0]);
      final seconds = double.parse(parts[1]);
      return Duration(
        minutes: minutes,
        milliseconds: (seconds * 1000).round(),
      );
    }
  } catch (_) {
    return null;
  }
  return null;
}
