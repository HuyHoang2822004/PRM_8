import '../models/cart_item.dart';

class CartService {
  double totalAmount(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.total);
  }
}
