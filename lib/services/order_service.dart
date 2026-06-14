import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class OrderService {
  static const _ordersKey = 'chrono_orders';

  Future<List<Order>> loadOrders(List<Product> allProducts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_ordersKey);
    if (jsonStr == null) return [];
    
    try {
      final list = json.decode(jsonStr) as List<dynamic>;
      return list.map((jsonMap) {
        final itemsList = jsonMap['items'] as List<dynamic>;
        final items = itemsList.map((itemMap) {
          final pid = itemMap['productId'] as int;
          final prod = allProducts.firstWhere(
            (p) => p.id == pid,
            orElse: () => Product(
              id: pid,
              name: 'Sản phẩm đã gỡ bỏ',
              brand: 'Unknown',
              price: 0,
              image: '',
              description: '',
              strapMaterial: '',
              movement: '',
              waterResistance: '',
              warranty: '',
              stock: 0,
              straps: [],
              colors: [],
            ),
          );
          return CartItem(
            product: prod,
            strap: itemMap['strap'] as String,
            color: itemMap['color'] as String,
            quantity: itemMap['quantity'] as int,
          );
        }).toList();

        return Order(
          id: jsonMap['id'] as String,
          items: items,
          receiverName: jsonMap['receiverName'] as String,
          phone: jsonMap['phone'] as String,
          address: jsonMap['address'] as String,
          paymentMethod: jsonMap['paymentMethod'] as String,
          status: jsonMap['status'] as String? ?? 'Chờ duyệt',
          createdAt: DateTime.parse(jsonMap['createdAt'] as String),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Order> createOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_ordersKey);
    final List<dynamic> list = jsonStr != null ? json.decode(jsonStr) as List<dynamic> : [];
    
    final orderMap = {
      'id': order.id,
      'receiverName': order.receiverName,
      'phone': order.phone,
      'address': order.address,
      'paymentMethod': order.paymentMethod,
      'status': order.status,
      'createdAt': order.createdAt.toIso8601String(),
      'items': order.items.map((item) => {
        'productId': item.product.id,
        'strap': item.strap,
        'color': item.color,
        'quantity': item.quantity,
      }).toList(),
    };
    
    list.insert(0, orderMap);
    await prefs.setString(_ordersKey, json.encode(list));
    return order;
  }
}
