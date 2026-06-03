import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int? selectedSize;
  String? selectedColor;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.product.sizes.first;
    selectedColor = widget.product.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('vi');
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: PageView(
                children: [
                  Image.network(widget.product.image, fit: BoxFit.cover),
                  Image.network(widget.product.image, fit: BoxFit.cover),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.product.name, style: Theme.of(context).textTheme.titleLarge),
            Text('${formatter.format(widget.product.price)}đ'),
            const SizedBox(height: 12),
            const Text('Size:'),
            Wrap(
              spacing: 8,
              children: widget.product.sizes
                  .map(
                    (size) => ChoiceChip(
                      label: Text('$size'),
                      selected: selectedSize == size,
                      onSelected: (_) => setState(() => selectedSize = size),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text('Color:'),
            Wrap(
              spacing: 8,
              children: widget.product.colors
                  .map(
                    (color) => ChoiceChip(
                      label: Text(color),
                      selected: selectedColor == color,
                      onSelected: (_) => setState(() => selectedColor = color),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text('Quantity:'),
            Row(
              children: [
                IconButton(
                  onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$quantity'),
                IconButton(
                  onPressed: () => setState(() => quantity++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.product.description),
            const SizedBox(height: 16),
            CustomButton(
              onPressed: () {
                final cart = context.read<CartProvider>();
                cart.addToCart(
                  widget.product,
                  size: selectedSize!,
                  color: selectedColor!,
                  quantity: quantity,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart')),
                );
              },
              label: 'Add To Cart',
            ),
          ],
        ),
      ),
    );
  }
}
