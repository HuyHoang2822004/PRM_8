import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/common/custom_textfield.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;

  const PasswordInput({super.key, required this.controller});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: AppStrings.password,
      obscureText: _obscure,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility : Icons.visibility_off,
          color: AppColors.textSecondary,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.validatePasswordEmpty;
        }
        if (value.length < 6) {
          return AppStrings.validatePasswordLength;
        }
        return null;
      },
    );
  }
}
