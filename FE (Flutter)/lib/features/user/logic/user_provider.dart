import 'package:flutter/material.dart';
import 'package:spartmay/features/user/data/models/user_model.dart';
import 'package:spartmay/features/user/data/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser() async {
    _setLoading(true);
    try {
      _user = await _userService.fetchUserProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print("Error loading user: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}