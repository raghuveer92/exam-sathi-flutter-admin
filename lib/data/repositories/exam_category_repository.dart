import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/exam_category_model.dart';

class ExamCategoryRepository {
  final ApiClient _client;
  ExamCategoryRepository({required ApiClient client}) : _client = client;

  Future<List<ExamCategoryModel>> getCategories() async {
    final response = await _client.dio.get(ApiEndpoints.adminExamCategories);
    final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return list
        .map((e) => ExamCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ExamCategoryModel> create(Map<String, dynamic> data) async {
    final response =
        await _client.dio.post(ApiEndpoints.adminExamCategories, data: data);
    return ExamCategoryModel.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<ExamCategoryModel> update(int id, Map<String, dynamic> data) async {
    final response = await _client.dio.put(
      ApiEndpoints.adminExamCategoryById(id),
      data: data,
    );
    return ExamCategoryModel.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<void> delete(int id) async {
    await _client.dio.delete(ApiEndpoints.adminExamCategoryById(id));
  }
}
