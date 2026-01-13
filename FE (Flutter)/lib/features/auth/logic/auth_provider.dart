import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> register(String fullName, String email, String password) async {
    _setLoading(true);
    
    final success = await _authService.register(fullName, email, password);

     if (!success) {
      _errorMessage = "Đăng ký thất bại. Email có thể đã tồn tại.";
    } else {
      _errorMessage = null;
    }

    _setLoading(false);
    return success;
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    final success = await _authService.login(email, password);
    
    if (!success) {
      _errorMessage = "Đăng nhập thất bại. Vui lòng kiểm tra lại.";
    } else {
      _errorMessage = null;
    }
    
    _setLoading(false);
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}