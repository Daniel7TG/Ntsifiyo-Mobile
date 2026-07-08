import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/activity_config.dart';
import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../game_session.dart';
import '../widgets/game_widgets.dart';
import '../widgets/game_summary_view.dart';

/// Motor compartido de juegos de cuestionario (mirror de QuizGameView.jsx,
/// IntrusoGameView.jsx y FillBlankGameView.jsx):
/// - QUIZ: pregunta (texto/imagen/audio) + opciones
/// - INTRUDER: opciones barajadas, encuentra la que no pertenece
/// - FILL_BLANK: oración con '___' que se rellena con la opción elegida
class QuestionnaireGameView extends ConsumerStatefulWidget {
  final GameSession session;
  final VoidCallback onExit;

  const QuestionnaireGameView({
    super.key,
    required this.session,
    required this.onExit,
  });

  @override
  ConsumerState<QuestionnaireGameView> createState() =>
      _QuestionnaireGameViewState();
}

class _QuestionnaireGameViewState
    extends ConsumerState<QuestionnaireGameView> {
  late List<Question> _questions;
  int _index = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _showResult = false;
  final List<ResponseLog> _logs = [];

  String get _gameType => widget.session.data.gameType ?? '';
  bool get _isIntruder => _gameType == ActivityTypes.intruder;
  bool get _isFillBlank => _gameType == ActivityTypes.fillBlank;

  GameConfig get _config1 => widget.session.data.promptConfig;
  GameConfig get _config2 => widget.session.data.answerConfig;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    _questions = widget.session.data.questions;
    if (_isIntruder) {
      // El intruso baraja las opciones (mirror de IntrusoGameView).
      final random = Random();
      _questions = [
        for (final q in _questions)
          Question(
            id: q.id,
            question: q.question,
            word: q.word,
            responseList: [...q.responseList]..shuffle(random),
          ),
      ];
    }
  }

  Question get _current => _questions[_index];

  String? _wordText(Word? word, GameConfig config) => word?.textFor(config);

  void _select(int optionIndex) {
    if (_selectedAnswerIndex != null) return;
    final option = _current.responseList[optionIndex];
    final isCorrect = option.isCorrect;

    setState(() {
      _selectedAnswerIndex = optionIndex;
      if (isCorrect) _score++;
      _logs.add(ResponseLog(
        questionId: _current.id,
        responseAnswerId: option.id ?? option.wordId,
        isCorrect: isCorrect,
      ));
    });

    showGameFeedback(context, correct: isCorrect);
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selectedAnswerIndex = null;
      });
    } else {
      setState(() => _showResult = true);
    }
  }

  void _restart() {
    ref.read(gameSessionProvider.notifier).restart();
    setState(() {
      _index = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _showResult = false;
      _logs.clear();
      _setup();
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = gameInfoFor(_gameType);

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(info.title)),
        body: const Center(
            child: Text('La actividad no tiene preguntas configuradas.')),
      );
    }

    if (_showResult) {
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
    final promptText = question.question.isNotEmpty
        ? question.question
        : _wordText(question.word, _config1);
    final hasPromptMedia = question.word != null &&
        ((_config1.showImage && (question.word!.imageUrl ?? '').isNotEmpty) ||
            (_config1.playAudio && (question.word!.audioUrl ?? '').isNotEmpty));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(info.title),
        leading: BackButton(onPressed: widget.onExit),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_index + 1}/${_questions.length}',
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
            // Barra de progreso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_index + 1) / _questions.length,
                  minHeight: 7,
                  backgroundColor: Colors.white,
                  color: info.color,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_isIntruder)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '¿Cuál no pertenece al grupo?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),

                  // Estímulo de la pregunta (imagen/audio)
                  if (hasPromptMedia)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: GameCardWidget(
                          imagePath: _config1.showImage
                              ? question.word?.imageUrl
                              : null,
                          audioPath: _config1.playAudio
                              ? question.word?.audioUrl
                              : null,
                        ),
                      ),
                    ),

                  // Texto de la pregunta
                  if (_config1.showText && promptText != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _isFillBlank
                          ? _buildFillBlankPrompt(promptText)
                          : Text(
                              promptText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: AppColors.textMain,
                              ),
                            ),
                    ),

                  // Opciones
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio:
                        _config2.showImage ? 0.85 : 1.9,
                    children: [
                      for (var i = 0; i < question.responseList.length; i++)
                        _buildOption(question.responseList[i], i),
                    ],
                  ),

                  const SizedBox(height: 16),
                  if (_selectedAnswerIndex != null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: info.color,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.card)),
                        ),
                        onPressed: _next,
                        child: Text(
                          _index < _questions.length - 1
                              ? 'Siguiente →'
                              : 'Ver Resultados',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Oración con espacio en blanco que se rellena al elegir (FillBlank).
  Widget _buildFillBlankPrompt(String text) {
    final selectedText = _selectedAnswerIndex != null
        ? _optionText(_current.responseList[_selectedAnswerIndex!])
        : null;
    final parts = text.split('___');
    final spans = <InlineSpan>[];
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        spans.add(TextSpan(
          text: ' ${selectedText ?? '_____'} ',
          style: TextStyle(
            color: selectedText != null
                ? AppColors.primary
                : AppColors.textLight,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w900,
          ),
        ));
      }
    }
    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        fontSize: 19,
        color: AppColors.textMain,
        height: 1.5,
      ),
    );
  }

  String? _optionText(Answer option) {
    if (!_config2.showText) return null;
    if (option.answerText.isNotEmpty) return option.answerText;
    return _wordText(option.word, _config2);
  }

  Widget _buildOption(Answer option, int index) {
    final isSelected = _selectedAnswerIndex == index;
    final answered = _selectedAnswerIndex != null;
    final state = answered && option.isCorrect
        ? GameCardState.correct
        : (isSelected && !option.isCorrect)
            ? GameCardState.incorrect
            : GameCardState.none;

    final text = _optionText(option);
    final image = _config2.showImage ? option.word?.imageUrl : null;
    final audio = _config2.playAudio ? option.word?.audioUrl : null;

    // Omitir opciones totalmente vacías (mirror de la web).
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
