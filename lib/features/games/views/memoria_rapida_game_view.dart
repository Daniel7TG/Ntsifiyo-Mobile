import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/kid_card.dart';
import '../game_session.dart';
import '../widgets/game_widgets.dart';
import '../widgets/game_summary_view.dart';

const _gameDuration = 60; // segundos
const _baseSpeedMs = 3500;
const _minSpeedMs = 1200;
const _speedDecreaseMs = 150;
const _matchProbability = 0.7;

/// Memoria Rápida (mirror de MemoriaRapidaGameView.jsx): aparece una palabra
/// arriba (cfg0) y una carta abajo (cfg1); decide rápido si coinciden.
class MemoriaRapidaGameView extends ConsumerStatefulWidget {
  final GameSession session;
  final VoidCallback onExit;

  const MemoriaRapidaGameView(
      {super.key, required this.session, required this.onExit});

  @override
  ConsumerState<MemoriaRapidaGameView> createState() =>
      _MemoriaRapidaGameViewState();
}

class _MemoriaRapidaGameViewState
    extends ConsumerState<MemoriaRapidaGameView> {
  final _random = Random();

  late List<Word> _words;
  int _topIndex = 0;
  Word? _bottomWord;
  bool _currentMatch = false;

  String _phase = 'countdown'; // countdown | playing | finished
  int _countdown = 3;
  int _timeLeft = _gameDuration;
  int _speed = _baseSpeedMs;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _correct = 0;
  int _total = 0;
  final List<ResponseLog> _logs = [];

  Timer? _mainTimer;
  Timer? _cardTimer;
  Timer? _countdownTimer;

  GameConfig get _cfg0 => widget.session.data.promptConfig;
  GameConfig get _cfg1 => widget.session.data.answerConfig;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    _words = [...widget.session.data.words]..shuffle(_random);
    _topIndex = 0;
    _bottomWord = null;
    _phase = 'countdown';
    _countdown = 3;
    _timeLeft = _gameDuration;
    _speed = _baseSpeedMs;
    _score = 0;
    _combo = 0;
    _maxCombo = 0;
    _correct = 0;
    _total = 0;
    _logs.clear();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _phase = 'playing');
        _startMainTimer();
        _nextCard(0);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _startMainTimer() {
    _mainTimer?.cancel();
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft <= 1) {
        timer.cancel();
        _finish();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _nextCard(int index) {
    if (index >= _words.length) {
      _finish();
      return;
    }
    final top = _words[index];
    final shouldMatch =
        _random.nextDouble() < _matchProbability || _words.length == 1;
    Word bottom;
    if (shouldMatch) {
      bottom = top;
      _currentMatch = true;
    } else {
      do {
        bottom = _words[_random.nextInt(_words.length)];
      } while (bottom.id == top.id);
      _currentMatch = false;
    }
    setState(() {
      _topIndex = index;
      _bottomWord = bottom;
    });

    // Auto-skip: si se acaba el tiempo de la carta cuenta como incorrecta.
    _cardTimer?.cancel();
    _cardTimer = Timer(Duration(milliseconds: _speed), () => _answer(null));
  }

  void _answer(bool? saysMatch) {
    if (_phase != 'playing') return;
    _cardTimer?.cancel();

    final isCorrect = saysMatch != null && saysMatch == _currentMatch;
    final topWord = _words[_topIndex];

    _logs.add(ResponseLog(
      responseAnswerId: topWord.id,
      isCorrect: isCorrect,
      wordText: topWord.mazahuaWord.isNotEmpty
          ? topWord.mazahuaWord
          : topWord.spanishWord,
    ));

    setState(() {
      _total++;
      if (isCorrect) {
        final multiplier = min(1 + _combo * 0.1, 3.0);
        _score += (100 * multiplier).round();
        _combo++;
        _maxCombo = max(_maxCombo, _combo);
        _correct++;
        _speed = max(_minSpeedMs, _speed - _speedDecreaseMs);
      } else {
        _combo = 0;
      }
    });

    showGameFeedback(context, ref, correct: isCorrect);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted && _phase == 'playing') _nextCard(_topIndex + 1);
    });
  }

  void _finish() {
    if (_phase == 'finished') return;
    _mainTimer?.cancel();
    _cardTimer?.cancel();
    setState(() => _phase = 'finished');
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    _cardTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.data.words.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Memoria Rápida')),
        body:
            const Center(child: Text('La actividad no tiene palabras.')),
      );
    }

    if (_phase == 'finished') {
      return GameSummaryView(
        outcome: GameOutcome(
          correctAnswers: _correct,
          totalQuestions: _total > 0 ? _total : 1,
          responseLogs: _logs,
        ),
        onExit: widget.onExit,
        onRetry: () {
          ref.read(gameSessionProvider.notifier).restart();
          setState(_setup);
        },
      );
    }

    if (_phase == 'countdown') {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(_countdown),
            tween: Tween(begin: 0.4, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Text(
              '$_countdown',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                fontSize: 96,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    }

    final top = _words[_topIndex];
    final bottom = _bottomWord;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Memoria Rápida'),
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
                      color: _timeLeft <= 10
                          ? AppColors.error
                          : AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '$_timeLeft s',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _timeLeft <= 10
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Marcador
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Puntos: $_score',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  if (_combo > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset('assets/svgs/racha.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                  AppColors.primary, BlendMode.srcIn)),
                          const SizedBox(width: 4),
                          Text(
                            'Combo x$_combo',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Palabra de arriba (referencia)
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: GameCardWidget(
                      text: _cfg0.showText ? top.textFor(_cfg0) : null,
                      imagePath: _cfg0.showImage ? top.imageUrl : null,
                      audioPath: _cfg0.playAudio ? top.audioUrl : null,
                      wordId: top.id,
                      disabled: true,
                    ),
                  ),
                ),
              ),

              const Icon(Icons.compare_arrows,
                  size: 32, color: AppColors.textLight),

              // Carta de abajo (por decidir), con barra de tiempo
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (bottom != null)
                          TweenAnimationBuilder<double>(
                            key: ValueKey('$_topIndex-${bottom.id}'),
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 250),
                            builder: (context, value, child) =>
                                Opacity(opacity: value, child: child),
                            child: GameCardWidget(
                              text: _cfg1.showText
                                  ? bottom.textFor(_cfg1)
                                  : null,
                              imagePath:
                                  _cfg1.showImage ? bottom.imageUrl : null,
                              audioPath:
                                  _cfg1.playAudio ? bottom.audioUrl : null,
                              wordId: bottom.id,
                              disabled: true,
                            ),
                          ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          key: ValueKey('bar-$_topIndex'),
                          tween: Tween(begin: 1, end: 0),
                          duration: Duration(milliseconds: _speed),
                          builder: (context, value, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: Colors.white,
                              color: value > 0.35
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botones ✓ / ✗
              Row(
                children: [
                  Expanded(
                    child: KidButton(
                      label: 'No es',
                      icon: Icons.close,
                      color: AppColors.error,
                      expanded: true,
                      onPressed: () => _answer(false),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: KidButton(
                      label: '¡Es igual!',
                      icon: Icons.check,
                      color: AppColors.success,
                      expanded: true,
                      onPressed: () => _answer(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
