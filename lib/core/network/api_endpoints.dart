class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://exam-sathi.onrender.com/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Admin
  static const String adminAnalytics = '/admin/analytics';
  static const String adminStudents = '/admin/students';
  static String adminStudentById(int id) => '/admin/students/$id';
  static String adminStudentStatus(int id) => '/admin/students/$id/status';

  // Exams
  static const String exams = '/exams';
  static String examById(int id) => '/exams/$id';

  // Subjects
  static const String subjects = '/subjects';
  static String subjectsByExam(int examId) => '/subjects/exam/$examId';
  static String subjectById(int id) => '/subjects/$id';

  // Syllabus
  static String chaptersBySubject(int subjectId) =>
      '/syllabus/subjects/$subjectId/chapters';
  static String topicsByChapter(int chapterId) =>
      '/syllabus/chapters/$chapterId/topics';
}
