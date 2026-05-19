class SubjectModel {
  final int id;
  final int examId;
  final String name;
  final String? description;
  final String iconName;
  final String colorCode;
  final int displayOrder;
  final bool isActive;
  final int topicCount;

  const SubjectModel({
    required this.id,
    required this.examId,
    required this.name,
    this.description,
    required this.iconName,
    required this.colorCode,
    this.displayOrder = 0,
    this.isActive = true,
    this.topicCount = 0,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: (json['id'] as num).toInt(),
        examId: (json['examId'] as num).toInt(),
        name: json['name'] as String,
        description: json['description'] as String?,
        iconName: (json['iconName'] as String?) ?? 'menu_book',
        colorCode: (json['colorCode'] as String?) ?? '#6C63FF',
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
        isActive: (json['isActive'] as bool?) ?? true,
        topicCount: (json['topicCount'] as num?)?.toInt() ?? 0,
      );
}
