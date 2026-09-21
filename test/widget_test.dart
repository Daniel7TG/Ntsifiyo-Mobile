import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/data/models/models.dart';

void main() {
  test('GameData parsea payload de startGame con alias de campos', () {
    final data = GameData.fromJson({
      'gameType': 'QUESTIONNAIRE',
      'questions': [
        {
          'question': '¿Cómo se dice perro?',
          'responseList': [
            {'answerText': "dyo'o", 'isCorrect': true, 'wordId': 1},
            {'answerText': 'mizhi', 'isCorrect': false, 'wordId': 2},
          ],
        }
      ],
      'gameconfigs': [
        {
          'showText': true,
          'showImage': false,
          'playAudio': false,
          'isMazahua': true
        }
      ],
    });

    expect(data.questions, hasLength(1));
    expect(data.questions.first.responseList, hasLength(2));
    expect(data.questions.first.responseList.first.isCorrect, isTrue);
    expect(data.promptConfig.isMazahua, isTrue);
    expect(data.promptConfig.showImage, isFalse);
  });

  test('AppUser serializa ida y vuelta', () {
    const user = AppUser(
        firstname: 'Ana', lastname: 'García', userType: Roles.student);
    final restored = AppUser.fromJson(user.toJson());
    expect(restored.displayName, 'Ana García');
    expect(restored.isStudent, isTrue);
  });

  test(
      'Word y Answer dejan imageUrl/audioUrl en null cuando el backend no '
      'los manda, en vez de fabricar una ruta de asset que puede no '
      'existir en el bundle (WordImage resuelve ese fallback por wordId '
      'en tiempo de render, no el modelo)', () {
    final word = Word.fromJson({'id': 5, 'spanishWord': 'abeja', 'mazahuaWord': 'ngïnï'});
    expect(word.imageUrl, isNull);
    expect(word.audioUrl, isNull);
    expect(word.id, 5);

    final answer = Answer.fromJson({'wordId': 5, 'answerText': 'abeja', 'isCorrect': true});
    expect(answer.word?.imageUrl, isNull);
    expect(answer.word?.audioUrl, isNull);
    expect(answer.word?.id, 5);

    final data = GameData.fromJson({
      'words': [
        {'id': 5, 'spanishWord': 'abeja', 'mazahuaWord': 'ngïnï'}
      ],
      'questions': [
        {
          'id': 10,
          'question': '¿Qué animal es?',
          'responseList': [
            {'wordId': 5, 'isCorrect': true}
          ]
        }
      ]
    });

    final linkedWord = data.questions.first.responseList.first.word;
    expect(linkedWord, isNotNull);
    expect(linkedWord?.imageUrl, isNull);
    expect(linkedWord?.audioUrl, isNull);
    expect(linkedWord?.id, 5);
  });

  test(
      'Word.fromJson sí conserva imageUrl/audioUrl cuando el backend los '
      'manda explícitamente', () {
    final word = Word.fromJson({
      'id': 5,
      'spanishWord': 'abeja',
      'mazahuaWord': 'ngïnï',
      'imageUrl': 'https://cdn.example.com/abeja.webp',
      'audioUrl': 'https://cdn.example.com/abeja.mp3',
    });
    expect(word.imageUrl, 'https://cdn.example.com/abeja.webp');
    expect(word.audioUrl, 'https://cdn.example.com/abeja.mp3');
  });
}
