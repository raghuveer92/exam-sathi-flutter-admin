import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/analytics_model.dart';
import '../models/user_model.dart';

class AdminRepository {
  final ApiClient _client;
  AdminRepository({required ApiClient client}) : _client = client;

  Future<AnalyticsModel> getAnalytics() async {
    final response = await _client.dio.get(ApiEndpoints.adminAnalytics);
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return AnalyticsModel.fromJson(data);
  }

  Future<List<AdminUserModel>> getStudents({String? query}) async {
    final response = await _client.dio.get(
      ApiEndpoints.adminStudents,
      queryParameters: query != null ? {'q': query} : null,
    );
    final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return list
        .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminUserModel> getStudentById(int id) async {
    final response = await _client.dio.get(ApiEndpoints.adminStudentById(id));
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return AdminUserModel.fromJson(data);
  }

  Future<AdminUserModel> updateStudentStatus(int id, {required bool isActive}) async {
    final response = await _client.dio.patch(
      ApiEndpoints.adminStudentStatus(id),
      queryParameters: {'isActive': isActive},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return AdminUserModel.fromJson(data);
  }
}
