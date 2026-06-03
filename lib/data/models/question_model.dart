class QuestionModel {
  final int id;
  final int examId;
  final String examName;
  final int subjectId;
  final String subjectName;
  final int chapterId;
  final String chapterTitle;
  final int topicId;
  final String topicTitle;
  final String questionText;
  final String questionType;
  final String? explanation;
  final double marks;
  final double negativeMarks;
  final String difficultyLevel;
  final bool previousYear;
  final String? previousYearValue;
  final bool isActive;
  final List<QuestionOptionModel> options;

  QuestionModel({
    required this.id,
    required this.examId,
    required this.examName,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterTitle,
    required this.topicId,
    required this.topicTitle,
    required this.questionText,
    required this.questionType,
    this.explanation,
    required this.marks,
    required this.negativeMarks,
    required this.difficultyLevel,
    required this.previousYear,
    this.previousYearValue,
    required this.isActive,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      examId: json['examId'] as int,
      examName: json['examName'] as String? ?? '',
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String? ?? '',
      chapterId: json['chapterId'] as int,
      chapterTitle: json['chapterTitle'] as String? ?? '',
      topicId: json['topicId'] as int,
      topicTitle: json['topicTitle'] as String? ?? '',
      questionText: json['questionText'] as String? ?? '',
      questionType: json['questionType'] as String? ?? 'SINGLE_CORRECT',
      explanation: json['explanation'] as String?,
      marks: (json['marks'] as num?)?.toDouble() ?? 1,
      negativeMarks: (json['negativeMarks'] as num?)?.toDouble() ?? 0,
      difficultyLevel: json['difficultyLevel'] as String? ?? 'MEDIUM',
      previousYear: json['previousYear'] as bool? ?? false,
      previousYearValue: json['previousYearValue'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => QuestionOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionOptionModel {
  final int? id;
  final String optionKey;
  final String optionText;
  final bool isCorrect;
  final int displayOrder;

  QuestionOptionModel({
    this.id,
    required this.optionKey,
    required this.optionText,
    this.isCorrect = false,
    this.displayOrder = 0,
  });

  Map<String, dynamic> toJson() => {
        'optionKey': optionKey,
        'optionText': optionText,
        'isCorrect': isCorrect,
        'displayOrder': displayOrder,
      };

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] as int?,
      optionKey: json['optionKey'] as String? ?? '',
      optionText: json['optionText'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }
}

class TopicTestConfigModel {
  final int? id;
  final int topicId;
  final String topicTitle;
  final int numQuestions;
  final int durationMinutes;
  final String difficultyFilter;
  final bool isActive;
  final int availableQuestionCount;

  TopicTestConfigModel({
    this.id,
    required this.topicId,
    required this.topicTitle,
    required this.numQuestions,
    required this.durationMinutes,
    required this.difficultyFilter,
    required this.isActive,
    required this.availableQuestionCount,
  });

  factory TopicTestConfigModel.fromJson(Map<String, dynamic> json) {
    return TopicTestConfigModel(
      id: json['id'] as int?,
      topicId: json['topicId'] as int,
      topicTitle: json['topicTitle'] as String? ?? '',
      numQuestions: json['numQuestions'] as int? ?? 10,
      durationMinutes: json['durationMinutes'] as int? ?? 15,
      difficultyFilter: json['difficultyFilter'] as String? ?? 'ALL',
      isActive: json['isActive'] as bool? ?? true,
      availableQuestionCount: json['availableQuestionCount'] as int? ?? 0,
    );
  }

  bool get isConfigured => id != null;
}

class BulkQuestionImportResult {
  final int totalRows;
  final int imported;
  final int failed;
  final List<String> errors;

  BulkQuestionImportResult({
    required this.totalRows,
    required this.imported,
    required this.failed,
    required this.errors,
  });

  factory BulkQuestionImportResult.fromJson(Map<String, dynamic> json) {
    return BulkQuestionImportResult(
      totalRows: json['totalRows'] as int? ?? 0,
      imported: json['imported'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
      errors: (json['errors'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
