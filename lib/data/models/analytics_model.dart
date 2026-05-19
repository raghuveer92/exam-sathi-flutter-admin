class AnalyticsModel {
  final int totalStudents;
  final int activeStudents;
  final int totalExams;
  final double averageCompletionPercent;
  final int todayActiveUsers;
  final List<TopStudentModel> topStudents;

  const AnalyticsModel({
    required this.totalStudents,
    required this.activeStudents,
    required this.totalExams,
    required this.averageCompletionPercent,
    required this.todayActiveUsers,
    required this.topStudents,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) => AnalyticsModel(
        totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
        activeStudents: (json['activeStudents'] as num?)?.toInt() ?? 0,
        totalExams: (json['totalExams'] as num?)?.toInt() ?? 0,
        averageCompletionPercent:
            ((json['averageCompletionPercent'] as num?) ?? 0.0).toDouble(),
        todayActiveUsers: (json['todayActiveUsers'] as num?)?.toInt() ?? 0,
        topStudents: (json['topStudents'] as List<dynamic>?)
                ?.map((e) => TopStudentModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class TopStudentModel {
  final int userId;
  final String fullName;
  final String email;
  final double completionPercent;
  final int streakDays;

  const TopStudentModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.completionPercent,
    required this.streakDays,
  });

  factory TopStudentModel.fromJson(Map<String, dynamic> json) =>
      TopStudentModel(
        userId: (json['userId'] as num).toInt(),
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        completionPercent:
            ((json['completionPercent'] as num?) ?? 0.0).toDouble(),
        streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      );
}
