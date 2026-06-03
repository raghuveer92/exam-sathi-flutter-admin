import 'package:admin_web_flutter/core/util/question_text_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validate accepts commas in question and explanation', () {
    const text = '''
QUESTION: What is 50% of 200, 300 and 400?
TYPE: SINGLE_CORRECT
OPTION_A: 100
OPTION_B: 150
CORRECT: A
EXPLANATION: Use 50%, then add values with commas.
MARKS: 1
NEGATIVE_MARKS: 0.25
''';

    final result = validateQuestionText(text);
    expect(result.isValid, isTrue);
    expect(result.questionCount, 1);
  });

  test('serialize and validate round trip format', () {
    final result = validateQuestionText(questionTextTemplate);
    expect(result.isValid, isTrue);
    expect(result.questionCount, 2);
  });
}
