import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('vi');
    return Card(
      child: ListTile(
        title: Text(item.product.name),
        subtitle: Text('Size: ${item.size} | Color: ${item.color}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${formatter.format(item.product.price)}đ'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove)),
                Text('${item.quantity}'),
                IconButton(onPressed: onIncrease, icon: const Icon(Icons.add)),
                IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
