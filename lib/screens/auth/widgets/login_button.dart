import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/common/custom_button.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const LoginButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      label: AppStrings.loginButton,
      isLoading: isLoading,
    );
  }
}
