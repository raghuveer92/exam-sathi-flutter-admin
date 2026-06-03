import '../../data/models/question_model.dart';

const questionTextSeparator = '\n---\n\n';

const questionTextTemplate = '''QUESTION: What is the average of 10, 20 and 30?
TYPE: SINGLE_CORRECT
OPTION_A: 15
OPTION_B: 20
OPTION_C: 25
OPTION_D: 30
CORRECT: B
EXPLANATION: Average = (10 + 20 + 30) / 3 = 20
MARKS: 1
NEGATIVE_MARKS: 0.25
PREVIOUS_YEAR: false

---

QUESTION: Which of the following are prime numbers?
TYPE: MULTIPLE_CORRECT
OPTION_A: 2
OPTION_B: 3
OPTION_C: 4
OPTION_D: 5
CORRECT: A|B|D
EXPLANATION: 2, 3 and 5 are prime numbers.
MARKS: 2
NEGATIVE_MARKS: 0.5
PREVIOUS_YEAR: true
PREVIOUS_YEAR_VALUE: 2023
''';

class QuestionTextValidationResult {
  final List<String> errors;
  final int questionCount;

  QuestionTextValidationResult({
    required this.errors,
    required this.questionCount,
  });

  bool get isValid => errors.isEmpty && questionCount > 0;
}

String serializeQuestion(QuestionModel question) {
  final buffer = StringBuffer();
  buffer.writeln('QUESTION: ${question.questionText}');
  buffer.writeln('TYPE: ${question.questionType}');

  final sortedOptions = [...question.options]
    ..sort((a, b) => a.optionKey.compareTo(b.optionKey));
  for (final option in sortedOptions) {
    buffer.writeln('OPTION_${option.optionKey}: ${option.optionText}');
  }

  final correctKeys = sortedOptions
      .where((o) => o.isCorrect)
      .map((o) => o.optionKey)
      .join('|');
  buffer.writeln('CORRECT: $correctKeys');

  if (question.explanation != null && question.explanation!.isNotEmpty) {
    buffer.writeln('EXPLANATION: ${question.explanation}');
  }
  buffer.writeln('MARKS: ${question.marks}');
  buffer.writeln('NEGATIVE_MARKS: ${question.negativeMarks}');
  buffer.writeln('PREVIOUS_YEAR: ${question.previousYear}');
  if (question.previousYearValue != null && question.previousYearValue!.isNotEmpty) {
    buffer.writeln('PREVIOUS_YEAR_VALUE: ${question.previousYearValue}');
  }
  return buffer.toString().trimRight();
}

String serializeQuestions(List<QuestionModel> questions) {
  return questions.map(serializeQuestion).join(questionTextSeparator);
}

bool isQuestionTextEffectivelyEmpty(String text) {
  final normalized = text.replaceAll('\r\n', '\n').trim();
  if (normalized.isEmpty) return true;

  var hasQuestionContent = false;
  for (final rawLine in normalized.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    if (RegExp(r'^-+$').hasMatch(line)) continue;
    hasQuestionContent = true;
    break;
  }
  return !hasQuestionContent;
}

QuestionTextValidationResult validateQuestionText(String text) {
  final errors = <String>[];
  if (text.trim().isEmpty) {
    return QuestionTextValidationResult(errors: ['Paste at least one question'], questionCount: 0);
  }

  final blocks = text.replaceAll('\r\n', '\n').trim().split('\n---\n');
  var questionIndex = 0;

  for (final rawBlock in blocks) {
    final block = rawBlock.trim();
    if (block.isEmpty) continue;
    questionIndex++;

    final fields = <String, String>{};
    final options = <String, String>{};
    String? currentKey;
    final currentValue = StringBuffer();

    void flush() {
      final key = currentKey;
      if (key == null) return;
      final value = currentValue.toString().trim();
      if (key.startsWith('OPTION_') && key.length == 'OPTION_'.length + 1) {
        options[key.substring('OPTION_'.length)] = value;
      } else {
        fields[key] = value;
      }
      currentKey = null;
      currentValue.clear();
    }

    for (final rawLine in block.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        if (currentKey != null && currentValue.isNotEmpty) {
          currentValue.write('\n');
        }
        continue;
      }

      final match = RegExp(r'^([A-Z][A-Z0-9_]*):\s*(.*)$').firstMatch(line);
      if (match != null) {
        flush();
        currentKey = match.group(1)!;
        currentValue.write(match.group(2)!);
      } else if (currentKey != null) {
        if (currentValue.isNotEmpty) currentValue.write('\n');
        currentValue.write(line);
      } else {
        errors.add('Question $questionIndex: expected KEY: value format');
        break;
      }
    }
    flush();

    if (!fields.containsKey('QUESTION') || fields['QUESTION']!.isEmpty) {
      errors.add('Question $questionIndex: QUESTION is required');
    }
    if (!fields.containsKey('TYPE') || fields['TYPE']!.isEmpty) {
      errors.add('Question $questionIndex: TYPE is required');
    }
    if (options.length < 2) {
      errors.add('Question $questionIndex: at least two OPTION_X fields required');
    }
    if (!fields.containsKey('CORRECT') || fields['CORRECT']!.isEmpty) {
      errors.add('Question $questionIndex: CORRECT is required');
    }

    final marks = double.tryParse(fields['MARKS'] ?? '1') ?? 1;
    if (marks <= 0) {
      errors.add('Question $questionIndex: MARKS must be greater than 0');
    }
    final negative = double.tryParse(fields['NEGATIVE_MARKS'] ?? '0') ?? 0;
    if (negative < 0) {
      errors.add('Question $questionIndex: NEGATIVE_MARKS cannot be negative');
    }

    final correctKeys = (fields['CORRECT'] ?? '')
        .split(RegExp(r'[|,]'))
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toList();
    for (final key in correctKeys) {
      if (!options.containsKey(key)) {
        errors.add('Question $questionIndex: CORRECT references unknown option $key');
      }
    }

    final type = (fields['TYPE'] ?? '').toUpperCase();
    if (type.contains('SINGLE') && correctKeys.length != 1) {
      errors.add('Question $questionIndex: SINGLE_CORRECT requires exactly one CORRECT option');
    }
  }

  return QuestionTextValidationResult(errors: errors, questionCount: questionIndex);
}
