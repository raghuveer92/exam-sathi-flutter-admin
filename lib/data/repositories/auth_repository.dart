import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _client;
  AuthRepository({required ApiClient client}) : _client = client;

  Future<String> login(String email, String password) async {
    final response = await _client.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    // Backend wraps all responses in { "success": true, "data": { ... } }
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final token = data['accessToken'] as String;
    await _client.saveToken(token);
    // Verify admin role
    final user = AdminUserModel.fromJson(data['user'] as Map<String, dynamic>);
    if (!user.isAdmin) {
      await _client.clearToken();
      throw Exception('Access denied: admin only');
    }
    return token;
  }

  Future<void> logout() => _client.clearToken();

  Future<bool> isLoggedIn() => _client.isLoggedIn();
}
