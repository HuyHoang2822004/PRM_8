import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import 'widgets/email_input.dart';
import 'widgets/login_button.dart';
import 'widgets/login_title.dart';
import 'widgets/password_input.dart';
import 'widgets/register_prompt.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    
    await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    
    if (!mounted) return;
    if (authProvider.status == AuthStatus.success) {
      context.go(AppRoutes.home);
      return;
    }
    
    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.accent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.loginFailed),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingXXLarge,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidthLogin),
            child: Consumer<AuthProvider>(
              builder: (_, auth, __) => Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LoginTitle(),
                    const SizedBox(height: AppSizes.paddingXXLarge),
                    EmailInput(controller: _emailController),
                    const SizedBox(height: AppSizes.paddingMedium),
                    PasswordInput(controller: _passwordController),
                    const SizedBox(height: AppSizes.paddingLarge),
                    LoginButton(
                      onPressed: _submit,
                      isLoading: auth.status == AuthStatus.loading,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    const RegisterPrompt(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
