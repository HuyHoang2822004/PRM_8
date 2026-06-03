import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:prm_8/providers/auth_provider.dart';
import 'package:prm_8/screens/auth/login_screen.dart';
import 'package:prm_8/services/auth_service.dart';

class _FakeAuthService extends AuthService {
  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> checkLogin() async => false;
}

void main() {
  testWidgets('login screen validates required fields', (tester) async {
    final provider = AuthProvider(_FakeAuthService());

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: provider,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Email required'), findsOneWidget);
    expect(find.text('Password required'), findsOneWidget);
  });
}
