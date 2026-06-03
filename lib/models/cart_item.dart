import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
  });

  final Product product;
  final int size;
  final String color;
  int quantity;

  double get total => quantity * product.price.toDouble();
}
