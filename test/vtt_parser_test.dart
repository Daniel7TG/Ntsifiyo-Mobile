import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/features/content/logic/vtt_parser.dart';

void main() {
  group('parseWebVtt', () {
    test('parsea un archivo básico con cabecera WEBVTT', () {
      const vtt = '''
WEBVTT

00:00:01.000 --> 00:00:04.000
Jñaa

00:00:04.500 --> 00:00:07.000
Ndezhe
''';
      final track = parseWebVtt(vtt);
      expect(track.cues, hasLength(2));
      expect(track.cues[0].text, 'Jñaa');
      expect(track.cues[0].start, const Duration(seconds: 1));
      expect(track.cues[0].end, const Duration(seconds: 4));
      expect(track.cues[1].text, 'Ndezhe');
    });

    test('ignora bloques NOTE y REGION', () {
      const vtt = '''
WEBVTT

NOTE
Esto es un comentario que no debe aparecer como cue.

REGION
id:fred
width:40%

00:00:01.000 --> 00:00:02.000
Hola
''';
      final track = parseWebVtt(vtt);
      expect(track.cues, hasLength(1));
      expect(track.cues.single.text, 'Hola');
    });

    test('acepta identificador de cue antes de la línea de tiempos', () {
      const vtt = '''
WEBVTT

1
00:00:01.000 --> 00:00:02.000
Uno

cue-dos
00:00:02.000 --> 00:00:03.000
Dos
''';
      final track = parseWebVtt(vtt);
      expect(track.cues, hasLength(2));
      expect(track.cues[0].text, 'Uno');
      expect(track.cues[1].text, 'Dos');
    });

    test('descarta los ajustes de posición tras el timestamp', () {
      const vtt = '''
WEBVTT

00:00:01.000 --> 00:00:02.000 align:center line:90%
Centrado
''';
      final track = parseWebVtt(vtt);
      expect(track.cues, hasLength(1));
      expect(track.cues.single.end, const Duration(seconds: 2));
    });

    test('acepta formato corto mm:ss.mmm', () {
      const vtt = '''
WEBVTT

01:02.500 --> 01:05.000
Corto
''';
      final track = parseWebVtt(vtt);
      expect(track.cues.single.start,
          const Duration(minutes: 1, milliseconds: 2500));
      expect(track.cues.single.end, const Duration(minutes: 1, seconds: 5));
    });

    test('acepta coma decimal (estilo SubRip)', () {
      const vtt = '''
WEBVTT

00:00:01,250 --> 00:00:02,750
Coma
''';
      final track = parseWebVtt(vtt);
      expect(track.cues.single.start,
          const Duration(seconds: 1, milliseconds: 250));
      expect(track.cues.single.end,
          const Duration(seconds: 2, milliseconds: 750));
    });

    test('tolera CRLF', () {
      const vtt = 'WEBVTT\r\n\r\n00:00:01.000 --> 00:00:02.000\r\nHola\r\n';
      final track = parseWebVtt(vtt);
      expect(track.cues, hasLength(1));
      expect(track.cues.single.text, 'Hola');
    });

    test('conserva un cue multilínea', () {
      const vtt = '''
WEBVTT

00:00:01.000 --> 00:00:03.000
Primera línea
Segunda línea
''';
      final track = parseWebVtt(vtt);
      expect(track.cues.single.text, 'Primera línea\nSegunda línea');
    });

    test('conserva un cue de menos de un segundo (el bug del parser viejo)',
        () {
      const vtt = '''
WEBVTT

00:00:01.100 --> 00:00:01.600
Rápido
''';
      final track = parseWebVtt(vtt);
      expect(track.cues, hasLength(1));
      expect(track.cues.single.start,
          const Duration(seconds: 1, milliseconds: 100));
      expect(track.cues.single.end,
          const Duration(seconds: 1, milliseconds: 600));
    });

    test('entrada vacía o basura produce SubtitleTrack.empty', () {
      expect(parseWebVtt('').isEmpty, isTrue);
      expect(parseWebVtt('esto no es un vtt válido').isEmpty, isTrue);
    });
  });

  group('SubtitleTrack.cueAt', () {
    final track = SubtitleTrack([
      const SubtitleCue(
        start: Duration(seconds: 1),
        end: Duration(seconds: 3),
        text: 'A',
      ),
      const SubtitleCue(
        start: Duration(seconds: 3),
        end: Duration(seconds: 5),
        text: 'B',
      ),
    ]);

    test('start es inclusivo', () {
      expect(track.cueAt(const Duration(seconds: 1))?.text, 'A');
    });

    test('end es exclusivo: el límite pertenece al siguiente cue', () {
      expect(track.cueAt(const Duration(seconds: 3))?.text, 'B');
    });

    test('sin cue activo devuelve null', () {
      expect(track.cueAt(const Duration(seconds: 10)), isNull);
      expect(track.cueAt(Duration.zero), isNull);
    });
  });
}
