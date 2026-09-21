import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';

/// Helper para capturar stream de audio PCM a 16,000 Hz Mono 16-bit (Little-Endian)
/// y convertirlo a Float32List [-1.0, 1.0] para el modelo ONNX.
class AudioRecorderHelper {
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _subscription;

  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  /// Inicia la grabación del stream PCM 16kHz por una duración específica o hasta detener.
  Future<Float32List?> grabarPCM16k({
    Duration duration = const Duration(seconds: 4),
  }) async {
    if (!await _audioRecorder.hasPermission()) {
      return null;
    }

    final stream = await _audioRecorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    final List<int> allBytes = [];
    final Completer<void> completer = Completer<void>();

    _subscription = stream.listen(
      (data) {
        allBytes.addAll(data);
      },
      onError: (e) {
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
    );

    // Detener automáticamente tras la duración límite
    Timer(duration, () async {
      await stopRecording();
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future;

    if (allBytes.isEmpty) return null;

    final Uint8List uint8 = Uint8List.fromList(allBytes);
    final ByteData byteData = ByteData.sublistView(uint8);
    final int sampleCount = uint8.length ~/ 2;
    final Float32List floats = Float32List(sampleCount);

    for (int i = 0; i < sampleCount; i++) {
      int sample = byteData.getInt16(i * 2, Endian.little);
      floats[i] = sample / 32768.0;
    }

    return floats;
  }

  Future<void> stopRecording() async {
    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
      await _subscription?.cancel();
      _subscription = null;
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stopRecording();
    await _audioRecorder.dispose();
  }
}
