import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/question_model.dart';

class QuestionBankRepository {
  final ApiClient _client;
  QuestionBankRepository({required ApiClient client}) : _client = client;

  Future<List<QuestionModel>> listQuestions({int? topicId, int? examId}) async {
    final response = await _client.dio.get(
      ApiEndpoints.adminQuestions,
      queryParameters: {
        if (topicId != null) 'topicId': topicId,
        if (examId != null) 'examId': examId,
      },
    );
    final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return list.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<QuestionModel> createQuestion(Map<String, dynamic> body) async {
    final response = await _client.dio.post(ApiEndpoints.adminQuestions, data: body);
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return QuestionModel.fromJson(data);
  }

  Future<QuestionModel> updateQuestion(int id, Map<String, dynamic> body) async {
    final response = await _client.dio.put(ApiEndpoints.adminQuestionById(id), data: body);
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return QuestionModel.fromJson(data);
  }

  Future<void> deleteQuestion(int id) async {
    await _client.dio.delete(ApiEndpoints.adminQuestionById(id));
  }

  Future<QuestionModel> updateQuestionStatus(int id, bool isActive) async {
    final response = await _client.dio.patch(
      ApiEndpoints.adminQuestionStatus(id),
      queryParameters: {'isActive': isActive},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return QuestionModel.fromJson(data);
  }

  Future<BulkQuestionImportResult> replaceTopicQuestions(
    int topicId,
    int examId,
    String textContent,
  ) async {
    final response = await _client.dio.post(
      ApiEndpoints.adminQuestionsReplaceForTopic(topicId),
      queryParameters: {'examId': examId},
      data: {'textContent': textContent},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return BulkQuestionImportResult.fromJson(data);
  }

  Future<TopicTestConfigModel?> getTopicTestByTopic(int topicId) async {
    final response = await _client.dio.get(ApiEndpoints.adminTopicTestByTopic(topicId));
    final data = (response.data as Map<String, dynamic>)['data'];
    if (data == null) return null;
    return TopicTestConfigModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<TopicTestConfigModel>> listTopicTests() async {
    final response = await _client.dio.get(ApiEndpoints.adminTopicTests);
    final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return list.map((e) => TopicTestConfigModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TopicTestConfigModel> saveTopicTest(Map<String, dynamic> body) async {
    final response = await _client.dio.post(ApiEndpoints.adminTopicTests, data: body);
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return TopicTestConfigModel.fromJson(data);
  }

  Future<void> deleteTopicTest(int configId) async {
    await _client.dio.delete(ApiEndpoints.adminTopicTestById(configId));
  }
}
