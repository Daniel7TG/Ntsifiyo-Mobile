import '../../../data/services/daily_pronunciation_service.dart' show pendingXpMessage;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/activity_config.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/stars.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/coyote_loading.dart';
import '../../../shared/widgets/kid_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../game_session.dart';
import 'game_widgets.dart';

/// Resumen al terminar un juego (mirror de GameSummary.jsx):
/// porcentaje, estrellas, tiempo, confetti, XP (o aviso de sincronización
/// pendiente) y panel para revisar las respuestas.
class GameSummaryView extends ConsumerStatefulWidget {
  final GameOutcome outcome;
  final VoidCallback onExit;
  final VoidCallback onRetry;

  const GameSummaryView({
    super.key,
    required this.outcome,
    required this.onExit,
    required this.onRetry,
  });

  @override
  ConsumerState<GameSummaryView> createState() => _GameSummaryViewState();
}

class _GameSummaryViewState extends ConsumerState<GameSummaryView> {
  bool _loading = true;
  RewardResult? _result;
  bool _queuedOffline = false;
  String? _error;
  bool _expandedLogs = false;

  /// Segundos que duró la partida, congelados al abrir el resumen (antes de
  /// que el POST /complete sume su propia latencia).
  late final int _timeElapsed;

  int get _percentage => widget.outcome.totalQuestions > 0
      ? (widget.outcome.correctAnswers * 100 / widget.outcome.totalQuestions)
          .round()
      : 0;

  @override
  void initState() {
    super.initState();
    _timeElapsed = _elapsedSeconds();
    _send();
  }

  int _elapsedSeconds() {
    final start = ref.read(gameSessionProvider)?.startDate;
    if (start == null) return 0;
    final seconds = DateTime.now().difference(start).inSeconds;
    return seconds > 0 ? seconds : 0;
  }

  Future<void> _send() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(gameSessionProvider.notifier)
          .complete(widget.outcome);
      if (!mounted) return;
      setState(() {
        _result = result;
        _queuedOffline = result == null;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Error de conexión al guardar tu progreso.';
        _loading = false;
      });
    }
  }

  /// Coyote mascota según desempeño (mirror de GameSummary.jsx + coyote web).
  (String, String, String) _headerContent() {
    if (_percentage == 100) {
      return (
        'assets/coyote/celebracion.webp',
        '¡PERFECTO!',
        '¡No fallaste ni una!'
      );
    }
    if (_percentage >= 80) {
      return (
        'assets/coyote/celebracion.webp',
        '¡Increíble!',
        '¡Muy buen trabajo!'
      );
    }
    if (_percentage >= 60) {
      return ('assets/coyote/saludo.webp', '¡Bien hecho!', '¡Sigue así!');
    }
    return (
      'assets/coyote/animations/waiting.webp',
      '¡Sigue practicando!',
      '¡Tú puedes!'
    );
  }

  /// Los juegos de pares no tienen preguntas: su revisión lista las palabras
  /// completadas e incompletas (mirror de looksLikeWordSummary).
  bool get _isPairsGame {
    final gameType = ref.read(gameSessionProvider)?.data.gameType;
    if (pairTypes.contains(gameType)) return true;
    return widget.outcome.responseLogs
        .any((l) => l.wordText != null && l.questionId == null);
  }

  @override
  Widget build(BuildContext context) {
    final (coyoteAsset, title, subtitle) = _headerContent();
    // Sobre los conteos crudos, no sobre `_percentage` ya redondeado, para
    // no encadenar dos redondeos (`lib/core/stars.dart`: única fuente de
    // estrellas de toda la app).
    final stars =
        starsFor(widget.outcome.correctAnswers, widget.outcome.totalQuestions);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            if (_percentage >= 80) const _Confetti(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: KidCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) =>
                            Transform.scale(scale: value, child: child),
                        child: Image.asset(coyoteAsset, height: 120),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      // Métricas: precisión (estrellas) y tiempo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Metric(
                            label: 'PRECISIÓN',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < 5; i++)
                                  Icon(
                                    i < stars ? Icons.star : Icons.star_border,
                                    color: AppColors.warning,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                          _Metric(
                            label: 'TIEMPO',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer,
                                    size: 18, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(_timeElapsed),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppColors.textMain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      ProgressRing(
                        value: widget.outcome.correctAnswers.toDouble(),
                        max: widget.outcome.totalQuestions.toDouble(),
                        color: _percentage >= 60
                            ? AppColors.success
                            : AppColors.error,
                        size: 130,
                        centerLabel: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_percentage%',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              '${widget.outcome.correctAnswers}/${widget.outcome.totalQuestions}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // XP / estado de sincronización / error del servidor
                      if (_loading)
                        const CoyoteLoadingIndicator(
                            message: 'Guardando tu progreso...', size: 100)
                      else if (_error != null)
                        _buildError(_error!)
                      else if (_queuedOffline)
                        _buildOfflineNote()
                      else
                        _buildXpResult(_result!),

                      // Revisión de respuestas
                      if (widget.outcome.responseLogs.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildLogsSection(),
                      ],

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: KidButton(
                              label: 'Salir',
                              color: AppColors.primaryBlue,
                              icon: Icons.home,
                              expanded: true,
                              onPressed: widget.onExit,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: KidButton(
                              label: 'Otra vez',
                              icon: Icons.replay,
                              expanded: true,
                              onPressed: widget.onRetry,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) =>
      '${totalSeconds ~/ 60}:${(totalSeconds % 60).toString().padLeft(2, '0')}';

  Widget _buildXpResult(RewardResult result) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.4), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/svgs/xp.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      AppColors.warning, BlendMode.srcIn)),
              const SizedBox(width: 6),
              Text(
                '+${result.xpGained} XP',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        if (result.isLevelUp) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration,
                  size: 20, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                '¡Subiste al nivel ${result.currentLevel}!',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOfflineNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_upload, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              pendingXpMessage,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain),
            ),
          ),
        ],
      ),
    );
  }

  /// El servidor rechazó el resultado: ofrecer reintentar en vez de encolarlo
  /// (mirror del botón "Reintentar guardar" de GameSummary.jsx).
  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 10),
          KidButton(
            label: 'Reintentar guardar',
            icon: Icons.refresh,
            color: AppColors.error,
            onPressed: _send,
          ),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    final isPairs = _isPairsGame;

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.input),
          onTap: () => setState(() => _expandedLogs = !_expandedLogs),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isPairs ? 'Ver palabras' : 'Revisar respuestas',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expandedLogs ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: !_expandedLogs
              ? const SizedBox(width: double.infinity)
              : isPairs
                  ? _PairsReview(logs: widget.outcome.responseLogs)
                  : Column(
                      children: [
                        for (var i = 0;
                            i < widget.outcome.responseLogs.length;
                            i++)
                          _AnswerReviewCard(
                            index: i,
                            log: widget.outcome.responseLogs[i],
                          ),
                      ],
                    ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final Widget child;

  const _Metric({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

/// Palabras completadas / incompletas de un juego de pares.
class _PairsReview extends StatelessWidget {
  final List<ResponseLog> logs;

  const _PairsReview({required this.logs});

  @override
  Widget build(BuildContext context) {
    // Una palabra cuenta como completada si acertó en algún intento.
    final byWord = <Object, ({String text, bool isCorrect})>{};
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      final key = log.responseAnswerId ?? log.wordText ?? i;
      final existing = byWord[key];
      byWord[key] = (
        text: log.wordText ?? existing?.text ?? '—',
        isCorrect: (existing?.isCorrect ?? false) || log.isCorrect,
      );
    }

    final completed = [
      for (final w in byWord.values)
        if (w.isCorrect) w.text
    ];
    final incomplete = [
      for (final w in byWord.values)
        if (!w.isCorrect) w.text
    ];

    return Column(
      children: [
        _WordList(
          title: 'Completadas',
          color: AppColors.success,
          icon: Icons.check_circle,
          words: completed,
          emptyText: 'Ninguna aún',
        ),
        const SizedBox(height: 10),
        _WordList(
          title: 'Incompletas',
          color: AppColors.error,
          icon: Icons.cancel,
          words: incomplete,
          emptyText: '¡Todas completadas!',
        ),
      ],
    );
  }
}

class _WordList extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<String> words;
  final String emptyText;

  const _WordList({
    required this.title,
    required this.color,
    required this.icon,
    required this.words,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (words.isEmpty)
            Text(
              emptyText,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textLight,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final word in words)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      word,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Tarjeta de revisión de una pregunta (mirror de .gs-log-item).
class _AnswerReviewCard extends StatelessWidget {
  final int index;
  final ResponseLog log;

  const _AnswerReviewCard({required this.index, required this.log});

  @override
  Widget build(BuildContext context) {
    final color = log.isCorrect ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(log.isCorrect ? Icons.check_circle : Icons.cancel,
                  size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                'Pregunta ${index + 1}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ReviewRow(
            label: 'Pregunta',
            text: log.questionText,
            image: log.questionImage,
            audio: log.questionAudio,
          ),
          _ReviewRow(
            label: 'Correcta',
            color: AppColors.success,
            text: log.correctText,
            image: log.correctImage,
            audio: log.correctAudio,
          ),
          // Si acertó, "Seleccionaste" repetiría la respuesta correcta.
          if (!log.isCorrect)
            _ReviewRow(
              label: 'Seleccionaste',
              color: AppColors.error,
              text: log.selectedText ?? '(Sin respuesta)',
              image: log.selectedImage,
              audio: log.selectedAudio,
            ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final Color? color;
  final String? text;
  final String? image;
  final String? audio;

  const _ReviewRow({
    required this.label,
    this.color,
    this.text,
    this.image,
    this.audio,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = (text ?? '').isNotEmpty;
    final hasImage = (image ?? '').isNotEmpty;
    final hasAudio = (audio ?? '').isNotEmpty;
    if (!hasText && !hasImage && !hasAudio) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textLight,
              ),
            ),
          ),
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: WordImage(path: image, width: 34, height: 34),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              hasText ? text! : '—',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color ?? AppColors.textMain,
              ),
            ),
          ),
          if (hasAudio) WordAudioButton(audioPath: audio, size: 30),
        ],
      ),
    );
  }
}

/// Confetti simple animado.
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  final _random = math.Random();
  late final List<_ConfettiPiece> _pieces = List.generate(
    18,
    (i) => _ConfettiPiece(
      x: _random.nextDouble(),
      speed: 0.5 + _random.nextDouble(),
      color: [
        AppColors.primary,
        AppColors.success,
        AppColors.warning,
        AppColors.accentPink,
        AppColors.primaryBlue,
      ][i % 5],
      size: 6 + _random.nextDouble() * 6,
      phase: _random.nextDouble(),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, _controller.value),
        ),
      ),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double speed;
  final Color color;
  final double size;
  final double phase;

  _ConfettiPiece({
    required this.x,
    required this.speed,
    required this.color,
    required this.size,
    required this.phase,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double t;

  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final progress = ((t * piece.speed) + piece.phase) % 1.0;
      final y = progress * size.height;
      final x = piece.x * size.width +
          18 * math.sin(progress * 6 * math.pi + piece.phase * 10);
      final paint = Paint()..color = piece.color.withValues(alpha: 0.85);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * 4 * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: piece.size, height: piece.size),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
