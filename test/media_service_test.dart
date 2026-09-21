import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/data/models/models.dart';
import 'package:jnatrjo_mobile/data/services/misc_services.dart';
import 'package:jnatrjo_mobile/features/content/player/media_playback_source.dart';

void main() {
  group('parseMediaList', () {
    test('lee `mediaList` — la forma real del backend (PlayMediaListMediaDTO)',
        () {
      final result = parseMediaList({
        'mediaList': [
          {
            'id': 1,
            'title': 'Canción de los colores',
            'duration': 42,
            'overviewImage': 'https://oci.example.com/preview.webp',
            'mediaType': 'SONG',
            'description': 'Una canción',
            'difficult': 'EASY',
          },
        ],
      });

      expect(result, hasLength(1));
      expect(result.single.id, 1);
      expect(result.single.title, 'Canción de los colores');
      expect(result.single.duration, 42);
      expect(result.single.overviewImage, 'https://oci.example.com/preview.webp');
      expect(result.single.difficult, 'EASY');
    });

    test(
        'la regresión real: {"content": [...]} ya no es el camino principal, '
        'pero se sigue tolerando', () {
      final result = parseMediaList({
        'content': [
          {'id': 2, 'title': 'Leyenda del sol'},
        ],
      });
      expect(result, hasLength(1));
      expect(result.single.title, 'Leyenda del sol');
    });

    test('acepta también {"media": [...]}', () {
      final result = parseMediaList({
        'media': [
          {'id': 3, 'title': 'Poema de la lluvia'},
        ],
      });
      expect(result, hasLength(1));
      expect(result.single.title, 'Poema de la lluvia');
    });

    test('acepta una lista pelada', () {
      final result = parseMediaList([
        {'id': 4, 'title': 'Cuento del coyote'},
      ]);
      expect(result, hasLength(1));
      expect(result.single.title, 'Cuento del coyote');
    });

    test('mediaList vacío o ausente produce lista vacía, nunca lanza', () {
      expect(parseMediaList({'mediaList': []}), isEmpty);
      expect(parseMediaList(<String, dynamic>{}), isEmpty);
    });
  });

  group('MediaItem.fromJson', () {
    test('mapea los nombres reales del backend', () {
      final item = MediaItem.fromJson({
        'id': 7,
        'title': 'Anécdota del maíz',
        'duration': 120,
        'overviewImage': 'https://oci.example.com/p/TOKEN/n/ns/b/bucket/o/preview.webp',
        'mediaType': 'ANECDOTE',
        'description': 'Una anécdota',
        'difficult': 'MEDIUM',
      });

      expect(item.id, 7);
      expect(item.title, 'Anécdota del maíz');
      expect(item.duration, 120);
      expect(item.mediaType, 'ANECDOTE');
      expect(item.difficult, 'MEDIUM');
    });
  });

  group('MediaPlaybackSource.isAudio', () {
    const posted = 'https://objectstorage.example.com/p/TOKEN123/n/ns/b/bucket/o';

    test('un objeto .mp3 con token PAR delante es audio', () {
      final source = MediaPlaybackSource(
        url: '$posted/media_song_3.mp3',
        title: 'x',
      );
      expect(source.isAudio, isTrue);
    });

    test('un objeto .webm con token PAR delante es video', () {
      final source = MediaPlaybackSource(
        url: '$posted/media_legend_7.webm',
        title: 'x',
      );
      expect(source.isAudio, isFalse);
    });

    test('reconoce otras extensiones de audio comunes', () {
      for (final ext in ['m4a', 'aac', 'wav', 'ogg']) {
        final source = MediaPlaybackSource(url: 'https://x/media.$ext', title: 'x');
        expect(source.isAudio, isTrue, reason: ext);
      }
    });
  });

  group('MediaPlaybackSource.fromStream', () {
    test('mapea StreamResources + MediaItem a un MediaPlaybackSource', () {
      final stream = StreamResources(
        url: 'https://oci.example.com/media.webm',
        espSubtitlesUrl: 'https://oci.example.com/esp.vtt',
        mazSubtitlesUrl: 'https://oci.example.com/maz.vtt',
      );
      final item = MediaItem(
        id: 1,
        title: 'Título',
        overviewImage: 'https://oci.example.com/preview.webp',
      );

      final source = MediaPlaybackSource.fromStream(stream, item: item);

      expect(source.url, stream.url);
      expect(source.espSubtitlesUrl, stream.espSubtitlesUrl);
      expect(source.mazSubtitlesUrl, stream.mazSubtitlesUrl);
      expect(source.posterUrl, item.overviewImage);
      expect(source.title, item.title);
    });

    test('sin MediaItem usa un título por defecto', () {
      final stream = StreamResources(url: 'https://oci.example.com/media.mp3');
      final source = MediaPlaybackSource.fromStream(stream);
      expect(source.title, isNotEmpty);
    });
  });
}
