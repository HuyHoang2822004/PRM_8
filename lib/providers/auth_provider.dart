import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../services/auth_service.dart';

enum AuthStatus { initial, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;
  static const String adminEmail = 'admin@chrono.com';
  AuthStatus status = AuthStatus.initial;
  String? errorMessage;
  bool isLoggedIn = false;
  bool isEmailNotVerified = false;
  Map<String, String> userProfile = {};

  Future<void> login(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    isEmailNotVerified = false;
    notifyListeners();

    try {
      final ok = await _authService.login(email, password);
      if (ok) {
        final currentUser = fb.FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await currentUser.reload();
          final freshUser = fb.FirebaseAuth.instance.currentUser;
          if (freshUser != null &&
              freshUser.email?.toLowerCase() != adminEmail &&
              !freshUser.emailVerified) {
            errorMessage = "Vui lòng xác thực email trước khi đăng nhập.";
            isEmailNotVerified = true;
            isLoggedIn = false;
            status = AuthStatus.error;
            await _authService.logout();
            notifyListeners();
            return;
          }
        }

        userProfile = await _authService.getUserProfile();
        isLoggedIn = true;
        status = AuthStatus.success;
      } else {
        isLoggedIn = false;
        status = AuthStatus.error;
        errorMessage = "Email hoặc mật khẩu không chính xác";
      }
    } catch (e) {
      isLoggedIn = false;
      status = AuthStatus.error;
      errorMessage = "Đã có lỗi xảy ra";
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

    final ok =
        await _authService.register(name, email, password, phone, address);
    isLoggedIn = false;
    if (ok) {
      status = AuthStatus.success;
    } else {
      status = AuthStatus.error;
      errorMessage = "Đăng ký không thành công";
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
    final hasUser = await _authService.checkLogin();
    if (hasUser) {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
        final freshUser = fb.FirebaseAuth.instance.currentUser;
        if (freshUser != null && !freshUser.emailVerified) {
          await _authService.logout();
          isLoggedIn = false;
          status = AuthStatus.initial;
          notifyListeners();
          return;
        }
      }
      isLoggedIn = true;
      userProfile = await _authService.getUserProfile();
      status = AuthStatus.success;
    } else {
      isLoggedIn = false;
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

  Future<bool> resendVerificationEmail(String email, String password) async {
    try {
      final credential =
          await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      await credential.user?.sendEmailVerification();
      await fb.FirebaseAuth.instance.signOut();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }
}
