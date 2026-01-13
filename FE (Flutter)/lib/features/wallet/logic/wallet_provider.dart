import 'package:flutter/material.dart';
import 'package:spartmay/features/wallet/data/models/wallet_model.dart';
import 'package:spartmay/features/wallet/data/services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  List<Wallet> _wallets = [];
  double _totalBalance = 0.0;
  bool _isLoading = false;
  String? _error;

  List<Wallet> get wallets => _wallets;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallets = await _service.getWallets();
    } catch (er) {
      _error = er.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTotalBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _totalBalance = await _service.getTotalBalance();
    } catch (er) {
      _error = er.toString();
      _totalBalance = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addWallet(Wallet wallet) async {
    try {
      final newWallet = await _service.createWallet(wallet);
      _wallets.add(newWallet);
      notifyListeners();
      return true;
    } catch (er) {
      _error = er.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWallet(int id, Wallet wallet) async {
    try {
      final updatedWallet = await _service.updateWallet(id, wallet);
      final index = _wallets.indexWhere((w) => w.id == id);
      if (index != -1) {
        _wallets[index] = updatedWallet;
        notifyListeners();
      }
      return true;
    } catch (er) {
      _error = er.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWallet(int id) async {
    try {
      await _service.deleteWallet(id);
      _wallets.removeWhere((w) => w.id == id);
      notifyListeners();
      return true;
    } catch (er) {
      _error = er.toString();
      notifyListeners();
      return false;
    }
  }
}