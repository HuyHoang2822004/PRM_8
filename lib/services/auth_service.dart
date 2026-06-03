import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _loginKey = 'is_logged_in';
  static const _emailKey = 'user_email';

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, true);
    await prefs.setString(_emailKey, email);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
    await prefs.remove(_emailKey);
  }

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }
}
