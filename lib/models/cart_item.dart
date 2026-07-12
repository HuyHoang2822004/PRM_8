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

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'strap': strap,
      'color': color,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      strap: json['strap'] as String,
      color: json['color'] as String,
      quantity: json['quantity'] as int,
    );
  }
}
