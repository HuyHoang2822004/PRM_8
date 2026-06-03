class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.sizes,
    required this.colors,
    required this.image,
    required this.description,
  });

  final int id;
  final String name;
  final String brand;
  final int price;
  final List<int> sizes;
  final List<String> colors;
  final String image;
  final String description;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: json['price'] as int,
      sizes: (json['sizes'] as List).map((e) => e as int).toList(),
      colors: (json['colors'] as List).map((e) => e as String).toList(),
      image: json['image'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}
