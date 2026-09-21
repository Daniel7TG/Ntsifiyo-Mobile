import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import 'preproceso_audio.dart';

/// Normaliza una clave de palabra para comparar contra los centroides ONNX:
/// minúsculas, sin espacios/guiones y sin acentos en vocales. La ñ se
/// conserva porque en español es una letra propia, no una n acentuada —
/// quitarla haría colisionar 'caña' con 'cana'. Es la única fuente de esta
/// normalización: antes vivía duplicada en el hub de pronunciación y no
/// quitaba acentos, así que 'gabán' nunca casaba con el centroide 'gaban'.
String normalizePronunciationKey(String key) {
  var result = key.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
  const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};
  for (final entry in accents.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }
  return result;
}

/// Servicio de inferencia IA en el dispositivo móvil utilizando ONNX Runtime.
/// Carga `validador_int8.onnx` y `centroides_y_config.json` para clasificar
/// audios PCM 16kHz Float32.
///
/// El preprocesado vive en `preproceso_audio.dart` y su contrato está en
/// `ENTRADA_DE_AUDIO.md` del proyecto «Audios Niños». Este servicio solo
/// orquesta: gate de voz → pipeline del clip → normalización del backbone (si
/// el modelo la pide) → ONNX → distancia coseno contra el prototipo.
class ValidadorService {
  OrtSession? _session;
  Future<void>? _initializing;
  Map<String, List<double>> _centroides = {};

  /// Umbral de decisión. El valor real llega de `centroides_y_config.json`;
  /// este solo cubre el arranque. Es el 0.2406 calibrado contra los
  /// **prototipos** de la cabeza AM-Softmax, no el 0.3559 de `umbral.json`,
  /// que se calibró contra los centroides promediados de la cabeza de
  /// tripletes: mezclar umbral y referencias de cabezas distintas desplaza el
  /// punto de decisión sin que nada falle de forma visible (§4).
  double _umbralGlobal = 0.2406;

  /// ¿Le toca al cliente aplicar la normalización media-cero/varianza-uno?
  /// Lo decide el modelo, no nosotros: `_meta.normalizacion_entrada` vale
  /// `"grafo"` (ya va dentro del ONNX, el cliente no debe aplicarla) o
  /// `"cliente"` (el ONNX no la trae). Ausente = grafo anterior al 2026-08-20,
  /// que se asume `"cliente"`. Ver §6 de `ENTRADA_DE_AUDIO.md`: aplicarla dos
  /// veces es tan incorrecto como no aplicarla.
  bool _normalizarEnCliente = true;

  bool _initialized = false;

  /// Retorna si el servicio ya fue cargado en memoria (modelo ONNX incluido).
  bool get isInitialized => _initialized;

  /// Retorna las palabras disponibles en la lista de centroides.
  List<String> get palabrasCentroides => _centroides.keys.toList();

  /// Carga únicamente `centroides_y_config.json` (~18 KB) — lo mínimo que
  /// necesita la pantalla de selección de palabras para decidir qué mostrar.
  /// Deliberadamente no toca el modelo ONNX de 182 MB, que solo hace falta
  /// para evaluar audio (`validarAudio`). Antes `init()` cargaba el modelo
  /// primero, así que la lista de palabras practicables tardaba en aparecer
  /// tanto como la carga completa del modelo.
  Future<void> ensureCentroides() async {
    if (_centroides.isNotEmpty) return;
    final jsonStr = await rootBundle.loadString(
      'assets/modelo/centroides_y_config.json',
    );
    final Map<String, dynamic> configJson = jsonDecode(jsonStr);

    _umbralGlobal = (configJson['umbral_global'] as num).toDouble();
    final meta = configJson['_meta'];
    final normalizacion = meta is Map ? meta['normalizacion_entrada'] : null;
    _normalizarEnCliente = normalizacion != 'grafo';
    final centroidesData = configJson['centroides'];

    final centroides = <String, List<double>>{};
    if (centroidesData is Map && centroidesData.containsKey('palabras')) {
      final palabras = (centroidesData['palabras'] as List).cast<String>();
      final vectores = (centroidesData['vectores'] as List);
      for (int i = 0; i < palabras.length; i++) {
        final vec = (vectores[i] as List)
            .map((e) => (e as num).toDouble())
            .toList();
        centroides[normalizePronunciationKey(palabras[i])] = vec;
      }
    } else if (centroidesData is Map) {
      centroidesData.forEach((key, value) {
        final list = (value as List).map((e) => (e as num).toDouble()).toList();
        centroides[normalizePronunciationKey(key.toString())] = list;
      });
    }
    _centroides = centroides;
  }

  /// Inicializar el motor ONNX Runtime y cargar centroides en RAM.
  Future<void> init() {
    if (_initialized) return Future.value();
    return _initializing ??= _init().whenComplete(() => _initializing = null);
  }

  Future<void> _init() async {
    try {
      await ensureCentroides();

      // El plugin extrae el modelo de 182 MB a un archivo local de forma
      // atómica y crea la sesión con ONNX Runtime moderno. Esa versión es
      // necesaria porque el modelo cuantizado usa MatMulNBits.
      _session = await OnnxRuntime().createSessionFromAsset(
        'assets/modelo/validador_int8.onnx',
        options: OrtSessionOptions(intraOpNumThreads: 2, interOpNumThreads: 1),
      );

      _initialized = true;
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  /// Validar una grabación en formato Float32List a 16,000 Hz Mono.
  Future<VeredictoPronunciacion> validarAudio(
    Float32List pcm16k,
    String palabraEsperada,
  ) async {
    if (!_initialized) {
      await init();
    }
    if (_session == null) {
      throw Exception("No se pudo cargar la sesión de ONNX Runtime.");
    }

    final targetKey = _normalizeKey(palabraEsperada);

    // 1. Gate de voz. Va ANTES de normalizar el RMS a propósito: es la única
    //    comprobación que depende del volumen absoluto, y normalizar primero
    //    amplificaría el ruido de sala a nivel de voz, dejándolo pasar todo.
    final gate = analizarVoz(pcm16k);
    if (!gate.hayVoz) {
      return VeredictoPronunciacion(
        status: PronunciationStatus.silence,
        score: 0.0,
        targetWord: palabraEsperada,
        targetDistance: 1.0,
        minDistance: 1.0,
        threshold: _umbralGlobal,
        mensaje: gate.motivo,
      );
    }

    // 2. Pipeline del clip: recorte por energía (umbral relativo al pico) →
    //    relleno a 0.25 s → normalización RMS a 0.1.
    Float32List pcmPreprocesado = prepararAudio(pcm16k);

    // 3. Normalización de entrada del backbone (media cero / varianza uno),
    //    solo si el ONNX no la trae dentro. Sin ella el modelo recibe RMS 0.1
    //    en vez del std=1 en que se calibró el umbral, y rechaza a la mitad de
    //    los niños que pronuncian bien.
    final Float32List entrada = _normalizarEnCliente
        ? normalizarParaBackbone(pcmPreprocesado)
        : pcmPreprocesado;

    // 4. Crear tensor ONNX con shape 2D [1, num_samples].
    final inputOrt = await OrtValue.fromList(entrada, [1, entrada.length]);
    final outputs = <String, OrtValue>{};
    late final List<double> vectorAudio128;

    try {
      // 5. Ejecutar inferencia ONNX y copiar el embedding antes de liberar
      // los recursos nativos asociados a los tensores.
      outputs.addAll(await _session!.run({'audio_16k': inputOrt}));
      if (outputs.isEmpty) {
        throw Exception("El modelo ONNX no devolvió ninguna salida.");
      }

      final rawValue = await outputs.values.first.asFlattenedList();
      vectorAudio128 = rawValue
          .map((e) => (e as num).toDouble())
          .toList(growable: false);
    } finally {
      await inputOrt.dispose();
      for (final output in outputs.values) {
        await output.dispose();
      }
    }

    // 6. Comparar con los centroides
    final targetCentroid = _centroides[targetKey];

    // Buscar la menor distancia entre todos los centroides
    double minDistance = double.infinity;
    String detectedWordKey = targetKey;

    _centroides.forEach((wordKey, centroid) {
      double dist = _calcularDistanciaCoseno(vectorAudio128, centroid);
      if (dist < minDistance) {
        minDistance = dist;
        detectedWordKey = wordKey;
      }
    });

    double targetDistance = targetCentroid != null
        ? _calcularDistanciaCoseno(vectorAudio128, targetCentroid)
        : minDistance;

    bool esCorrecto = targetDistance <= _umbralGlobal;
    double score =
        max(0.0, min(1.0, 1.0 - (targetDistance / (2.0 * _umbralGlobal)))) *
        100.0;

    PronunciationStatus status;
    String mensaje;

    if (esCorrecto) {
      status = PronunciationStatus.correct;
      mensaje = "¡Excelente! Pronunciación correcta.";
    } else if (minDistance <= _umbralGlobal && detectedWordKey != targetKey) {
      status = PronunciationStatus.incorrectDifferentWord;
      mensaje =
          "Parece que dijiste '$detectedWordKey' en lugar de '$palabraEsperada'. ¡Inténtalo de nuevo!";
    } else {
      status = PronunciationStatus.incorrect;
      mensaje = "Pronunciación no del todo clara. ¡Escucha e intenta de nuevo!";
    }

    return VeredictoPronunciacion(
      status: status,
      score: double.parse(score.toStringAsFixed(1)),
      targetWord: palabraEsperada,
      detectedWord: detectedWordKey,
      targetDistance: targetDistance,
      minDistance: minDistance,
      threshold: _umbralGlobal,
      mensaje: mensaje,
    );
  }

  double _calcularDistanciaCoseno(List<double> v1, List<double> v2) {
    if (v1.length != v2.length) return 1.0;
    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < v1.length; i++) {
      dot += v1[i] * v2[i];
      normA += v1[i] * v1[i];
      normB += v2[i] * v2[i];
    }
    if (normA == 0 || normB == 0) return 1.0;
    double similitud = dot / (sqrt(normA) * sqrt(normB));
    return 1.0 - similitud;
  }

  String _normalizeKey(String key) => normalizePronunciationKey(key);

  Future<void> dispose() async {
    final session = _session;
    _session = null;
    _initialized = false;
    if (session != null) await session.close();
  }
}

final validadorServiceProvider = Provider<ValidadorService>((ref) {
  final service = ValidadorService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

/// Set de claves de centroides ya normalizadas, listo para el hub de
/// pronunciación. A diferencia de leer `palabrasCentroides` desde un
/// `initState`, este `FutureProvider` sí notifica a quien lo observa cuando
/// termina de cargar (o falla), en vez de depender de un `setState` manual
/// que se saltaba silenciosamente si `init()`/`ensureCentroides()` lanzaba.
final centroidesProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  final service = ref.watch(validadorServiceProvider);
  await service.ensureCentroides();
  return service.palabrasCentroides.toSet();
});
