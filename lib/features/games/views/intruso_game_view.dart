import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/activity_config.dart';
import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../game_session.dart';
import '../widgets/game_widgets.dart';
import '../widgets/game_summary_view.dart';

/// Duración total de la partida (mirror de GAME_DURATION en IntrusoGameView.jsx).
const _gameDuration = 45;

/// El Intruso (mirror de IntrusoGameView.jsx): encuentra la carta que no
/// pertenece al grupo antes de que se acabe el tiempo. Acertar seguido
/// acumula combo.
class IntrusoGameView extends ConsumerStatefulWidget {
  final GameSession session;
  final VoidCallback onExit;

  const IntrusoGameView(
      {super.key, required this.session, required this.onExit});

  @override
  ConsumerState<IntrusoGameView> createState() => _IntrusoGameViewState();
}

class _IntrusoGameViewState extends ConsumerState<IntrusoGameView> {
  late List<Question> _questions;
  int _index = 0;
  int _score = 0;
  int _combo = 0;
  int _timeLeft = _gameDuration;
  int? _selectedIndex;
  bool _finished = false;
  final List<ResponseLog> _logs = [];

  Timer? _timer;

  GameConfig get _config1 => widget.session.data.promptConfig;
  GameConfig get _config2 => widget.session.data.answerConfig;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setup() {
    // El intruso baraja las opciones de cada pregunta.
    final random = Random();
    _questions = [
      for (final q in widget.session.data.questions)
        Question(
          id: q.id,
          question: q.question,
          word: q.word,
          responseList: [...q.responseList]..shuffle(random),
        ),
    ];
    _index = 0;
    _score = 0;
    _combo = 0;
    _selectedIndex = null;
    _finished = false;
    _logs.clear();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _gameDuration;
    if (_questions.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft <= 1) {
        timer.cancel();
        setState(() {
          _timeLeft = 0;
          _finished = true;
        });
        return;
      }
      setState(() => _timeLeft--);
    });
  }

  Question get _current => _questions[_index];

  Answer? get _correctOption =>
      _current.responseList.where((a) => a.isCorrect).firstOrNull;

  String? _optionText(Answer option) {
    if (!_config2.showText) return null;
    if (option.answerText.isNotEmpty) return option.answerText;
    return option.word?.textFor(_config2);
  }

  void _select(int optionIndex) {
    if (_selectedIndex != null || _finished) return;
    final option = _current.responseList[optionIndex];
    final isCorrect = option.isCorrect;
    final correct = _correctOption;

    setState(() {
      _selectedIndex = optionIndex;
      if (isCorrect) {
        _score++;
        _combo++;
      } else {
        _combo = 0;
      }
      _logs.add(ResponseLog(
        questionId: _current.id,
        responseAnswerId: option.id ?? option.wordId,
        isCorrect: isCorrect,
        questionText: _current.question.isNotEmpty
            ? _current.question
            : '¿Cuál no pertenece al grupo?',
        questionImage:
            _config1.showImage ? _current.word?.imageUrl : null,
        questionAudio:
            _config1.playAudio ? _current.word?.audioUrl : null,
        correctText: correct != null ? _optionText(correct) : null,
        correctImage: _config2.showImage ? correct?.word?.imageUrl : null,
        correctAudio: _config2.playAudio ? correct?.word?.audioUrl : null,
        selectedText: _optionText(option),
        selectedImage: _config2.showImage ? option.word?.imageUrl : null,
        selectedAudio: _config2.playAudio ? option.word?.audioUrl : null,
      ));
    });

    showGameFeedback(context, ref, correct: isCorrect);

    // Sin botón "Siguiente": el juego es contrarreloj y avanza solo.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || _finished) return;
      if (_index < _questions.length - 1) {
        setState(() {
          _index++;
          _selectedIndex = null;
        });
      } else {
        _timer?.cancel();
        setState(() => _finished = true);
      }
    });
  }

  void _restart() {
    ref.read(gameSessionProvider.notifier).restart();
    setState(_setup);
  }

  @override
  Widget build(BuildContext context) {
    final info = gameInfoFor(ActivityTypes.intruder);

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(info.title)),
        body: const Center(
            child: Text('La actividad no tiene preguntas configuradas.')),
      );
    }

    if (_finished) {
      return GameSummaryView(
        outcome: GameOutcome(
          correctAnswers: _score,
          totalQuestions: _questions.length,
          responseLogs: _logs,
        ),
        onExit: widget.onExit,
        onRetry: _restart,
      );
    }

    final question = _current;
    final hasPromptMedia = question.word != null &&
        ((_config1.showImage && (question.word!.imageUrl ?? '').isNotEmpty) ||
            (_config1.playAudio && (question.word!.audioUrl ?? '').isNotEmpty));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(info.title),
        leading: BackButton(onPressed: widget.onExit),
        actions: [
          if (_combo >= 2)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ComboBadge(combo: _combo),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_index + 1}/${_questions.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            GameTimerBar(
              timeLeft: _timeLeft,
              total: _gameDuration,
              lowTimeThreshold: 10,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  const Text(
                    '¿Cuál no pertenece al grupo?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (hasPromptMedia)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: GameCardWidget(
                          imagePath:
                              _config1.showImage ? question.word?.imageUrl : null,
                          audioPath:
                              _config1.playAudio ? question.word?.audioUrl : null,
                        ),
                      ),
                    ),

                  if (_config1.showText && question.question.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        question.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: _config2.showImage ? 0.85 : 1.9,
                    children: [
                      for (var i = 0; i < question.responseList.length; i++)
                        _buildOption(question.responseList[i], i),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(Answer option, int index) {
    final isSelected = _selectedIndex == index;
    final answered = _selectedIndex != null;
    final state = answered && option.isCorrect
        ? GameCardState.correct
        : (isSelected && !option.isCorrect)
            ? GameCardState.incorrect
            : GameCardState.none;

    final text = _optionText(option);
    final image = _config2.showImage ? option.word?.imageUrl : null;
    final audio = _config2.playAudio ? option.word?.audioUrl : null;

    if ((text ?? '').isEmpty &&
        (image ?? '').isEmpty &&
        (audio ?? '').isEmpty) {
      return const SizedBox.shrink();
    }

    return GameCardWidget(
      text: text,
      imagePath: image,
      audioPath: audio,
      cardState: state,
      disabled: answered,
      onTap: () => _select(index),
    );
  }
}

/// Insignia de racha de aciertos consecutivos.
class _ComboBadge extends StatelessWidget {
  final int combo;
  const _ComboBadge({required this.combo});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(combo),
      tween: Tween(begin: 1.4, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.warning, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department,
                size: 15, color: AppColors.warning),
            const SizedBox(width: 3),
            Text(
              'x$combo',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
