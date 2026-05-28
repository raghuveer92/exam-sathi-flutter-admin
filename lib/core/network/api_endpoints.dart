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
      '/syllabus/chapters/subject/$subjectId';
  static String chapterById(int id) => '/syllabus/chapters/$id';
  static const String createChapter = '/syllabus/chapters';
  static String updateChapter(int id) => '/syllabus/chapters/$id';
  static String deleteChapter(int id) => '/syllabus/chapters/$id';

  static String topicsByChapter(int chapterId) =>
      '/syllabus/topics/chapter/$chapterId';
  static const String createTopic = '/syllabus/topics';
  static const String bulkCreateTopics = '/syllabus/topics/bulk';
  static String updateTopic(int id) => '/syllabus/topics/$id';
  static String deleteTopic(int id) => '/syllabus/topics/$id';
}
