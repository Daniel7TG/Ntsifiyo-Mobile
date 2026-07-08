import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../game_session.dart';
import '../widgets/game_widgets.dart';
import '../widgets/game_summary_view.dart';

class _MemoCard {
  final String uid;
  final int wordId;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;

  _MemoCard({
    required this.uid,
    required this.wordId,
    this.text,
    this.imageUrl,
    this.audioUrl,
  });
}

/// Memorama clásico (mirror de MemoramaGameView.jsx): voltea 2 cartas y
/// encuentra los pares. Carta A usa gameConfigs[0], carta B gameConfigs[1].
class MemoramaGameView extends ConsumerStatefulWidget {
  final GameSession session;
  final VoidCallback onExit;

  const MemoramaGameView(
      {super.key, required this.session, required this.onExit});

  @override
  ConsumerState<MemoramaGameView> createState() => _MemoramaGameViewState();
}

class _MemoramaGameViewState extends ConsumerState<MemoramaGameView> {
  late List<_MemoCard> _cards;
  final List<String> _flipped = [];
  final Set<int> _matched = {};
  final Set<String> _wrong = {};
  bool _locked = false;
  bool _finished = false;

  int _elapsed = 0;
  Timer? _timer;

  int get _totalPairs => _cards.length ~/ 2;

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

    _MemoCard build(Word w, GameConfig cfg, String type) => _MemoCard(
          uid: '${w.id}-$type',
          wordId: w.id ?? 0,
          text: cfg.showText ? w.textFor(cfg) : null,
          imageUrl: cfg.showImage ? w.imageUrl : null,
          audioUrl: cfg.playAudio ? w.audioUrl : null,
        );

    _cards = [
      for (final w in data.words) ...[build(w, cfg0, 'A'), build(w, cfg1, 'B')],
    ]..shuffle(random);

    _flipped.clear();
    _matched.clear();
    _wrong.clear();
    _locked = false;
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

  void _tap(_MemoCard card) {
    if (_locked ||
        _matched.contains(card.wordId) ||
        _flipped.contains(card.uid) ||
        _flipped.length == 2) {
      return;
    }

    if ((card.audioUrl ?? '').isNotEmpty) playWordAudio(card.audioUrl);

    setState(() => _flipped.add(card.uid));

    if (_flipped.length == 2) {

      _locked = true;
      final first = _cards.firstWhere((c) => c.uid == _flipped[0]);
      final second = _cards.firstWhere((c) => c.uid == _flipped[1]);

      if (first.wordId == second.wordId) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          setState(() {
            _matched.add(first.wordId);
            _flipped.clear();
            _locked = false;
          });
          if (_matched.length == _totalPairs) {
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted) setState(() => _finished = true);
            });
          }
        });
      } else {
        setState(() => _wrong.addAll(_flipped));
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            _flipped.clear();
            _wrong.clear();
            _locked = false;
          });
        });
      }
    }
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (widget.session.data.words.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Memorama')),
        body:
            const Center(child: Text('La actividad no tiene palabras.')),
      );
    }

    if (_finished) {
      return GameSummaryView(
        outcome: GameOutcome(
          correctAnswers: _matched.length,
          totalQuestions: _totalPairs,
          responseLogs: [
            for (final wordId in _cards.map((c) => c.wordId).toSet())
              ResponseLog(
                responseAnswerId: wordId,
                isCorrect: _matched.contains(wordId),
                wordText:
                    _cards.firstWhere((c) => c.wordId == wordId).text ?? '',
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

    final cols = _cards.length <= 8 ? 2 : 3;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Memorama'),
        leading: BackButton(onPressed: widget.onExit),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⏱ ${_formatTime(_elapsed)}   ${_matched.length}/$_totalPairs',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          final isMatched = _matched.contains(card.wordId);
          final isFlipped = isMatched || _flipped.contains(card.uid);
          final isWrong = _wrong.contains(card.uid);

          return _FlipCard(
            flipped: isFlipped,
            onTap: () => _tap(card),
            back: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                    color: darken(AppColors.primaryBlue, 0.15), width: 3),
                boxShadow: [
                  BoxShadow(
                      color: darken(AppColors.primaryBlue, 0.35),
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Text('?',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                        color: Colors.white)),
              ),
            ),
            front: GameCardWidget(
              text: card.text,
              imagePath: card.imageUrl,
              audioPath: card.audioUrl,
              cardState: isMatched
                  ? GameCardState.correct
                  : isWrong
                      ? GameCardState.incorrect
                      : GameCardState.none,
              disabled: true,
            ),
          );
        },
      ),
    );
  }
}

/// Carta con animación de volteo.
class _FlipCard extends StatelessWidget {
  final bool flipped;
  final Widget front;
  final Widget back;
  final VoidCallback onTap;

  const _FlipCard({
    required this.flipped,
    required this.front,
    required this.back,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: flipped ? 1 : 0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, _) {
          final angle = value * pi;
          final showFront = angle > pi / 2;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: showFront
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: front,
                  )
                : back,
          );
        },
      ),
    );
  }
}
