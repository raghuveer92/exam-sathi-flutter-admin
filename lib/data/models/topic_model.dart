class TopicModel {
  final int id;
  final int chapterId;
  final String title;
  final String? description;
  final double estimatedHours;
  final String difficultyLevel;
  final int orderIndex;
  final bool isActive;

  const TopicModel({
    required this.id,
    required this.chapterId,
    required this.title,
    this.description,
    required this.estimatedHours,
    required this.difficultyLevel,
    required this.orderIndex,
    required this.isActive,
  });

  factory TopicModel.fromJson(Map<String, dynamic> j) => TopicModel(
        id: (j['id'] as num).toInt(),
        chapterId: (j['chapterId'] as num).toInt(),
        title: j['title'] as String,
        description: j['description'] as String?,
        estimatedHours: (j['estimatedHours'] as num?)?.toDouble() ?? 1.0,
        difficultyLevel: j['difficultyLevel'] as String? ?? 'MEDIUM',
        orderIndex: (j['orderIndex'] as num?)?.toInt() ?? 0,
        isActive: (j['isActive'] as bool?) ?? true,
      );
}
