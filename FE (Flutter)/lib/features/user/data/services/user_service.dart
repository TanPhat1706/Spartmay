import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spartmay/core/api/api_client.dart';
import 'package:spartmay/features/user/data/models/user_model.dart';

class UserService {
  final Dio _dio = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<Options> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<UserModel> fetchUserProfile() async {
    try {
      final response = await _dio.get(
        "/users/me",
        options: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}