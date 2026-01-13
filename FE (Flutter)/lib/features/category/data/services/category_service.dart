import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spartmay/core/api/api_client.dart';
import 'package:spartmay/features/transaction/data/models/transaction_model.dart'; // Import model Category cũ

class CategoryService {
  final Dio _dio = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<Options> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Lấy tất cả danh mục
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories', options: await _getHeaders());
      return (response.data as List).map((c) => Category.fromJson(c)).toList();
    } catch (e) {
      throw Exception('Lỗi load danh mục: $e');
    }
  }

  // Thêm mới
  Future<bool> createCategory(String name, String icon, String type) async {
    try {
      await _dio.post('/categories', 
        data: {'name': name, 'icon': icon, 'type': type}, // type: INCOME hoặc EXPENSE
        options: await _getHeaders()
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sửa
  Future<bool> updateCategory(int id, String name, String icon) async {
    try {
      await _dio.put('/categories/$id', 
        data: {'name': name, 'icon': icon},
        options: await _getHeaders()
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Xóa
  Future<bool> deleteCategory(int id) async {
    try {
      await _dio.delete('/categories/$id', options: await _getHeaders());
      return true;
    } catch (e) {
      return false;
    }
  }
}