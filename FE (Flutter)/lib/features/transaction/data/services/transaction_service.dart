import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spartmay/core/api/api_client.dart';
import 'package:spartmay/features/stat/data/models/stat_model.dart';
import 'package:spartmay/features/transaction/data/models/transaction_model.dart';

class TransactionService {
  final Dio _dio = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<Options> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get(
        '/categories',
        options: await _getHeaders(),
      );
      return (response.data as List).map((c) => Category.fromJson(c)).toList();
    } catch (ex) {
      throw Exception('Failed to load categories: $ex');
    }
  }

  Future<PaginatedTransactionResponse> getTransactions({int page = 0, int size = 10}) async {
    try {
      final options = await _getHeaders();
      final response = await _dio.get(
        '/transactions', 
        queryParameters: {
          'page': page,
          'size': size,
          'sort': 'date,desc'
        },
        options: options,
      );
      
      if (response.statusCode == 200) {
        return PaginatedTransactionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> createTransaction(TransactionRequest request) async {
    try {
      final response = await _dio.post(
        "/transactions",
        data: request.toJson(),
        options: await _getHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to create transaction');
      }
      return true;
    } catch (er) {
      print('Failed to create transaction: $er');
      return false;
    }
  }

  Future<Transaction?> updateTransaction(int id, TransactionRequest request) async {
    try {
      final response = await _dio.put(
        "/transactions/$id",
        data: request.toJson(),
        options: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data);
      }
      return null;
    } catch (er) {
      print('Failed to update transaction: $er');
      return null;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final response = await _dio.delete(
        "/transactions/$id",
        options: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete transaction');
      }
    } catch (e) {
      print("Error deleting transaction: $e");
      return false;
    }
  }

  Future<MonthlySummaryResponse> getMonthlySummary(int month, int year) async {
    try {
      final url = '/transactions/monthly-summary'; // Hoặc đường dẫn đầy đủ
      print("Calling API: ${_dio.options.baseUrl}$url"); // Xem nó in ra cái gì
      final response = await _dio.get(
        "/transactions/monthly-summary",
        queryParameters: {
          "month": month,
          "year": year,
        },
        options: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return MonthlySummaryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load monthly summary');
      }
    } catch (e) {
      print("Error fetching summary: $e");
      return MonthlySummaryResponse(totalIncome: 0, totalExpense: 0, dailyStats: []);
    }
  }

  Future<List<CategoryStat>> getMonthlyStat(int month, int year, String type) async {
    try {
      final response = await _dio.get(
        "/transactions/monthly-stats",
        queryParameters: {
          "month": month,
          "year": year,
          "type": type,
        },
        options: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return (response.data as List).map((c) => CategoryStat.fromJson(c)).toList();
      } else {
        throw Exception('Failed to load monthly stat');
      }
    } catch (e) {
      print("Error fetching monthly stat: $e");
      return [];
    }
  }

  Future<List<Transaction>> getTransactionsByDate(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split("T")[0];
      final response = await _dio.get(
        "/transactions",
        queryParameters: {
          "date": formattedDate,
          "page": 0,
          "size": 100
        },
        options: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return PaginatedTransactionResponse.fromJson(response.data).content;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}