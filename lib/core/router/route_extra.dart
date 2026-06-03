import 'package:dio/dio.dart';

/// Parses [GoRouterState.extra] from nested exam → subject → chapter → topic navigation.
class RouteExtra {
  RouteExtra._({
    required this.examName,
    required this.subjectName,
    required this.chapterTitle,
  });

  final String examName;
  final String subjectName;
  final String chapterTitle;

  factory RouteExtra.forSubjects(Object? extra) {
    if (extra is String) {
      return RouteExtra._(
        examName: extra,
        subjectName: 'Subjects',
        chapterTitle: 'Topics',
      );
    }
    if (extra is Map) {
      return RouteExtra._(
        examName: _mapString(extra, 'examName', 'Subjects'),
        subjectName: _mapString(extra, 'subjectName', 'Subjects'),
        chapterTitle: _mapString(extra, 'chapterTitle', 'Topics'),
      );
    }
    return RouteExtra._(
      examName: 'Subjects',
      subjectName: 'Subjects',
      chapterTitle: 'Topics',
    );
  }

  factory RouteExtra.forChapters(Object? extra) {
    if (extra is String) {
      return RouteExtra._(
        examName: 'Exam',
        subjectName: extra,
        chapterTitle: 'Topics',
      );
    }
    if (extra is Map) {
      return RouteExtra._(
        examName: _mapString(extra, 'examName', 'Exam'),
        subjectName: _mapString(extra, 'subjectName', 'Chapters'),
        chapterTitle: _mapString(extra, 'chapterTitle', 'Topics'),
      );
    }
    return RouteExtra._(
      examName: 'Exam',
      subjectName: 'Chapters',
      chapterTitle: 'Topics',
    );
  }

  factory RouteExtra.forTopics(Object? extra) {
    if (extra is String) {
      return RouteExtra._(
        examName: 'Exam',
        subjectName: 'Subject',
        chapterTitle: extra,
      );
    }
    if (extra is Map) {
      return RouteExtra._(
        examName: _mapString(extra, 'examName', 'Exam'),
        subjectName: _mapString(extra, 'subjectName', 'Subject'),
        chapterTitle: _mapString(extra, 'chapterTitle', 'Topics'),
      );
    }
    return RouteExtra._(
      examName: 'Exam',
      subjectName: 'Subject',
      chapterTitle: 'Topics',
    );
  }

  static String _mapString(Map map, String key, String fallback) {
    final value = map[key];
    if (value == null) return fallback;
    return value.toString();
  }
}

String errorMessage(Object error) {
  if (error is DioException) {
    final msg = error.message;
    if (msg != null && msg.isNotEmpty) return msg;
  }
  final text = error.toString();
  if (text.startsWith('Exception: ')) {
    return text.replaceFirst('Exception: ', '');
  }
  return text;
}
