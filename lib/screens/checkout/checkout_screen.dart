import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
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
  String _paymentMethod = 'COD';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: cart.items,
      receiverName: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      paymentMethod: _paymentMethod,
    );

    final created = await orderProvider.createOrder(order);
    if (!mounted) return;
    if (created != null) {
      cart.clearCart();
      context.go('/order-success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<OrderProvider>(
          builder: (_, orderProvider, __) => Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Receiver Name',
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Name is required' : null,
                ),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Phone is required' : null,
                ),
                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Address is required'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Payment Method'),
                RadioListTile<String>(
                  value: 'COD',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                  title: const Text('COD'),
                ),
                RadioListTile<String>(
                  value: 'Bank Transfer',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                  title: const Text('Bank Transfer'),
                ),
                CustomButton(
                  onPressed: _placeOrder,
                  label: 'Place Order',
                  isLoading: orderProvider.isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
