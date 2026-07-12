import 'package:flutter/material.dart';

import '../services/auth_service.dart';

enum AuthStatus { initial, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;
  AuthStatus status = AuthStatus.initial;
  String? errorMessage;
  bool isLoggedIn = false;
  Map<String, String> userProfile = {};

  Future<void> login(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final ok = await _authService.login(email, password);
    isLoggedIn = ok;
    if (ok) {
      userProfile = await _authService.getUserProfile();
      status = AuthStatus.success;
    } else {
      status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String phone,
    String address,
  ) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final ok = await _authService.register(name, email, password, phone, address);
    isLoggedIn = ok;
    if (ok) {
      userProfile = await _authService.getUserProfile();
      status = AuthStatus.success;
    } else {
      status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    isLoggedIn = false;
    userProfile = {};
    status = AuthStatus.initial;
    notifyListeners();
  }

  Future<void> checkLogin() async {
    isLoggedIn = await _authService.checkLogin();
    if (isLoggedIn) {
      userProfile = await _authService.getUserProfile();
      status = AuthStatus.success;
    } else {
      status = AuthStatus.initial;
    }
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String address,
    String? avatarUrl,
  }) async {
    status = AuthStatus.loading;
    notifyListeners();

    final ok = await _authService.updateUserProfile(
      name: name,
      phone: phone,
      address: address,
      avatarUrl: avatarUrl,
    );
    if (ok) {
      userProfile = await _authService.getUserProfile();
      status = AuthStatus.success;
    } else {
      status = AuthStatus.error;
    }
    notifyListeners();
    return ok;
  }
}
