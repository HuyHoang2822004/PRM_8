import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../widgets/cart/cart_item_widget.dart';
import '../../widgets/common/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('vi');
    return Consumer<CartProvider>(
      builder: (_, cart, __) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(child: Text('Giỏ hàng trống'))
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (_, index) {
                        final item = cart.items[index];
                        return CartItemWidget(
                          item: item,
                          onIncrease: () => cart.increaseQty(item),
                          onDecrease: () => cart.decreaseQty(item),
                          onRemove: () => cart.removeItem(item),
                        );
                      },
                    ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('${formatter.format(cart.totalAmount)}đ'),
              ],
            ),
            const SizedBox(height: 10),
            CustomButton(
              onPressed: cart.items.isEmpty ? null : () => context.push('/checkout'),
              label: 'Checkout',
            ),
          ],
        ),
      ),
    );
  }
}
