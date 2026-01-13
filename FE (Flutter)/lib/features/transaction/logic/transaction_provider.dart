import 'package:flutter/material.dart';
import 'package:spartmay/features/transaction/data/models/transaction_model.dart';
import 'package:spartmay/features/transaction/data/services/transaction_service.dart';
import 'package:spartmay/features/wallet/logic/wallet_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<Category> _allCategories = [];
  bool _isLoading = false;
  
  // List transaction quản lý local
  List<Transaction> _transactions = [];
  
  // Pagination State
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _pageSize = 10;
  MonthlySummaryResponse? _monthlySummary;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  // String? _error;
  MonthlySummaryResponse? get monthlySummary => _monthlySummary;

  List<Category> get expenseCategories => 
      _allCategories.where((c) => c.type == TransactionType.EXPENSE).toList();

  List<Category> get incomeCategories => 
      _allCategories.where((c) => c.type == TransactionType.INCOME).toList();

  Future<void> fetchMonthlySummary() async {
    final now = DateTime.now();
    try {
      // Gọi service lấy dữ liệu tháng/năm hiện tại
      _monthlySummary = await _service.getMonthlySummary(now.month, now.year);
      notifyListeners();
    } catch (e) {
      print("Lỗi load summary: $e");
    }
  }

  // 1. Fetch Categories
  Future<void> fetchCategories() async {
    if (_allCategories.isNotEmpty) return; // Cache nhẹ, có rồi không load lại
    _isLoading = true;
    notifyListeners();
    try {
      _allCategories = await _service.getCategories();
    } catch (er) {
      print(er);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Refresh List (Kéo để load mới)
  Future<void> refreshTransactions() async {
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();
    await loadMoreTransactions();
  }

  // 3. Load More (Pagination)
  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _service.getTransactions(page: _currentPage, size: _pageSize);
      
      if (_currentPage == 0) {
        _transactions = response.content;
      } else {
        _transactions.addAll(response.content);
      }

      _hasMore = !response.last; 
      if (_hasMore) _currentPage++;
      
    } catch (e) {
      print("Lỗi load more: $e");
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // 4. Add Transaction
  Future<bool> addTransaction({
    required double amount,
    required String note,
    required int categoryId,
    required int walletId,
    required DateTime date,
    required WalletProvider walletProvider,
  }) async {
    _isLoading = true;
    notifyListeners();

    final request = TransactionRequest(
      amount: amount,
      note: note,
      categoryId: categoryId,
      walletId: walletId,
      date: date,
    );

    final success = await _service.createTransaction(request);

    if (success) {
      // Logic quan trọng:
      // 1. Reload ví để cập nhật số dư
      walletProvider.fetchWallets(); 
      // 2. Reload list giao dịch để giao dịch mới hiện lên đầu
      await refreshTransactions(); 
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // 5. Update Transaction (Đã hoàn thiện)
  Future<Transaction?> updateTransaction({
    required int id,
    required double amount,
    required String note,
    required int categoryId,
    required int walletId,
    required DateTime date,
    required WalletProvider walletProvider,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    final request = TransactionRequest(
      amount: amount,
      note: note,
      categoryId: categoryId,
      walletId: walletId,
      date: date,
    );

    // Gọi service, nhận về object đã update từ Server
    final updatedTransaction = await _service.updateTransaction(id, request);

    if (updatedTransaction != null) {
      // Cập nhật ngay vào list local để UI đổi màu/text mà ko cần reload
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        walletProvider.fetchWallets();
      }
    }

    _isLoading = false;
    notifyListeners();
    return updatedTransaction;
  }

  // 6. Delete Transaction
  Future<bool> deleteTransaction(int id, WalletProvider walletProvider) async {
    // Optimistic UI: Xóa trên UI trước cho mượt (hoặc hiện loading)
    try {
      final success = await _service.deleteTransaction(id);
      
      if (success) {
        // Xóa khỏi list local
        _transactions.removeWhere((t) => t.id == id);
        walletProvider.fetchWallets();
        notifyListeners(); 
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}