import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../game_session.dart';
import '../widgets/game_widgets.dart';
import '../widgets/game_summary_view.dart';

/// Tiempo según dificultad (mirror de TripasGameView.jsx).
const _timeByDifficulty = {'EASY': 150, 'MEDIUM': 100, 'HARD': 60};
const _minPointDist = 0.012;
const _originGrace = 0.06;
const _cardWidthPct = 0.20;

class _TripasCard {
  final String uid;
  final int wordId;
  final String side; // 'L' | 'R'
  final String? text;
  final String? imageUrl;
  final String? audioUrl;
  Offset pos = Offset.zero; // centro normalizado 0..1

  _TripasCard({
    required this.uid,
    required this.wordId,
    required this.side,
    this.text,
    this.imageUrl,
    this.audioUrl,
  });
}

/// Tripas del Gato (mirror de TripasGameView.jsx): une cada carta con su par
/// trazando líneas libres que no pueden cruzar las ya dibujadas.
class TripasGameView extends ConsumerStatefulWidget {
  final GameSession session;
  final VoidCallback onExit;

  const TripasGameView(
      {super.key, required this.session, required this.onExit});

  @override
  ConsumerState<TripasGameView> createState() => _TripasGameViewState();
}

class _TripasGameViewState extends ConsumerState<TripasGameView> {
  late List<_TripasCard> _cards;
  late List<Word> _gameWords;
  final List<({int wordId, List<Offset> points})> _matchedLines = [];
  final Set<int> _matched = {};
  List<Offset>? _draft;
  _TripasCard? _dragStart;
  bool _finished = false;
  int _timeLeft = 100;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    final data = widget.session.data;
    final cfg0 = data.promptConfig;
    final cfg1 = data.answerConfig;
    final random = Random();
    _gameWords = data.words;

    _TripasCard build(Word w, GameConfig cfg, String side) => _TripasCard(
          uid: '${w.id}-$side',
          wordId: w.id ?? 0,
          side: side,
          text: cfg.showText ? w.textFor(cfg) : null,
          imageUrl: cfg.showImage ? w.imageUrl : null,
          audioUrl: cfg.playAudio ? w.audioUrl : null,
        );

    _cards = [
      for (final w in data.words) ...[build(w, cfg0, 'L'), build(w, cfg1, 'R')],
    ]..shuffle(random);

    // Colocar cartas al azar sin encimarse (mirror del layout web).
    const cardW = _cardWidthPct;
    const boardAR = 0.75; // tablero 3:4 en móvil
    const cardH = cardW * boardAR;
    const marginX = cardW / 2 + 0.02;
    const marginY = cardH / 2 + 0.02;

    final placed = <Offset>[];
    for (final card in _cards) {
      Offset pos;
      var attempts = 0;
      do {
        pos = Offset(
          marginX + random.nextDouble() * (1 - 2 * marginX),
          marginY + random.nextDouble() * (1 - 2 * marginY),
        );
        attempts++;
      } while (attempts < 500 &&
          placed.any((p) =>
              (pos.dx - p.dx).abs() < cardW &&
              (pos.dy - p.dy).abs() < cardH));
      card.pos = pos;
      placed.add(pos);
    }

    _matchedLines.clear();
    _matched.clear();
    _draft = null;
    _dragStart = null;
    _finished = false;
    _timeLeft = _timeByDifficulty[
            (data.difficult ?? 'MEDIUM').toUpperCase()] ??
        100;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft <= 1) {
        timer.cancel();
        setState(() {
          _timeLeft = 0;
          _finished = true;
        });
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Geometría: ¿los segmentos AB y CD se cruzan? ─────────────────────
  static int _orient(Offset a, Offset b, Offset c) =>
      ((b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx))
          .sign
          .toInt();

  static bool _segmentsIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
    final o1 = _orient(p1, p2, p3);
    final o2 = _orient(p1, p2, p4);
    final o3 = _orient(p3, p4, p1);
    final o4 = _orient(p3, p4, p2);
    return o1 != o2 && o3 != o4;
  }

  _TripasCard? _cardAt(Offset norm, double boardAR) {
    const cardW = _cardWidthPct;
    final cardH = cardW * boardAR;
    for (final card in _cards.reversed) {
      if ((norm.dx - card.pos.dx).abs() <= cardW / 2 &&
          (norm.dy - card.pos.dy).abs() <= cardH / 2) {
        return card;
      }
    }
    return null;
  }

  void _panStart(Offset norm, double boardAR) {
    if (_finished) return;
    final card = _cardAt(norm, boardAR);
    if (card == null || _matched.contains(card.wordId)) return;
    if ((card.audioUrl ?? '').isNotEmpty) playWordAudio(card.audioUrl);
    setState(() {
      _dragStart = card;
      _draft = [card.pos];
    });
  }

  void _panUpdate(Offset norm) {
    final draft = _draft;
    if (_dragStart == null || draft == null) return;

    final last = draft.last;
    if ((norm - last).distance < _minPointDist) return;

    final farFromStart = (norm - draft.first).distance > _originGrace;
    if (farFromStart) {
      for (final line in _matchedLines) {
        final p = line.points;
        for (var i = 0; i < p.length - 1; i++) {
          if (_segmentsIntersect(last, norm, p[i], p[i + 1])) {
            _abortDraft(withError: true);
            return;
          }
        }
      }
    }
    setState(() => _draft = [...draft, norm]);
  }

  void _panEnd(Offset norm, double boardAR) {
    final drag = _dragStart;
    final draft = _draft;
    if (drag == null || draft == null) return;

    final target = _cardAt(norm, boardAR);
    if (target != null &&
        target.side != drag.side &&
        !_matched.contains(target.wordId)) {
      if (target.wordId == drag.wordId) {
        setState(() {
          _matchedLines
              .add((wordId: target.wordId, points: [...draft, target.pos]));
          _matched.add(target.wordId);
          _dragStart = null;
          _draft = null;
        });
        showGameFeedback(context, ref, correct: true);
        if (_matched.length == _gameWords.length) {
          _timer?.cancel();
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) setState(() => _finished = true);
          });
        }
        return;
      }
      _abortDraft(withError: true);
      return;
    }
    _abortDraft(withError: false);
  }

  void _abortDraft({required bool withError}) {
    setState(() {
      _dragStart = null;
      _draft = null;
    });
    if (withError) showGameFeedback(context, ref, correct: false);
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (widget.session.data.words.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Tripas del Gato')),
        body:
            const Center(child: Text('La actividad no tiene palabras.')),
      );
    }

    if (_finished) {
      return GameSummaryView(
        outcome: GameOutcome(
          correctAnswers: _matched.length,
          totalQuestions: _gameWords.length,
          responseLogs: [
            for (final w in _gameWords)
              ResponseLog(
                responseAnswerId: w.id,
                isCorrect: _matched.contains(w.id),
                wordText: w.spanishWord.isNotEmpty
                    ? w.spanishWord
                    : w.mazahuaWord,
              ),
          ],
        ),
        onExit: widget.onExit,
        onRetry: () {
          ref.read(gameSessionProvider.notifier).restart();
          setState(_setup);
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tripas del Gato'),
        leading: BackButton(onPressed: widget.onExit),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer,
                      size: 16,
                      color: _timeLeft <= 15
                          ? AppColors.error
                          : AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatTime(_timeLeft)}   ${_matched.length}/${_gameWords.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _timeLeft <= 15
                          ? AppColors.error
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Une cada carta con su par sin cruzar las líneas dibujadas',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 0.75,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final boardSize = Size(
                          constraints.maxWidth, constraints.maxHeight);
                      final boardAR =
                          boardSize.width / boardSize.height;

                      Offset toNorm(Offset local) => Offset(
                          local.dx / boardSize.width,
                          local.dy / boardSize.height);

                      return GestureDetector(
                        onPanStart: (d) =>
                            _panStart(toNorm(d.localPosition), boardAR),
                        onPanUpdate: (d) =>
                            _panUpdate(toNorm(d.localPosition)),
                        onPanEnd: (d) =>
                            _panEnd(toNorm(d.localPosition), boardAR),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                                color: AppColors.border, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xFFCBD5E1),
                                  offset: Offset(0, 4)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.card - 3),
                            child: Stack(
                              children: [
                                // Líneas
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _LinesPainter(
                                      matchedLines: _matchedLines,
                                      draft: _draft,
                                    ),
                                  ),
                                ),
                                // Cartas
                                for (final card in _cards)
                                  Positioned(
                                    left: card.pos.dx * boardSize.width -
                                        (_cardWidthPct *
                                                boardSize.width) /
                                            2,
                                    top: card.pos.dy * boardSize.height -
                                        (_cardWidthPct *
                                                boardSize.width) /
                                            2,
                                    width:
                                        _cardWidthPct * boardSize.width,
                                    height:
                                        _cardWidthPct * boardSize.width,
                                    child: _buildCard(card),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_TripasCard card) {
    final isMatched = _matched.contains(card.wordId);
    final isActive = _dragStart?.uid == card.uid;

    return Container(
      decoration: BoxDecoration(
        color: isMatched
            ? AppColors.success.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched
              ? AppColors.success
              : isActive
                  ? AppColors.primary
                  : AppColors.border,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0xFFE2E8F0), offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: (card.imageUrl ?? '').isNotEmpty
          ? WordImage(path: card.imageUrl, fit: BoxFit.contain)
          : Center(
              child: card.text != null
                  ? Text(
                      card.text!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    )
                  : const Icon(Icons.volume_up,
                      size: 20, color: AppColors.primary),
            ),
    );
  }
}

class _LinesPainter extends CustomPainter {
  final List<({int wordId, List<Offset> points})> matchedLines;
  final List<Offset>? draft;

  _LinesPainter({required this.matchedLines, required this.draft});

  void _drawLine(Canvas canvas, Size size, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx * size.width, p.dy * size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final matchedPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final draftPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final line in matchedLines) {
      _drawLine(canvas, size, line.points, matchedPaint);
    }
    if (draft != null) _drawLine(canvas, size, draft!, draftPaint);
  }

  @override
  bool shouldRepaint(_LinesPainter oldDelegate) => true;
}
