import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';

class MockPaymentScreen extends StatefulWidget {
  final String provider; // 'momo' | 'zalopay' | 'vnpay'
  final double amount;
  final VoidCallback onSuccess;

  const MockPaymentScreen({
    super.key,
    required this.provider,
    required this.amount,
    required this.onSuccess,
  });

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.decimalPattern('vi');
    
    // Customize design based on payment gateway
    Color themeColor;
    String title;
    String logoAsset = '';
    
    switch (widget.provider.toLowerCase()) {
      case 'momo':
        themeColor = const Color(0xFFA50064); // MoMo Pink
        title = 'CỔNG THANH TOÁN MOMO';
        break;
      case 'zalopay':
        themeColor = const Color(0xFF00ADF2); // ZaloPay Blue
        title = 'CỔNG THANH TOÁN ZALOPAY';
        break;
      case 'vnpay':
      default:
        themeColor = const Color(0xFFE22119); // VNPAY Red
        title = 'CỔNG THANH TOÁN VNPAY';
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payment_outlined,
                      size: 32,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ĐANG KHỞI TẠO GIAO DỊCH',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currencyFormat.format(widget.amount)}đ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const Divider(height: 32),

                  if (_isLoading) ...[
                    const SizedBox(height: 24),
                    CircularProgressIndicator(color: themeColor),
                    const SizedBox(height: 24),
                    const Text(
                      'Đang kết nối an toàn với máy chủ ngân hàng...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // Real VietQR scannable image
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: 'https://img.vietqr.io/image/TCB-190356789012-compact.png?amount=${widget.amount.toInt()}&addInfo=CHRONO%20PAYMENT&accountName=CHRONO%20SHOWROOM',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox(
                              width: 150,
                              height: 150,
                              child: Center(
                                child: CircularProgressIndicator(color: AppColors.accent),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.qr_code_scanner,
                              size: 140,
                              color: themeColor.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'QUÉT MÃ ĐỂ THANH TOÁN (VIETQR/MOMO/ZALOPAY)',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mã QR Code đã được đồng bộ với hóa đơn đồng hồ của bạn. Vui lòng quét mã hoặc nhấp nút giả lập bên dưới để hoàn tất.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    // Success trigger button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: widget.onSuccess,
                        child: const Text(
                          'GIẢ LẬP: THANH TOÁN THÀNH CÔNG',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
