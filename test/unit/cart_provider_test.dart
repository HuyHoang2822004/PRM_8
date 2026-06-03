import 'package:flutter_test/flutter_test.dart';
import 'package:prm_8/models/product.dart';
import 'package:prm_8/providers/cart_provider.dart';

void main() {
  group('CartProvider', () {
    final product = Product(
      id: 1,
      name: 'Nike Air Force 1',
      brand: 'Nike',
      price: 2990000,
      sizes: const [40, 41, 42],
      colors: const ['White'],
      image: 'https://example.com/shoe.jpg',
      description: 'desc',
    );

    test('addToCart and totalAmount work correctly', () {
      final provider = CartProvider();

      provider.addToCart(product, size: 42, color: 'White');
      provider.addToCart(product, size: 42, color: 'White');

      expect(provider.items.length, 1);
      expect(provider.items.first.quantity, 2);
      expect(provider.totalAmount, 5980000);
    });
  });
}
