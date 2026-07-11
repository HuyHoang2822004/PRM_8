import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestoreInstance = firestore,
        _authInstance = auth;

  final FirebaseFirestore? _firestoreInstance;
  final FirebaseAuth? _authInstance;

  FirebaseFirestore get _firestore => _firestoreInstance ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _authInstance ?? FirebaseAuth.instance;

  Future<List<Order>> loadOrders(List<Product> allProducts) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Fetch orders for this specific authenticated user
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      final list = snapshot.docs.map((doc) {
        final jsonMap = doc.data();
        final itemsList = jsonMap['items'] as List<dynamic>? ?? [];
        
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
            strap: itemMap['strap'] as String? ?? 'Mặc định',
            color: itemMap['color'] as String? ?? 'Mặc định',
            quantity: itemMap['quantity'] as int? ?? 1,
          );
        }).toList();

        DateTime dt = DateTime.now();
        if (jsonMap['createdAt'] != null) {
          if (jsonMap['createdAt'] is Timestamp) {
            dt = (jsonMap['createdAt'] as Timestamp).toDate();
          } else {
            dt = DateTime.parse(jsonMap['createdAt'].toString());
          }
        }

        return Order(
          id: jsonMap['id'] as String? ?? doc.id,
          items: items,
          receiverName: jsonMap['receiverName'] as String? ?? '',
          phone: jsonMap['phone'] as String? ?? '',
          address: jsonMap['address'] as String? ?? '',
          paymentMethod: jsonMap['paymentMethod'] as String? ?? '',
          status: jsonMap['status'] as String? ?? 'Chờ duyệt',
          createdAt: dt,
        );
      }).toList();

      // Sort locally descending to avoid requiring composite indexes on Firestore
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<Order> createOrder(Order order) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    final batch = _firestore.batch();
    final orderRef = _firestore.collection('orders').doc(order.id);

    final orderMap = {
      'id': order.id,
      'userId': user.uid,
      'receiverName': order.receiverName,
      'phone': order.phone,
      'address': order.address,
      'paymentMethod': order.paymentMethod,
      'status': order.status,
      'createdAt': Timestamp.fromDate(order.createdAt),
      'items': order.items.map((item) => {
        'productId': item.product.id,
        'strap': item.strap,
        'color': item.color,
        'quantity': item.quantity,
      }).toList(),
    };

    batch.set(orderRef, orderMap);

    // Decrement stock for each product in order
    for (final item in order.items) {
      final productRef = _firestore.collection('products').doc(item.product.id.toString());
      batch.update(productRef, {
        'stock': FieldValue.increment(-item.quantity),
      });
    }

    await batch.commit();
    return order;
  }

  Future<List<Order>> loadAllOrders(List<Product> allProducts) async {
    try {
      final snapshot = await _firestore.collection('orders').get();

      final list = snapshot.docs.map((doc) {
        final jsonMap = doc.data();
        final itemsList = jsonMap['items'] as List<dynamic>? ?? [];
        
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
            strap: itemMap['strap'] as String? ?? 'Mặc định',
            color: itemMap['color'] as String? ?? 'Mặc định',
            quantity: itemMap['quantity'] as int? ?? 1,
          );
        }).toList();

        DateTime dt = DateTime.now();
        if (jsonMap['createdAt'] != null) {
          if (jsonMap['createdAt'] is Timestamp) {
            dt = (jsonMap['createdAt'] as Timestamp).toDate();
          } else {
            dt = DateTime.parse(jsonMap['createdAt'].toString());
          }
        }

        return Order(
          id: jsonMap['id'] as String? ?? doc.id,
          items: items,
          receiverName: jsonMap['receiverName'] as String? ?? '',
          phone: jsonMap['phone'] as String? ?? '',
          address: jsonMap['address'] as String? ?? '',
          paymentMethod: jsonMap['paymentMethod'] as String? ?? '',
          status: jsonMap['status'] as String? ?? 'Chờ duyệt',
          createdAt: dt,
        );
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final orderDoc = await _firestore.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) return;

    final currentStatus = orderDoc.data()?['status'] as String? ?? 'Chờ duyệt';
    final userId = orderDoc.data()?['userId'] as String? ?? '';
    
    final batch = _firestore.batch();
    batch.update(_firestore.collection('orders').doc(orderId), {
      'status': status,
    });

    // Write a notification to Firestore if status changed
    if (userId.isNotEmpty && currentStatus != status) {
      final notifRef = _firestore.collection('notifications').doc();
      String type = 'order_confirmed';
      String title = '📦 Đơn hàng đã được xác nhận';
      if (status == 'Đang giao') {
        type = 'order_shipping';
        title = '🚚 Đơn hàng đang được giao';
      } else if (status == 'Hoàn thành') {
        type = 'order_completed';
        title = '✅ Đơn hàng đã hoàn tất';
      } else if (status == 'Đã hủy') {
        type = 'order_completed';
        title = '❌ Đơn hàng đã bị hủy';
      }

      batch.set(notifRef, {
        'userId': userId,
        'title': title,
        'body': 'Đơn hàng $orderId của bạn đã chuyển sang trạng thái: $status.',
        'createdAt': Timestamp.now(),
        'type': type,
        'relatedId': orderId,
        'isRead': false,
      });
    }

    // If order is cancelled, restore stock
    if (status == 'Đã hủy' && currentStatus != 'Đã hủy') {
      final itemsList = orderDoc.data()?['items'] as List<dynamic>? ?? [];
      for (final itemMap in itemsList) {
        final pid = itemMap['productId'] as int;
        final qty = itemMap['quantity'] as int? ?? 1;
        final productRef = _firestore.collection('products').doc(pid.toString());
        batch.update(productRef, {
          'stock': FieldValue.increment(qty),
        });
      }
    }

    await batch.commit();
  }

  Stream<List<Order>> getOrdersStream(List<Product> allProducts) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final jsonMap = doc.data();
        final itemsList = jsonMap['items'] as List<dynamic>? ?? [];
        
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
            strap: itemMap['strap'] as String? ?? 'Mặc định',
            color: itemMap['color'] as String? ?? 'Mặc định',
            quantity: itemMap['quantity'] as int? ?? 1,
          );
        }).toList();

        DateTime dt = DateTime.now();
        if (jsonMap['createdAt'] != null) {
          if (jsonMap['createdAt'] is Timestamp) {
            dt = (jsonMap['createdAt'] as Timestamp).toDate();
          } else {
            dt = DateTime.parse(jsonMap['createdAt'].toString());
          }
        }

        return Order(
          id: jsonMap['id'] as String? ?? doc.id,
          items: items,
          receiverName: jsonMap['receiverName'] as String? ?? '',
          phone: jsonMap['phone'] as String? ?? '',
          address: jsonMap['address'] as String? ?? '',
          paymentMethod: jsonMap['paymentMethod'] as String? ?? '',
          status: jsonMap['status'] as String? ?? 'Chờ duyệt',
          createdAt: dt,
        );
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Order>> getAllOrdersStream(List<Product> allProducts) {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final jsonMap = doc.data();
        final itemsList = jsonMap['items'] as List<dynamic>? ?? [];
        
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
            strap: itemMap['strap'] as String? ?? 'Mặc định',
            color: itemMap['color'] as String? ?? 'Mặc định',
            quantity: itemMap['quantity'] as int? ?? 1,
          );
        }).toList();

        DateTime dt = DateTime.now();
        if (jsonMap['createdAt'] != null) {
          if (jsonMap['createdAt'] is Timestamp) {
            dt = (jsonMap['createdAt'] as Timestamp).toDate();
          } else {
            dt = DateTime.parse(jsonMap['createdAt'].toString());
          }
        }

        return Order(
          id: jsonMap['id'] as String? ?? doc.id,
          items: items,
          receiverName: jsonMap['receiverName'] as String? ?? '',
          phone: jsonMap['phone'] as String? ?? '',
          address: jsonMap['address'] as String? ?? '',
          paymentMethod: jsonMap['paymentMethod'] as String? ?? '',
          status: jsonMap['status'] as String? ?? 'Chờ duyệt',
          createdAt: dt,
        );
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
