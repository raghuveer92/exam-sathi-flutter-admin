class ChapterModel {
  final int id;
  final int subjectId;
  final String title;
  final String? description;
  final int orderIndex;
  final bool isActive;
  final int topicCount;

  const ChapterModel({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    required this.orderIndex,
    required this.isActive,
    required this.topicCount,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> j) => ChapterModel(
        id: (j['id'] as num).toInt(),
        subjectId: (j['subjectId'] as num).toInt(),
        title: j['title'] as String,
        description: j['description'] as String?,
        orderIndex: (j['orderIndex'] as num?)?.toInt() ?? 0,
        isActive: (j['isActive'] as bool?) ?? true,
        topicCount: (j['topicCount'] as num?)?.toInt() ?? 0,
      );
}
