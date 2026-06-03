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
  final int? groupId;
  final String? groupName;
  final bool? groupOptional;
  final int? groupMinSelection;
  final int? groupMaxSelection;
  final bool selected;

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
    this.groupId,
    this.groupName,
    this.groupOptional,
    this.groupMinSelection,
    this.groupMaxSelection,
    this.selected = false,
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
        groupId: (json['groupId'] as num?)?.toInt(),
        groupName: json['groupName'] as String?,
        groupOptional: json['groupOptional'] as bool?,
        groupMinSelection: (json['groupMinSelection'] as num?)?.toInt(),
        groupMaxSelection: (json['groupMaxSelection'] as num?)?.toInt(),
        selected: (json['selected'] as bool?) ?? false,
      );
}
