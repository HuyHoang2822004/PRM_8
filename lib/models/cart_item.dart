import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.strap,
    required this.color,
    this.quantity = 1,
  });

  final Product product;
  final String strap;
  final String color;
  int quantity;

  double get total => quantity * product.activePrice.toDouble();
}
