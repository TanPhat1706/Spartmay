import 'package:flutter/material.dart';
import 'package:spartmay/features/transaction/data/models/transaction_model.dart';
import 'package:spartmay/features/category/data/services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();
  
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  // Getter lọc danh mục theo loại để hiển thị lên Tab
  List<Category> get expenseCategories => 
      _categories.where((c) => c.type == TransactionType.EXPENSE).toList();
      
  List<Category> get incomeCategories => 
      _categories.where((c) => c.type == TransactionType.INCOME).toList();

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _service.getCategories();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(String name, String icon, TransactionType type) async {
    final typeStr = type == TransactionType.INCOME ? 'INCOME' : 'EXPENSE';
    final success = await _service.createCategory(name, icon, typeStr);
    if (success) await fetchCategories(); // Reload list
    return success;
  }

  Future<bool> updateCategory(int id, String name, String icon) async {
    final success = await _service.updateCategory(id, name, icon);
    if (success) await fetchCategories();
    return success;
  }

  Future<bool> deleteCategory(int id) async {
    final success = await _service.deleteCategory(id);
    if (success) await fetchCategories();
    return success;
  }
}