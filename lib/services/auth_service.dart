import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _loginKey = 'is_logged_in';
  static const _emailKey = 'user_email';

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Default testing account
    if (cleanEmail == 'admin@chrono.com' && cleanPassword == '123456') {
      await prefs.setBool(_loginKey, true);
      await prefs.setString(_emailKey, cleanEmail);
      if (prefs.getString('user_name') == null) {
        await prefs.setString('user_name', 'Chrono Admin');
        await prefs.setString('user_phone', '0909123456');
        await prefs.setString('user_address', '123 Nguyễn Văn Linh, Quận 7, TP.HCM');
      }
      return true;
    }

    // Registered account check
    final storedEmail = prefs.getString(_emailKey)?.trim().toLowerCase();
    final storedPassword = prefs.getString('user_password')?.trim();
    if (storedEmail != null && storedEmail == cleanEmail && storedPassword == cleanPassword) {
      await prefs.setBool(_loginKey, true);
      return true;
    }

    return false;
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String phone,
    String address,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name.trim());
    await prefs.setString('user_phone', phone.trim());
    await prefs.setString('user_address', address.trim());
    await prefs.setString(_emailKey, email.trim().toLowerCase());
    await prefs.setString('user_password', password.trim());
    await prefs.setBool(_loginKey, true);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
  }

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }
  
  Future<Map<String, String>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'Khách hàng',
      'email': prefs.getString(_emailKey) ?? '',
      'phone': prefs.getString('user_phone') ?? '',
      'address': prefs.getString('user_address') ?? '',
    };
  }
}
