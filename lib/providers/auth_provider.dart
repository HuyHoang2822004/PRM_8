import 'package:flutter/material.dart';

import '../services/auth_service.dart';

enum AuthStatus { initial, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;
  AuthStatus status = AuthStatus.initial;
  String? errorMessage;
  bool isLoggedIn = false;

  Future<void> login(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    if (!email.contains('@')) {
      status = AuthStatus.error;
      errorMessage = 'Email không hợp lệ';
      notifyListeners();
      return;
    }
    if (password.length < 6) {
      status = AuthStatus.error;
      errorMessage = 'Mật khẩu tối thiểu 6 ký tự';
      notifyListeners();
      return;
    }

    final ok = await _authService.login(email, password);
    isLoggedIn = ok;
    status = ok ? AuthStatus.success : AuthStatus.error;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    isLoggedIn = false;
    status = AuthStatus.initial;
    notifyListeners();
  }

  Future<void> checkLogin() async {
    isLoggedIn = await _authService.checkLogin();
    status = isLoggedIn ? AuthStatus.success : AuthStatus.initial;
    notifyListeners();
  }
}
