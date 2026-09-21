import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../game_session.dart';
import '../widgets/game_widgets.dart';
import '../widgets/game_summary_view.dart';

class _PairCard {
  final int wordId;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;

  _PairCard({
    required this.wordId,
    this.text,
    this.imageUrl,
    this.audioUrl,
  });
}

/// Pares (mirror de ParesGameView.jsx): dos columnas barajadas;
/// toca una carta de la izquierda y su par de la derecha para unirlas.
class ParesGameView extends ConsumerStatefulWidget {
  final GameSession session;
  final VoidCallback onExit;

  const ParesGameView(
      {super.key, required this.session, required this.onExit});

  @override
  ConsumerState<ParesGameView> createState() => _ParesGameViewState();
}

class _ParesGameViewState extends ConsumerState<ParesGameView> {
  late List<_PairCard> _left;
  late List<_PairCard> _right;
  final Set<int> _matched = {};
  int? _selectedLeft;
  int? _wrongRight;
  bool _finished = false;
  int _elapsed = 0;
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

    List<_PairCard> build(GameConfig cfg) => [
          for (final w in data.words)
            _PairCard(
              wordId: w.id ?? 0,
              text: cfg.showText ? w.textFor(cfg) : null,
              imageUrl: cfg.showImage ? w.imageUrl : null,
              audioUrl: cfg.playAudio ? w.audioUrl : null,
            ),
        ]..shuffle(random);

    _left = build(cfg0);
    _right = build(cfg1);
    _matched.clear();
    _selectedLeft = null;
    _wrongRight = null;
    _finished = false;
    _elapsed = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_finished) setState(() => _elapsed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tapLeft(_PairCard card) {
    if (_matched.contains(card.wordId)) return;
    if ((card.audioUrl ?? '').isNotEmpty) playWordAudio(card.audioUrl);
    setState(() => _selectedLeft = card.wordId);
  }

  void _tapRight(_PairCard card) {
    if (_matched.contains(card.wordId) || _selectedLeft == null) return;
    if ((card.audioUrl ?? '').isNotEmpty) playWordAudio(card.audioUrl);

    if (card.wordId == _selectedLeft) {
      setState(() {
        _matched.add(card.wordId);
        _selectedLeft = null;
      });
      showGameFeedback(context, ref, correct: true);
      if (_matched.length == _left.length) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => _finished = true);
        });
      }
    } else {
      setState(() => _wrongRight = card.wordId);
      showGameFeedback(context, ref, correct: false);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _wrongRight = null;
            _selectedLeft = null;
          });
        }
      });
    }
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (widget.session.data.words.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Pares')),
        body:
            const Center(child: Text('La actividad no tiene palabras.')),
      );
    }

    if (_finished) {
      return GameSummaryView(
        outcome: GameOutcome(
          correctAnswers: _matched.length,
          totalQuestions: _left.length,
          responseLogs: [
            for (final card in _left)
              ResponseLog(
                responseAnswerId: card.wordId,
                isCorrect: _matched.contains(card.wordId),
                wordText: card.text ?? '',
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
        title: const Text('Pares'),
        leading: BackButton(onPressed: widget.onExit),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatTime(_elapsed)}   ${_matched.length}/${_left.length}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted),
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
              padding: EdgeInsets.all(12),
              child: Text(
                'Toca una carta de la izquierda y luego su par de la derecha',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildColumn(_left, isLeft: true)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildColumn(_right, isLeft: false)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<_PairCard> cards, {required bool isLeft}) {
    return Column(
      children: [
        for (final card in cards)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Opacity(
              opacity: _matched.contains(card.wordId) ? 0.45 : 1,
              child: GameCardWidget(
                text: card.text,
                imagePath: card.imageUrl,
                audioPath: card.audioUrl,
                wordId: card.wordId,
                cardState: _matched.contains(card.wordId)
                    ? GameCardState.correct
                    : (!isLeft && _wrongRight == card.wordId)
                        ? GameCardState.incorrect
                        : (isLeft && _selectedLeft == card.wordId)
                            ? GameCardState.correct
                            : GameCardState.none,
                disabled: _matched.contains(card.wordId),
                onTap: () => isLeft ? _tapLeft(card) : _tapRight(card),
              ),
            ),
          ),
      ],
    );
  }
}
