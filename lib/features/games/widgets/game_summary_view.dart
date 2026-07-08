import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/kid_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/states.dart';
import '../game_session.dart';

/// Resumen al terminar un juego (mirror de GameSummary.jsx):
/// porcentaje, estrellas, confetti y XP (o aviso de sincronización pendiente).
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

  int get _percentage => widget.outcome.totalQuestions > 0
      ? (widget.outcome.correctAnswers * 100 / widget.outcome.totalQuestions)
          .round()
      : 0;

  @override
  void initState() {
    super.initState();
    _send();
  }

  Future<void> _send() async {
    final result =
        await ref.read(gameSessionProvider.notifier).complete(widget.outcome);
    if (!mounted) return;
    setState(() {
      _result = result;
      _queuedOffline = result == null;
      _loading = false;
    });
  }

  /// Coyote mascota según desempeño (mirror de GameSummary.jsx + coyote web).
  (String, String, String) _headerContent() {
    if (_percentage == 100) {
      return ('assets/coyote/celebracion.webp', '¡PERFECTO!', '¡No fallaste ni una!');
    }
    if (_percentage >= 80) {
      return ('assets/coyote/celebracion.webp', '¡Increíble!', '¡Muy buen trabajo!');
    }
    if (_percentage >= 60) {
      return ('assets/coyote/saludo.webp', '¡Bien hecho!', '¡Sigue así!');
    }
    return ('assets/coyote/esperando.webp', '¡Sigue practicando!', '¡Tú puedes!');
  }

  @override
  Widget build(BuildContext context) {
    final (coyoteAsset, title, subtitle) = _headerContent();
    final stars = (_percentage / 100 * 5).round();

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

                      // Estrellas
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < 5; i++)
                            Icon(
                              i < stars ? Icons.star : Icons.star_border,
                              color: AppColors.warning,
                              size: 34,
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

                      // XP / estado de sincronización
                      if (_loading)
                        const LoadingState(message: 'Guardando tu progreso...')
                      else if (_queuedOffline)
                        _buildOfflineNote()
                      else
                        _buildXpResult(_result!),

                      const SizedBox(height: 24),
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
              const Icon(Icons.bolt, color: AppColors.warning),
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
          Text(
            '🎊 ¡Subiste al nivel ${result.currentLevel}!',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.success,
            ),
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
        border:
            Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_upload, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sin conexión: tu resultado quedó guardado y recibirás tu XP al reconectarte.',
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
