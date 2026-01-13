import 'package:flutter/material.dart';
import 'package:spartmay/features/transaction/data/models/transaction_model.dart';
import 'package:spartmay/features/transaction/data/services/transaction_service.dart';

class CalendarProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  bool _isLoading = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  
  Map<DateTime, DailyStat> _monthlyStatsMap = {};
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  List<Transaction> _selectedDayTransactions = [];

  bool get isLoading => _isLoading;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  List<Transaction> get selectedDayTransactions => _selectedDayTransactions;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DailyStat? getStatForDay(DateTime day) {
    final key = _normalizeDate(day);
    return _monthlyStatsMap[key];
  }

  Future<void> fetchMonthlyStats(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final summary = await _service.getMonthlySummary(date.month, date.year);
      
      _monthlyIncome = summary.totalIncome;
      _monthlyExpense = summary.totalExpense;
      _monthlyStatsMap = {};
      
      for (var stat in summary.dailyStats) {
        final key = _normalizeDate(stat.date);
        _monthlyStatsMap[key] = stat;
      }
      
      print("Đã load xong lịch tháng ${date.month}: Thu $_monthlyIncome | Chi $_monthlyExpense");
      
    } catch (e) {
      print("Lỗi fetchMonthlyStats: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      
      notifyListeners(); 
      _selectedDayTransactions = await _service.getTransactionsByDate(selectedDay);
      notifyListeners(); 
    }
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    fetchMonthlyStats(focusedDay);
  }
  
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}