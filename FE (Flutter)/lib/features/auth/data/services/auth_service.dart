import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spartmay/core/api/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<bool> register(String fullName, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: 'auth_token', value: token);
        return true;
      }
      return false;
    } on DioException catch (ex) {
      print('Registration Error: ${ex.response?.data ?? ex.message}');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: 'auth_token', value: token);
        return true;
      }
      return false;
    } on DioException catch (ex) {
      print('Login Error: ${ex.response?.data ?? ex.message}');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}