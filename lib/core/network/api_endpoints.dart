class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://exam-sathi.onrender.com/api/v1',
  );

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

  // Exam catalog admin
  static const String adminExamCategories = '/admin/exam-categories';
  static String adminExamCategoryById(int id) => '/admin/exam-categories/$id';

  // Subjects
  static const String subjects = '/subjects';
  static String subjectsByExam(int examId) => '/subjects/exam/$examId';
  static String subjectById(int id) => '/subjects/$id';
  static String cloneSubject(int id) => '/subjects/$id/clone';
  static String subjectGroupsByExam(int examId) => '/subject-groups/exam/$examId';
  static const String subjectGroups = '/subject-groups';
  static String subjectGroupById(int groupId) => '/subject-groups/$groupId';

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

  // Question Bank
  static const String adminQuestions = '/admin/questions';
  static String adminQuestionById(int id) => '/admin/questions/$id';
  static String adminQuestionStatus(int id) => '/admin/questions/$id/status';
  static String adminQuestionsReplaceForTopic(int topicId) =>
      '/admin/questions/topic/$topicId/replace';
  static const String adminTopicTests = '/admin/topic-tests';
  static String adminTopicTestById(int id) => '/admin/topic-tests/$id';
  static String adminTopicTestByTopic(int topicId) => '/admin/topic-tests/topic/$topicId';
}
