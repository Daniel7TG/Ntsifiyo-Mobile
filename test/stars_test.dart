import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/core/stars.dart';

void main() {
  group('starsFor', () {
    test('5 de 5 aciertos da 5 estrellas', () {
      expect(starsFor(5, 5), 5);
    });

    test('4 de 5 aciertos da 4 estrellas', () {
      expect(starsFor(4, 5), 4);
    });

    test('4 de 6 aciertos redondea hacia abajo a 3 estrellas', () {
      expect(starsFor(4, 6), 3);
    });

    test('0 aciertos da 0 estrellas', () {
      expect(starsFor(0, 5), 0);
    });

    test('total de preguntas 0 da 0 estrellas (evita división por cero)', () {
      expect(starsFor(0, 0), 0);
      expect(starsFor(3, 0), 0);
    });

    test('nunca supera el máximo de 5 estrellas', () {
      // Un total inconsistente (más aciertos que preguntas) no debe
      // desbordar la escala.
      expect(starsFor(9, 5), maxStars);
    });
  });
}
