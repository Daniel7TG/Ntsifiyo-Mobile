import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/theme.dart';
import '../../core/ai/validador_service.dart';
import '../../core/audio/audio_recorder_helper.dart';
import '../../data/models/models.dart';
import '../games/widgets/game_widgets.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/coyote_loading.dart';

enum _RecordingState { idle, recording, analyzing, result }

/// Pantalla individual de práctica de pronunciación para una palabra específica.
class PronunciationPracticeScreen extends ConsumerStatefulWidget {
  final Word word;
  final Future<String> Function()? onAccepted;

  const PronunciationPracticeScreen({
    super.key,
    required this.word,
    this.onAccepted,
  });

  @override
  ConsumerState<PronunciationPracticeScreen> createState() =>
      _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState
    extends ConsumerState<PronunciationPracticeScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AudioPlayer _userAudioPlayer;
  late AudioRecorderHelper _recorderHelper;

  _RecordingState _state = _RecordingState.idle;
  bool _isPlayingAudio = false;
  bool _isPlayingUserAudio = false;
  double _recordingProgress = 0.0;
  Timer? _recordingTimer;
  VeredictoPronunciacion? _veredicto;
  String? _userRecordedWavPath;
  String? _dailyMessage;
  bool _savingDaily = false, _dailySaved = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _userAudioPlayer = AudioPlayer();
    _recorderHelper = AudioRecorderHelper();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Inicializar ONNX service al abrir pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // La evaluación vuelve a intentar la carga y muestra el error al usuario
      // si falla. Aquí solo precalentamos el modelo para reducir la espera.
      unawaited(ref.read(validadorServiceProvider).init().catchError((_) {}));
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioPlayer.dispose();
    _userAudioPlayer.dispose();
    _recorderHelper.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveDaily() async {
    if (widget.onAccepted == null || _savingDaily || _dailySaved) return;
    setState(() => _savingDaily = true);
    try {
      final message = await widget.onAccepted!();
      if (mounted) {
        setState(() {
          _dailyMessage = message;
          _dailySaved = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _dailyMessage = 'No se pudo guardar el reto: $e');
      }
    } finally {
      if (mounted) setState(() => _savingDaily = false);
    }
  }

  Future<void> _playReferenceAudio() async {
    final audioUrl = widget.word.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio no disponible para esta palabra.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      setState(() => _isPlayingAudio = true);
      if (audioUrl.startsWith('assets/')) {
        await _audioPlayer.setAsset(audioUrl);
      } else {
        await _audioPlayer.setUrl(audioUrl);
      }
      await _audioPlayer.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo reproducir el audio de muestra.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  Future<void> _playUserRecording() async {
    if (_userRecordedWavPath == null ||
        !File(_userRecordedWavPath!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay grabación disponible para reproducir.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      setState(() => _isPlayingUserAudio = true);
      await _userAudioPlayer.setFilePath(_userRecordedWavPath!);
      await _userAudioPlayer.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo reproducir tu grabación.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlayingUserAudio = false);
      }
    }
  }

  /// Guarda muestras Float32List a 16kHz como un archivo .wav reproducible
  Future<String> _saveWavFile(Float32List floats) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/recorded_user_audio.wav';
    final file = File(filePath);

    const int sampleRate = 16000;
    const int numChannels = 1;
    const int bitsPerSample = 16;
    const int bytesPerSample = bitsPerSample ~/ 8;

    final int sampleCount = floats.length;
    final int dataSize = sampleCount * bytesPerSample;
    final int fileSize = 36 + dataSize;

    final ByteData header = ByteData(44);
    // RIFF header
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57); // 'W'
    header.setUint8(9, 0x41); // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'

    // fmt chunk
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6D); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Subchunk1Size
    header.setUint16(20, 1, Endian.little); // AudioFormat (PCM)
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(
      28,
      sampleRate * numChannels * bytesPerSample,
      Endian.little,
    );
    header.setUint16(32, numChannels * bytesPerSample, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);

    // data chunk
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'
    header.setUint32(40, dataSize, Endian.little);

    final BytesBuilder builder = BytesBuilder();
    builder.add(header.buffer.asUint8List());

    final ByteData pcmData = ByteData(dataSize);
    for (int i = 0; i < sampleCount; i++) {
      int sample = (floats[i] * 32767.0).clamp(-32768.0, 32767.0).toInt();
      pcmData.setInt16(i * 2, sample, Endian.little);
    }
    builder.add(pcmData.buffer.asUint8List());

    await file.writeAsBytes(builder.toBytes(), flush: true);
    return filePath;
  }

  Future<void> _startRecording() async {
    final hasPerm = await _recorderHelper.hasPermission();
    if (!hasPerm) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se requieren permisos de micrófono para grabar tu voz.',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _state = _RecordingState.recording;
      _recordingProgress = 0.0;
      _veredicto = null;
      _userRecordedWavPath = null;
    });

    const totalDurationMs = 4000;
    const intervalMs = 100;
    int elapsedMs = 0;

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (
      timer,
    ) {
      elapsedMs += intervalMs;
      if (mounted) {
        setState(() {
          _recordingProgress = (elapsedMs / totalDurationMs).clamp(0.0, 1.0);
        });
      }
      if (elapsedMs >= totalDurationMs) {
        timer.cancel();
      }
    });

    // Iniciar captura PCM
    final Float32List? pcmData = await _recorderHelper.grabarPCM16k(
      duration: const Duration(milliseconds: totalDurationMs),
    );

    _recordingTimer?.cancel();

    if (!mounted) return;

    if (pcmData == null || pcmData.isEmpty) {
      setState(() {
        _state = _RecordingState.idle;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo capturar el audio del micrófono.'),
        ),
      );
      return;
    }

    // Guardar archivo .wav local para reproducción de la voz del usuario
    try {
      final wavPath = await _saveWavFile(pcmData);
      _userRecordedWavPath = wavPath;
    } catch (_) {}

    // Iniciar Inferencia ONNX
    setState(() {
      _state = _RecordingState.analyzing;
    });

    try {
      final validador = ref.read(validadorServiceProvider);
      String palabra = widget.word.spanishWord.isNotEmpty
          ? widget.word.spanishWord
          : widget.word.mazahuaWord;

      final veredicto = await validador.validarAudio(pcmData, palabra);

      if (mounted) {
        setState(() {
          _veredicto = veredicto;
          _state = _RecordingState.result;
        });
        if (veredicto.status == PronunciationStatus.correct) await _saveDaily();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _RecordingState.idle;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al evaluar la pronunciación: $e')),
        );
      }
    }
  }

  void _resetPractice() {
    _userAudioPlayer.stop();
    setState(() {
      _state = _RecordingState.idle;
      _veredicto = null;
      _recordingProgress = 0.0;
      _isPlayingUserAudio = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.word.mazahuaWord,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta principal de la palabra
              KidCard(
                accentColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Imagen grande de la palabra
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: WordImage(
                          path: widget.word.imageUrl,
                          wordId: widget.word.id,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Palabra en Mazahua
                    Text(
                      widget.word.mazahuaWord,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        color: AppColors.textMain,
                      ),
                    ),

                    // Traducción al Español
                    Text(
                      widget.word.spanishWord,
                      style: const TextStyle(
                        fontFamily: 'PublicSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textMuted,
                      ),
                    ),

                    if (widget.word.mazahuaPronunciation != null &&
                        widget.word.mazahuaPronunciation!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '/${widget.word.mazahuaPronunciation}/',
                        style: const TextStyle(
                          fontFamily: 'PublicSans',
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Botón para escuchar pronunciación oficial
                    KidButton(
                      label: _isPlayingAudio
                          ? 'Reproduciendo...'
                          : 'Escuchar pronunciación',
                      icon: _isPlayingAudio
                          ? Icons.volume_up_rounded
                          : Icons.play_arrow_rounded,
                      color: const Color(0xFF8B5CF6),
                      loading: _isPlayingAudio,
                      onPressed: _isPlayingAudio ? null : _playReferenceAudio,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Control de grabación e Inferencia ONNX
              if (_state == _RecordingState.analyzing) ...[
                const Center(
                  child: Column(
                    children: [
                      CoyoteLoadingIndicator(
                        message: 'El Coyote está evaluando tu pronunciación...',
                      ),
                    ],
                  ),
                ),
              ] else if (_state == _RecordingState.result &&
                  _veredicto != null) ...[
                _buildResultCard(_veredicto!),
                if (widget.onAccepted != null &&
                    (_savingDaily || _dailyMessage != null))
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          _savingDaily ? 'Guardando tu reto…' : _dailyMessage!,
                          textAlign: TextAlign.center,
                        ),
                        if (!_savingDaily && !_dailySaved)
                          TextButton(
                            onPressed: _saveDaily,
                            child: const Text('Reintentar guardar'),
                          ),
                      ],
                    ),
                  ),
              ] else ...[
                _buildRecordingControls(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingControls() {
    final isRecording = _state == _RecordingState.recording;

    return Column(
      children: [
        Text(
          isRecording
              ? '¡Habla fuerte y claro ahora!'
              : 'Presiona el botón para grabar tu voz',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 16),

        // Botón circular de micrófono 3D pulsante
        ScaleTransition(
          scale: isRecording
              ? _pulseAnimation
              : const AlwaysStoppedAnimation(1.0),
          child: GestureDetector(
            onTap: isRecording ? null : _startRecording,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? Colors.redAccent : AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? Colors.red : AppColors.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: isRecording ? 20 : 10,
                    spreadRadius: isRecording ? 6 : 2,
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (isRecording) ...[
          // Barra de progreso de tiempo de grabación
          SizedBox(
            width: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _recordingProgress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Grabando (4s max)...',
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontSize: 13,
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultCard(VeredictoPronunciacion veredicto) {
    Color cardColor;
    IconData statusIcon;
    String titleText;

    switch (veredicto.status) {
      case PronunciationStatus.correct:
        cardColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        titleText = '¡Excelente Pronunciación!';
        break;
      case PronunciationStatus.incorrectDifferentWord:
        cardColor = Colors.orange;
        statusIcon = Icons.info_rounded;
        titleText = 'Palabra diferente';
        break;
      case PronunciationStatus.silence:
        cardColor = Colors.grey;
        statusIcon = Icons.mic_off_rounded;
        titleText = 'No se detectó voz';
        break;
      case PronunciationStatus.incorrect:
        cardColor = const Color(0xFFE11D48);
        statusIcon = Icons.stars_rounded;
        titleText = 'Casi lo logras';
        break;
    }

    return KidCard(
      accentColor: cardColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: cardColor, size: 32),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  titleText,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: cardColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Puntuación en porcentaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              children: [
                Text(
                  '${veredicto.score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 36,
                    color: cardColor,
                  ),
                ),
                const Text(
                  'Puntuación de similitud',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Mensaje explicativo
          Text(
            veredicto.mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PublicSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 20),

          // Botones de acción: Repetir mi audio / Intentar de nuevo
          Column(
            children: [
              if (_userRecordedWavPath != null) ...[
                KidButton(
                  label: _isPlayingUserAudio
                      ? 'Reproduciendo tu audio...'
                      : 'Repetir mi audio',
                  icon: _isPlayingUserAudio
                      ? Icons.volume_up_rounded
                      : Icons.replay_rounded,
                  color: const Color(0xFF3B82F6),
                  loading: _isPlayingUserAudio,
                  onPressed: _isPlayingUserAudio ? null : _playUserRecording,
                ),
                const SizedBox(height: 12),
              ],
              KidButton(
                label: 'Intentar de nuevo',
                icon: Icons.refresh_rounded,
                color: cardColor,
                onPressed: _resetPractice,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
