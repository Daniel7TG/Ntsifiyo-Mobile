import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/kid_card.dart';
import '../game_session.dart';
import '../widgets/game_widgets.dart';
import '../widgets/game_summary_view.dart';

const _cardIntervalMs = 5000;
const _penaltyPts = 5;
const _correctPts = 10;

class _LotoCard {
  final int wordId;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;

  _LotoCard({
    required this.wordId,
    this.text,
    this.imageUrl,
    this.audioUrl,
  });
}

/// Lotería (mirror de LoteriaGameView.jsx): tablero de 9 cartas (cfg1);
/// la pila (cfg0) revela cartas cada 5s. Marca las de tu tablero que ya
/// salieron y presiona ¡Lotería! al completarlas.
class LoteriaGameView extends ConsumerStatefulWidget {
  final GameSession session;
  final VoidCallback onExit;

  const LoteriaGameView(
      {super.key, required this.session, required this.onExit});

  @override
  ConsumerState<LoteriaGameView> createState() => _LoteriaGameViewState();
}

class _LoteriaGameViewState extends ConsumerState<LoteriaGameView> {
  late List<_LotoCard> _pile;
  late List<_LotoCard> _board;
  int _pileIndex = -1;
  final Set<int> _revealed = {};
  final Set<int> _matched = {};
  final Set<int> _wrong = {};
  int _score = 0;

  bool _finished = false;
  Timer? _pileTimer;

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

    _LotoCard build(Word w, GameConfig cfg) => _LotoCard(
          wordId: w.id ?? 0,
          text: cfg.showText ? w.textFor(cfg) : null,
          imageUrl: cfg.showImage ? w.imageUrl : null,
          audioUrl: cfg.playAudio ? w.audioUrl : null,
        );

    final boardWords = [...data.words]..shuffle(random);
    _board = [for (final w in boardWords.take(9)) build(w, cfg1)];

    final pileWords = [...data.words]..shuffle(random);
    _pile = [for (final w in pileWords) build(w, cfg0)];

    _pileIndex = -1;
    _revealed.clear();
    _matched.clear();
    _wrong.clear();
    _score = 0;

    _finished = false;

    _pileTimer?.cancel();
    _revealNext();
    _pileTimer = Timer.periodic(
        const Duration(milliseconds: _cardIntervalMs), (_) => _revealNext());
  }

  void _revealNext() {
    final next = _pileIndex + 1;
    if (next >= _pile.length) {
      _pileTimer?.cancel();
      return;
    }
    final card = _pile[next];
    setState(() {
      _pileIndex = next;
      _revealed.add(card.wordId);
    });
    if ((card.audioUrl ?? '').isNotEmpty) playWordAudio(card.audioUrl);
  }

  void _tapBoardCard(_LotoCard card) {
    if (_finished || _matched.contains(card.wordId)) return;

    if (_revealed.contains(card.wordId)) {
      setState(() {
        _matched.add(card.wordId);
        _score += _correctPts;
      });
    } else {
      setState(() {
        _wrong.add(card.wordId);

        _score = max(0, _score - _penaltyPts);
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _wrong.remove(card.wordId));
      });
    }
  }

  void _pressLoteria() {
    final allSelected = _board.every((c) => _matched.contains(c.wordId));
    if (!allSelected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Aún no marcas todas las cartas de tu tablero.'),
      ));
      return;
    }
    _pileTimer?.cancel();
    setState(() => _finished = true);
  }

  @override
  void dispose() {
    _pileTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.data.words.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Lotería')),
        body:
            const Center(child: Text('La actividad no tiene palabras.')),
      );
    }

    if (_finished) {
      return GameSummaryView(
        outcome: GameOutcome(
          correctAnswers: _matched.length,
          totalQuestions: _board.length,
          responseLogs: [
            for (final card in _board)
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

    final current =
        _pileIndex >= 0 && _pileIndex < _pile.length ? _pile[_pileIndex] : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Lotería'),
        leading: BackButton(onPressed: widget.onExit),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Puntos: $_score',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Carta actual de la pila
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Carta actual',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 150,
                        child: current == null
                            ? const SizedBox(height: 80)
                            : TweenAnimationBuilder<double>(
                                key: ValueKey(_pileIndex),
                                tween: Tween(begin: 0.6, end: 1),
                                duration:
                                    const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) =>
                                    Transform.scale(
                                        scale: value, child: child),
                                child: GameCardWidget(
                                  text: current.text,
                                  imagePath: current.imageUrl,
                                  audioPath: current.audioUrl,
                                  disabled: true,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(
                        '${_pileIndex + 1}/${_pile.length}',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 18),
                      ),
                      const Text(
                        'cartas',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tablero 3x3
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
                children: [
                  for (final card in _board)
                    GameCardWidget(
                      text: card.text,
                      imagePath: card.imageUrl,
                      audioPath: card.audioUrl,
                      wordId: card.wordId,
                      cardState: _matched.contains(card.wordId)
                          ? GameCardState.correct
                          : _wrong.contains(card.wordId)
                              ? GameCardState.incorrect
                              : GameCardState.none,
                      onTap: () => _tapBoardCard(card),
                    ),
                ],
              ),
            ),

            // Botón ¡Lotería!
            Padding(
              padding: const EdgeInsets.all(16),
              child: KidButton(
                label: '¡LOTERÍA!',
                icon: Icons.celebration,
                color: AppColors.accentPink,
                expanded: true,
                onPressed: _pressLoteria,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
