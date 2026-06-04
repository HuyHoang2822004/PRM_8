import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  String _paymentMethod = 'COD';

  @override
  void initState() {
    super.initState();
    // Pre-fill recipient info from auth profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        setState(() {
          _nameController.text = auth.userProfile['name'] ?? '';
          _phoneController.text = auth.userProfile['phone'] ?? '';
          _addressController.text = auth.userProfile['address'] ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giỏ hàng trống, không thể đặt hàng'),
          backgroundColor: AppColors.accent,
        ),
      );
      return;
    }

    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      items: cart.items,
      receiverName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      paymentMethod: _paymentMethod,
    );

    final created = await orderProvider.createOrder(order);
    if (!mounted) return;
    if (created != null) {
      cart.clearCart();
      context.go('/order-success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? 'Không thể đặt hàng, vui lòng thử lại'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('vi');
    final cart = context.watch<CartProvider>();
    
    // Calculate shipping (free over 5,000,000)
    final shippingFee = cart.totalAmount > 5000000 ? 0 : 30000;
    final finalTotal = cart.totalAmount + shippingFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('XÁC NHẬN ĐƠN HÀNG'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (_, orderProvider, __) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Order Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TÓM TẮT ĐƠN HÀNG',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      const Divider(height: 20),
                      // List of products
                      ...cart.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.name} (x${item.quantity})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${formatter.format(item.total)}đ',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 20),
                      // Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tiền hàng:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text('${formatter.format(cart.totalAmount)}đ', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Phí giao hàng:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text(
                            shippingFee == 0 ? 'Miễn phí' : '${formatter.format(shippingFee)}đ',
                            style: TextStyle(
                              fontSize: 13,
                              color: shippingFee == 0 ? Colors.green : AppColors.textPrimary,
                              fontWeight: shippingFee == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng thanh toán:',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            '${formatter.format(finalTotal)}đ',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 2. Shipping Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'THÔNG TIN GIAO HÀNG',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Họ tên người nhận',
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Vui lòng nhập họ tên người nhận'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Số điện thoại liên hệ',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          final phoneRegex = RegExp(r'^[0-9]{9,11}$');
                          if (!phoneRegex.hasMatch(value.trim())) {
                            return 'Số điện thoại không hợp lệ (9-11 số)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _addressController,
                        label: 'Địa chỉ giao hàng chi tiết',
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Vui lòng nhập địa chỉ nhận hàng'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _noteController,
                        label: 'Ghi chú cho shipper (Không bắt buộc)',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 3. Payment Method Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PHƯƠNG THỨC THANH TOÁN',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: 'COD',
                        groupValue: _paymentMethod,
                        activeColor: AppColors.primary,
                        onChanged: (value) => setState(() => _paymentMethod = value!),
                        title: const Text('Thanh toán khi nhận hàng (COD)', style: TextStyle(fontSize: 13)),
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: 'Bank Transfer',
                        groupValue: _paymentMethod,
                        activeColor: AppColors.primary,
                        onChanged: (value) => setState(() => _paymentMethod = value!),
                        title: const Text('Chuyển khoản ngân hàng (Techcombank)', style: TextStyle(fontSize: 13)),
                      ),
                      
                      // Animated Bank Transfer instructions with Simulated QR
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.account_balance, size: 18, color: AppColors.accent),
                                  SizedBox(width: 8),
                                  Text(
                                    'Thông tin tài khoản cửa hàng',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text('• Ngân hàng: Techcombank (TCB)', style: TextStyle(fontSize: 12)),
                              const Text('• Số tài khoản: 19035678889012', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const Text('• Tên chủ tài khoản: CONG TY CHRONO LUXURY', style: TextStyle(fontSize: 12)),
                              Text('• Nội dung: CHRONO ${DateTime.now().millisecond}', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 14),
                              // Visual QR Code Simulation
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 130,
                                        height: 130,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.qr_code_2, size: 64, color: AppColors.primary.withOpacity(0.85)),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'MÃ QR THANH TOÁN',
                                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Quét mã để chuyển khoản nhanh',
                                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        crossFadeState: _paymentMethod == 'Bank Transfer'
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 4. Place Order button
              CustomButton(
                onPressed: _placeOrder,
                label: 'HOÀN TẤT ĐẶT HÀNG',
                isLoading: orderProvider.isSubmitting,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
