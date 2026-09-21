import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jnatrjo_mobile/core/ai/preproceso_audio.dart';

/// Genera una señal periódica tipo voz (fundamental baja + armónicos), que es
/// lo que el gate espera dejar pasar: energía concentrada en frecuencias
/// bajas, pocos cruces por cero.
Float32List _voz(int muestras, {double amplitud = 0.3, double f0 = 140}) {
  final s = Float32List(muestras);
  for (var i = 0; i < muestras; i++) {
    final t = i / srModelo;
    s[i] = amplitud *
        (sin(2 * pi * f0 * t) +
            0.5 * sin(2 * pi * 2 * f0 * t) +
            0.25 * sin(2 * pi * 3 * f0 * t)) /
        1.75;
  }
  return s;
}

/// Ruido de banda ancha: plano en el tiempo y con muchos cruces por cero.
Float32List _ruido(int muestras, {double amplitud = 0.05, int semilla = 7}) {
  final r = Random(semilla);
  final s = Float32List(muestras);
  for (var i = 0; i < muestras; i++) {
    s[i] = amplitud * (r.nextDouble() * 2 - 1);
  }
  return s;
}

/// Una palabra dentro de un buffer de 4 s con algo de silencio alrededor.
Float32List _bufferConPalabra({
  double amplitud = 0.3,
  double palabraS = 0.7,
  double inicioS = 1.2,
}) {
  final total = Float32List(srModelo * 4);
  final palabra = _voz((srModelo * palabraS).round(), amplitud: amplitud);
  total.setRange(
      (srModelo * inicioS).round(), (srModelo * inicioS).round() + palabra.length, palabra);
  return total;
}

double _distanciaCoseno(Float32List a, Float32List b) {
  var dot = 0.0, na = 0.0, nb = 0.0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  return 1.0 - dot / (sqrt(na) * sqrt(nb));
}

void main() {
  group('gate de voz', () {
    test('deja pasar una palabra dentro de un buffer de 4 s', () {
      final v = analizarVoz(_bufferConPalabra());
      expect(v.hayVoz, isTrue, reason: v.motivo);
    });

    test('rechaza el silencio por rms de pico', () {
      final v = analizarVoz(Float32List(srModelo * 4));
      expect(v.hayVoz, isFalse);
      expect(v.rmsPico, lessThan(gateRmsPicoMin));
    });

    test('rechaza el ruido de banda ancha constante', () {
      // Es el caso que motivó el gate: 23 de 24 buffers de ruido puro
      // recibían «suena más como <palabra>» con el gate viejo de rms < 0.005.
      final v = analizarVoz(_ruido(srModelo * 4, amplitud: 0.15));
      expect(v.hayVoz, isFalse);
    });

    test('el gate viejo (rms medio > 0.005) sí habría dejado pasar ese ruido',
        () {
      expect(rms(_ruido(srModelo * 4, amplitud: 0.15)), greaterThan(0.005));
    });
  });

  group('recorte por energía', () {
    test('el umbral es relativo al pico: recorta igual susurro y grito', () {
      final fuerte = recortarEnergia(_bufferConPalabra(amplitud: 0.5));
      final flojo = recortarEnergia(_bufferConPalabra(amplitud: 0.03));
      expect(flojo.length, fuerte.length);
    });

    test('conserva la palabra más los 100 ms de margen a cada lado', () {
      final recortado = recortarEnergia(_bufferConPalabra(palabraS: 0.7));
      final esperado = (srModelo * (0.7 + 0.2)).round();
      expect(recortado.length, closeTo(esperado, srModelo * 0.05));
    });

    test('rellena a 0.25 s los clips demasiado cortos', () {
      final corto = _voz((srModelo * 0.1).round());
      expect(recortarEnergia(corto).length, (srModelo * duracionMinimaS).toInt());
    });

    test('el silencio total no revienta', () {
      expect(recortarEnergia(Float32List(srModelo)).length, srModelo);
    });
  });

  group('invariancia al volumen (§5)', () {
    test('normalizarRms deja el mismo RMS objetivo con 18 dB de diferencia',
        () {
      for (final g in [0.125, 0.25, 1.0, 2.0]) {
        final s = prepararAudio(_bufferConPalabra(amplitud: 0.05 * g));
        expect(rms(s), closeTo(rmsObjetivo, 1e-4));
      }
    });

    test('la entrada final al backbone es idéntica a lo largo del rango', () {
      final ref = normalizarParaBackbone(
          prepararAudio(_bufferConPalabra(amplitud: 0.05)));
      for (final g in [2.0, 4.0, 8.0]) {
        final otra = normalizarParaBackbone(
            prepararAudio(_bufferConPalabra(amplitud: 0.05 * g)));
        expect(otra.length, ref.length);
        expect(_distanciaCoseno(ref, otra), closeTo(0.0, 1e-6));
      }
    });
  });

  group('normalización para el backbone (§6)', () {
    test('deja media 0 y desviación 1, no RMS 0.1', () {
      final entrada = normalizarParaBackbone(prepararAudio(_bufferConPalabra()));
      var suma = 0.0;
      for (final v in entrada) {
        suma += v;
      }
      final media = suma / entrada.length;
      expect(media, closeTo(0.0, 1e-4));
      expect(rms(entrada), closeTo(1.0, 1e-3));
    });

    test('prepararAudio NO la incluye: quién la aplica lo decide el modelo',
        () {
      expect(rms(prepararAudio(_bufferConPalabra())), closeTo(rmsObjetivo, 1e-4));
    });
  });
}
