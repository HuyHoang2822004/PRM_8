import 'cart_item.dart';

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.receiverName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
  });

  final String id;
  final List<CartItem> items;
  final String receiverName;
  final String phone;
  final String address;
  final String paymentMethod;
}
