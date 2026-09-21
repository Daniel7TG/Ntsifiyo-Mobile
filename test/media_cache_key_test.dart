import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/core/storage/media_cache_key.dart';

void main() {
  group('mediaCacheKey', () {
    test('quita el segmento de token PAR y deja namespace/bucket/objeto',
        () {
      const url =
          'https://objectstorage.mx-queretaro-1.oraclecloud.com/p/'
          'AbCdEf123TOKEN/n/axceel8oki5w/b/bucket-20260205-2248/o/'
          'dictionary/img/5.webp';
      expect(mediaCacheKey(url),
          'https://objectstorage.mx-queretaro-1.oraclecloud.com/n/'
          'axceel8oki5w/b/bucket-20260205-2248/o/dictionary/img/5.webp');
    });

    test('dos PAR distintos del mismo objeto colapsan a la misma clave', () {
      const first =
          'https://objectstorage.mx-queretaro-1.oraclecloud.com/p/'
          'tokenUno/n/ns/b/bucket/o/img/5.webp';
      const second =
          'https://objectstorage.mx-queretaro-1.oraclecloud.com/p/'
          'tokenDos/n/ns/b/bucket/o/img/5.webp';
      expect(mediaCacheKey(first), mediaCacheKey(second));
    });

    test('una URL que no sigue el patrón PAR queda intacta', () {
      const url = 'https://cdn.example.com/img/5.webp';
      expect(mediaCacheKey(url), url);
    });

    test('una ruta de asset del bundle (sin http) queda intacta', () {
      const path = 'assets/dictionary/img/5.webp';
      expect(mediaCacheKey(path), path);
    });
  });
}
