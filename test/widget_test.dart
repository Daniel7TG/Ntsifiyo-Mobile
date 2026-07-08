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
}
