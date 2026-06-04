import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Animated success icon representation
                const Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.accent,
                        size: 96,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ĐẶT HÀNG THÀNH CÔNG',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cảm ơn bạn đã lựa chọn Chrono Luxury. Đơn hàng của bạn đã được tiếp nhận và lưu trữ thành công trên hệ thống dữ liệu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Delivery steps indicators
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QUY TRÌNH TIẾP THEO:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStepRow(Icons.phone_in_talk, 'Xác nhận cuộc gọi trong vòng 15 phút.'),
                      const SizedBox(height: 10),
                      _buildStepRow(Icons.local_shipping, 'Đóng gói sản phẩm và bàn giao vận chuyển.'),
                      const SizedBox(height: 10),
                      _buildStepRow(Icons.verified, 'Khách hàng kiểm tra đồng hồ trước khi thanh toán.'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 36),
                CustomButton(
                  onPressed: () => context.go('/home'),
                  label: 'QUAY LẠI TRANG CHỦ',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
