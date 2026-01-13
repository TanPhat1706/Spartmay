import 'package:flutter/material.dart';
import 'package:spartmay/features/stat/data/models/stat_model.dart';
import 'package:spartmay/features/transaction/data/services/transaction_service.dart';

class StatProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  DateTime _selectedDate = DateTime.now();
  int _touchedIndex = -1;
  List<CategoryStat> _stats = [];
  bool _isLoading = false;
  String _currentType = 'EXPENSE';


  DateTime get selectedDate => _selectedDate;
  int get touchedIndex => _touchedIndex;
  List<CategoryStat> get stats => _stats;
  bool get isLoading => _isLoading;
  String get currentType => _currentType;

  double get totalExpense => _stats.fold(0, (sum, item) => sum + item.amount);

  void changeMonth(int month) {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + month, 1);
    fetchStat();
  }

  void touchSection(int index) {
    _touchedIndex = index;
    notifyListeners();
  }

  void setTransactionType(String type) {
    if (_currentType != type) {
      _currentType = type;
      _touchedIndex = -1; // Reset touch khi đổi tab
      fetchStat(); // Gọi lại API
    }
  }

  Future<void> fetchStat() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _service.getMonthlyStat(_selectedDate.month, _selectedDate.year, _currentType);
      _stats.sort((a, b) => b.amount.compareTo(a.amount));
    } catch (e) {
      print("Error fetching stat: $e");
      _stats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}