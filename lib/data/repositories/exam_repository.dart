import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/exam_model.dart';

class ExamRepository {
  final ApiClient _client;
  ExamRepository({required ApiClient client}) : _client = client;

  Future<List<ExamModel>> getExams() async {
    final response = await _client.dio.get(ApiEndpoints.exams);
    final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return list
        .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ExamModel> createExam(Map<String, dynamic> data) async {
    final response = await _client.dio.post(ApiEndpoints.exams, data: data);
    final body = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ExamModel.fromJson(body);
  }

  Future<ExamModel> updateExam(int id, Map<String, dynamic> data) async {
    final response =
        await _client.dio.put(ApiEndpoints.examById(id), data: data);
    final body = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ExamModel.fromJson(body);
  }

  Future<void> deleteExam(int id) async {
    await _client.dio.delete(ApiEndpoints.examById(id));
  }
}
