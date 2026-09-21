import 'dart:math';
import 'dart:typed_data';

/// Port a Dart del preprocesado de audio del validador mazahua. Es un *mirror*
/// de `mazahua/comun.py` y `mazahua/gate_voz.py` del proyecto «Audios Niños»,
/// y su contrato está escrito en `ENTRADA_DE_AUDIO.md` (§3 pipeline, §5
/// invariancia al volumen, §6 normalización del backbone, §7 checklist de
/// integración).
///
/// **Antes de cambiar cualquier constante o cualquier orden de pasos, lee ese
/// documento.** Los prototipos y el umbral 0.2406 se calibraron sobre esta
/// cadena exacta; alterarla desplaza el punto de decisión sin que nada falle
/// de forma visible.
///
/// Este archivo no depende de Flutter a propósito: así los tests lo cubren sin
/// binding.

// --- Constantes de preprocesado (mazahua/config.py) --------------------------

/// Frecuencia fija del backbone wav2vec2. No es negociable (§1).
const int srModelo = 16000;

/// Ventana de análisis de energía, en ms.
const int frameMs = 25;

/// Salto entre ventanas de análisis, en ms.
const int hopMs = 10;

/// Se conserva lo que supere el 10 % del pico de RMS. **Relativo al pico, no
/// absoluto**: así un clip susurrado y uno gritado se recortan en el mismo
/// sitio fonético (§3). Un umbral absoluto se comería el principio de las
/// palabras dichas bajito.
const double umbralRmsRelativo = 0.10;

/// Margen de silencio que se deja a cada lado del recorte, en ms.
const int margenSilencioMs = 100;

/// Mínimo que exige wav2vec2 para no reventar, en segundos.
const double duracionMinimaS = 0.25;

/// Nivel de RMS al que se lleva todo clip. La clave de la invariancia al
/// volumen (§5): cualquier ganancia global se cancela aquí.
const double rmsObjetivo = 0.1;

/// Equivalente a `PREPROC_VERSION` de Python. Si cambias esta cadena de pasos,
/// súbela.
const int preprocVersion = 2;

// --- Constantes del gate de voz (mazahua/gate_voz.py) ------------------------

/// Ventana sobre la que se mide el pico de energía, en segundos.
const double gateVentanaS = 0.30;

/// El momento más sonoro debe superar esto. **Se mide sobre el audio ANTES de
/// normalizar el RMS**: es la única comprobación de todo el sistema que
/// depende del volumen absoluto, y es deliberado — sirve para distinguir «no
/// hay nadie hablando» de «hay alguien hablando bajito» (§3).
const double gateRmsPicoMin = 0.0200;

/// Pico/mediana: el habla va a ráfagas, el ruido de fondo es plano.
const double gateCrestaMin = 2.20;

/// El ruido de banda ancha cruza el cero mucho más que la voz.
const double gateZcrMax = 0.3400;

// --- Utilidades --------------------------------------------------------------

/// RMS de un tramo de `samples`, con el mismo epsilon (1e-12) que la
/// referencia en Python.
double rms(Float32List samples, [int start = 0, int? length]) {
  if (samples.isEmpty) return 0.0;
  final end = min(samples.length, start + (length ?? samples.length - start));
  if (end <= start) return 0.0;
  var suma = 0.0;
  for (var i = start; i < end; i++) {
    suma += samples[i] * samples[i];
  }
  return sqrt(suma / (end - start) + 1e-12);
}

// --- Gate de voz -------------------------------------------------------------

/// Resultado del gate de voz. `motivo` está en español y es apto para mostrar
/// directamente al niño.
class VeredictoGate {
  final bool hayVoz;
  final String motivo;
  final double rmsPico;
  final double cresta;
  final double zcr;

  const VeredictoGate({
    required this.hayVoz,
    required this.motivo,
    required this.rmsPico,
    required this.cresta,
    required this.zcr,
  });
}

/// RMS de ventanas de 0.30 s solapadas al 50 %.
List<double> _ventanasRms(Float32List wav, [double ventanaS = gateVentanaS]) {
  final n = max((srModelo * ventanaS).toInt(), 1);
  final salto = max(n ~/ 2, 1);
  if (wav.length < n) return [rms(wav)];
  final salida = <double>[];
  for (var i = 0; i + n <= wav.length; i += salto) {
    salida.add(rms(wav, i, n));
  }
  return salida;
}

/// Fracción de muestras donde la señal cambia de signo.
double tasaCrucesCero(Float32List wav, [int start = 0, int? length]) {
  final end = min(wav.length, start + (length ?? wav.length - start));
  if (end - start < 2) return 0.0;
  var cruces = 0;
  for (var i = start + 1; i < end; i++) {
    if (wav[i].isNegative != wav[i - 1].isNegative) cruces++;
  }
  return cruces / (end - start - 1);
}

/// Decide si el buffer contiene habla, **antes** de buscar la palabra y
/// **antes** de normalizar el RMS. Tres señales independientes; basta con que
/// falle una para rechazar.
///
/// Existe porque con 24 buffers de ruido puro la app respondía «suena más como
/// \<palabra\>» en 23: el gate anterior miraba el RMS medio de los 4 s
/// completos, que el ruido de sala supera sin problema. Sus constantes salen
/// de `11_calibrar_gate.py`, no están puestas a ojo.
///
/// No se porta `segmento_plausible` (la comprobación de duración 0.25–2.0 s)
/// porque opera sobre el segmento que localiza el detector de palabra de la
/// app de escritorio, y aquí no hay tal detector: aplicarla al tramo recortado
/// por energía rechazaría grabaciones buenas con ruido de fondo constante.
VeredictoGate analizarVoz(Float32List wav) {
  final ventanas = _ventanasRms(wav);
  final rmsPico = ventanas.reduce(max);
  final ordenadas = [...ventanas]..sort();
  final medio = ordenadas.length ~/ 2;
  final mediana = ordenadas.length.isOdd
      ? ordenadas[medio]
      : (ordenadas[medio - 1] + ordenadas[medio]) / 2.0;
  final cresta = rmsPico / max(mediana, 1e-9);

  final n = max((srModelo * gateVentanaS).toInt(), 1);
  final salto = max(n ~/ 2, 1);
  var k = 0;
  for (var i = 1; i < ventanas.length; i++) {
    if (ventanas[i] > ventanas[k]) k = i;
  }
  final zcr = tasaCrucesCero(wav, k * salto, n);

  if (rmsPico < gateRmsPicoMin) {
    return VeredictoGate(
      hayVoz: false,
      motivo: 'No se oyó nada lo bastante fuerte. Acércate al micrófono.',
      rmsPico: rmsPico,
      cresta: cresta,
      zcr: zcr,
    );
  }
  if (cresta < gateCrestaMin) {
    return VeredictoGate(
      hayVoz: false,
      motivo: 'Solo se oye ruido de fondo. Busca un lugar más silencioso.',
      rmsPico: rmsPico,
      cresta: cresta,
      zcr: zcr,
    );
  }
  if (zcr > gateZcrMax) {
    return VeredictoGate(
      hayVoz: false,
      motivo: 'Lo que se oyó no tiene forma de voz. Inténtalo otra vez.',
      rmsPico: rmsPico,
      cresta: cresta,
      zcr: zcr,
    );
  }
  return VeredictoGate(
    hayVoz: true,
    motivo: '',
    rmsPico: rmsPico,
    cresta: cresta,
    zcr: zcr,
  );
}

// --- Pipeline de preparación -------------------------------------------------

/// Rellena con ceros simétricos hasta `duracionMinimaS`.
Float32List rellenarAMinimo(Float32List wav) {
  final minimo = (srModelo * duracionMinimaS).toInt();
  if (wav.length >= minimo) return wav;
  final faltante = minimo - wav.length;
  final antes = faltante ~/ 2;
  final salida = Float32List(minimo);
  salida.setRange(antes, antes + wav.length, wav);
  return salida;
}

/// Recorta silencio inicial/final por energía RMS con umbral **relativo al
/// pico** (10 %), deja 100 ms de margen a cada lado y garantiza la duración
/// mínima. Ventanas de 25 ms con salto de 10 ms.
Float32List recortarEnergia(Float32List wav) {
  final frameLen = srModelo * frameMs ~/ 1000;
  final hopLen = srModelo * hopMs ~/ 1000;

  if (wav.length < frameLen) return rellenarAMinimo(wav);

  final nFrames = 1 + (wav.length - frameLen) ~/ hopLen;
  final rmsFrames = Float64List(nFrames);
  var pico = 0.0;
  for (var i = 0; i < nFrames; i++) {
    final v = rms(wav, i * hopLen, frameLen);
    rmsFrames[i] = v;
    if (v > pico) pico = v;
  }

  if (pico < 1e-6) return rellenarAMinimo(wav);

  final umbral = pico * umbralRmsRelativo;
  var primerFrame = -1;
  var ultimoFrame = -1;
  for (var i = 0; i < nFrames; i++) {
    if (rmsFrames[i] >= umbral) {
      if (primerFrame < 0) primerFrame = i;
      ultimoFrame = i;
    }
  }
  if (primerFrame < 0) return rellenarAMinimo(wav);

  final margen = srModelo * margenSilencioMs ~/ 1000;
  final inicio = max(0, primerFrame * hopLen - margen);
  final fin = min(wav.length, ultimoFrame * hopLen + frameLen + margen);

  return rellenarAMinimo(
    Float32List.sublistView(wav, inicio, fin),
  );
}

/// Normaliza el volumen a RMS 0.1. Aquí se cancela cualquier ganancia global:
/// es lo que hace que dos niños con la misma pronunciación, uno susurrando y
/// otro gritando, obtengan el **mismo embedding** (§5). El recorte a [-1, 1]
/// replica el `np.clip` de la referencia.
Float32List normalizarRms(Float32List wav, [double objetivo = rmsObjetivo]) {
  final actual = rms(wav);
  if (actual < 1e-6) return wav;
  final factor = objetivo / actual;
  final salida = Float32List(wav.length);
  for (var i = 0; i < wav.length; i++) {
    salida[i] = (wav[i] * factor).clamp(-1.0, 1.0);
  }
  return salida;
}

/// Media cero y varianza uno, como `Wav2Vec2FeatureExtractor(do_normalize=true)`.
///
/// **No forma parte de `prepararAudio`**: es el contrato de entrada del
/// *backbone*, no del preprocesado del clip. En entrenamiento la aplica el
/// feature-extractor de HuggingFace, así que los embeddings, los prototipos y
/// el umbral 0.2406 viven todos en este espacio.
///
/// Omitirla es el fallo del §6: alimentar el backbone con RMS 0.1 (unas 10
/// veces por debajo del std=1 que vio en entrenamiento) rechazaba al 49.2 % de
/// las pronunciaciones buenas, frente al 95.8 % aceptado al aplicarla, y
/// duplicaba el EER (21.3 % → 10.4 %). Aplicarla **dos veces** es igual de
/// incorrecto: quién debe llamarla lo dice el propio modelo en
/// `_meta.normalizacion_entrada` de `centroides_y_config.json`.
Float32List normalizarParaBackbone(Float32List wav) {
  if (wav.isEmpty) return wav;
  var suma = 0.0;
  for (final v in wav) {
    suma += v;
  }
  final media = suma / wav.length;
  var varianza = 0.0;
  for (final v in wav) {
    final d = v - media;
    varianza += d * d;
  }
  varianza /= wav.length;
  final desv = sqrt(varianza + 1e-7);
  final salida = Float32List(wav.length);
  for (var i = 0; i < wav.length; i++) {
    salida[i] = (wav[i] - media) / desv;
  }
  return salida;
}

/// Pipeline del clip, equivalente a `preparar_audio_desde_array`: recorte por
/// energía → relleno a 0.25 s → normalización RMS a 0.1.
///
/// No hay remuestreo porque la app graba ya a 16 kHz mono
/// (`AudioRecorderHelper`). Si algún día se graba a otra frecuencia, hay que
/// remuestrear con un filtro decente **antes** de llamar aquí: decimar
/// tirando muestras mete aliasing justo en la banda que el modelo usa (§7).
///
/// `normalizarParaBackbone` queda fuera a propósito — la decide el modelo.
Float32List prepararAudio(Float32List wav) =>
    normalizarRms(recortarEnergia(wav));
