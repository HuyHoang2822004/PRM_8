import 'cart_item.dart';

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.receiverName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    this.status = 'Chờ duyệt',
    required this.createdAt,
  });

  final String id;
  final List<CartItem> items;
  final String receiverName;
  final String phone;
  final String address;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.total);
}
