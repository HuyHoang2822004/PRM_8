import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/common/custom_textfield.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController controller;

  const EmailInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: AppStrings.emailOrPhone,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.validateEmailOrPhoneEmpty;
        }
        if (value.contains('@')) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value.trim())) {
            return AppStrings.validateEmailInvalid;
          }
        } else {
          final phoneRegex = RegExp(r'^[0-9]{9,11}$');
          if (!phoneRegex.hasMatch(value.trim())) {
            return AppStrings.validateEmailOrPhoneInvalid;
          }
        }
        return null;
      },
    );
  }
}
