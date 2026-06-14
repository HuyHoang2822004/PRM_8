import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
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
          content: Text(AppStrings.checkoutCartEmpty),
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
      createdAt: DateTime.now(),
    );

    final created = await orderProvider.createOrder(order);
    if (!mounted) return;
    if (created != null) {
      cart.clearCart();
      context.go(AppRoutes.orderSuccess);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? AppStrings.orderFailed),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('vi');
    final cart = context.watch<CartProvider>();
    
    final shippingFee = cart.totalAmount > 5000000 ? 0 : 30000;
    final finalTotal = cart.totalAmount + shippingFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.checkoutTitle),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.orderSummary,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      const Divider(height: 20),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(AppStrings.orderSummarySubtotal, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text('${formatter.format(cart.totalAmount)}đ', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(AppStrings.orderSummaryShipping, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text(
                            shippingFee == 0 ? AppStrings.freeShippingText : '${formatter.format(shippingFee)}đ',
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
                            AppStrings.orderSummaryTotal,
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
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.shippingInfo,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nameController,
                        label: AppStrings.shippingName,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? AppStrings.validateShippingNameEmpty
                            : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _phoneController,
                        label: AppStrings.shippingPhone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.validatePhoneEmpty;
                          }
                          final phoneRegex = RegExp(r'^[0-9]{9,11}$');
                          if (!phoneRegex.hasMatch(value.trim())) {
                            return AppStrings.validatePhoneLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _addressController,
                        label: AppStrings.shippingAddress,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? AppStrings.validateAddressEmpty
                            : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _noteController,
                        label: AppStrings.note,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.paymentMethod,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: 'COD',
                        groupValue: _paymentMethod,
                        activeColor: AppColors.primary,
                        onChanged: (value) => setState(() => _paymentMethod = value!),
                        title: const Text(AppStrings.codPayment, style: TextStyle(fontSize: 13)),
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: 'Bank Transfer',
                        groupValue: _paymentMethod,
                        activeColor: AppColors.primary,
                        onChanged: (value) => setState(() => _paymentMethod = value!),
                        title: const Text(AppStrings.bankPayment, style: TextStyle(fontSize: 13)),
                      ),
                      
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
                                    AppStrings.bankInfoTitle,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(AppStrings.bankInfoBank, style: TextStyle(fontSize: 12)),
                              const Text(AppStrings.bankInfoNumber, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const Text(AppStrings.bankInfoHolder, style: TextStyle(fontSize: 12)),
                              Text('• Nội dung: CHRONO ${DateTime.now().millisecond}', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 14),
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
                                                AppStrings.qrTitle,
                                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        AppStrings.qrPrompt,
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
              
              CustomButton(
                onPressed: _placeOrder,
                label: AppStrings.placeOrderButton,
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
