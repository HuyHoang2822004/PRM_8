import 'package:flutter_test/flutter_test.dart';
import 'package:prm_8/models/product.dart';
import 'package:prm_8/providers/cart_provider.dart';

void main() {
  group('CartProvider', () {
    final product = Product(
      id: 1,
      name: 'Rolex Submariner Date',
      brand: 'Rolex',
      price: 350000000,
      salePrice: 345000000,
      image: 'https://example.com/watch.jpg',
      description: 'desc',
      strapMaterial: 'Oystersteel',
      movement: 'Automatic (3235)',
      waterResistance: '30ATM',
      warranty: '5 Years',
      stock: 2,
      straps: const ['Oystersteel', 'Rubber B'],
      colors: const ['Green', 'Black'],
    );

    test('addToCart and totalAmount work correctly with watch activePrice', () {
      final provider = CartProvider();

      provider.addToCart(product, strap: 'Oystersteel', color: 'Black');
      provider.addToCart(product, strap: 'Oystersteel', color: 'Black');

      expect(provider.items.length, 1);
      expect(provider.items.first.quantity, 2);
      expect(provider.totalAmount, 690000000); // 2 * 345,000,000 activePrice (salePrice)
    });
  });
}
