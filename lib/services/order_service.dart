import '../models/order.dart';

class OrderService {
  Future<Order> createOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return order;
  }
}
