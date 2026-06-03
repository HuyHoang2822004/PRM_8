import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 90),
              const SizedBox(height: 12),
              const Text('Order Created Successfully'),
              const SizedBox(height: 12),
              CustomButton(
                onPressed: () => context.go('/home'),
                label: 'Back To Home',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
