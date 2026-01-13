import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spartmay/core/api/api_client.dart';
import 'package:spartmay/features/wallet/data/models/wallet_model.dart';

class WalletService {
  final Dio _dio = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<Options> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<double> getTotalBalance() async {
    try {
      final response = await _dio.get(
        '/wallets/total-balance',
        options: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load total balance');
      }
    } catch (ex) {
      throw Exception('Failed to load total balance: $ex');
    }
  }

  Future<List<Wallet>> getWallets() async {
    try {
      final response = await _dio.get(
        '/wallets',
        options: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return (response.data as List).map((json) => Wallet.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load wallets');
      }
    } catch (ex) {
      throw Exception('Failed to load wallets: $ex');
    }
  }

  Future<Wallet> createWallet(Wallet wallet) async {
    try {
      final response = await _dio.post(
        "/wallets",
        data: wallet.toJson(),
        options: await _getHeaders(),
      );
      return Wallet.fromJson(response.data);
    } catch (ex) {
      throw Exception('Failed to create wallet: $ex');
    }
  }

  Future<Wallet> updateWallet(int id, Wallet wallet) async {
    try {
      final response = await _dio.put(
        "/wallets/$id",
        data: wallet.toJson(),
        options: await _getHeaders(),
      );
      return Wallet.fromJson(response.data);
    } catch (ex) {
      throw Exception('Failed to update wallet: $ex');
    }
  }

  Future<void> deleteWallet(int id) async {
    try {
      await _dio.delete(
        "/wallets/$id",
        options: await _getHeaders(),
      );
    } catch (ex) {
      throw Exception('Failed to delete wallet: $ex');
    }
  }
}