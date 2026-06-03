import 'subject_model.dart';

class ExamSubjectGroupModel {
  final int id;
  final int examId;
  final String groupName;
  final bool isOptional;
  final int minSelection;
  final int maxSelection;
  final int displayOrder;
  final int selectedCount;
  final List<SubjectModel> subjects;

  const ExamSubjectGroupModel({
    required this.id,
    required this.examId,
    required this.groupName,
    this.isOptional = false,
    this.minSelection = 0,
    this.maxSelection = 0,
    this.displayOrder = 0,
    this.selectedCount = 0,
    this.subjects = const [],
  });

  factory ExamSubjectGroupModel.fromJson(Map<String, dynamic> json) => ExamSubjectGroupModel(
        id: (json['id'] as num).toInt(),
        examId: (json['examId'] as num).toInt(),
        groupName: (json['groupName'] as String?) ?? 'Subject Group',
        isOptional: (json['isOptional'] as bool?) ?? false,
        minSelection: (json['minSelection'] as num?)?.toInt() ?? 0,
        maxSelection: (json['maxSelection'] as num?)?.toInt() ?? 0,
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
        selectedCount: (json['selectedCount'] as num?)?.toInt() ?? 0,
        subjects: (json['subjects'] as List<dynamic>? ?? const [])
            .map((item) => SubjectModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}