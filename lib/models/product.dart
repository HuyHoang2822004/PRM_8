class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.salePrice,
    required this.image,
    required this.description,
    required this.strapMaterial,
    required this.movement,
    required this.waterResistance,
    required this.warranty,
    required this.stock,
    required this.straps,
    required this.colors,
  });

  final int id;
  final String name;
  final String brand;
  final int price;
  final int? salePrice;
  final String image;
  final String description;
  final String strapMaterial;
  final String movement;
  final String waterResistance;
  final String warranty;
  final int stock;
  final List<String> straps;
  final List<String> colors;

  int get activePrice => salePrice ?? price;
  bool get hasDiscount => salePrice != null && salePrice! < price;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: json['price'] as int,
      salePrice: json['salePrice'] as int?,
      image: json['image'] as String,
      description: json['description'] as String? ?? '',
      strapMaterial: json['strapMaterial'] as String? ?? '',
      movement: json['movement'] as String? ?? '',
      waterResistance: json['waterResistance'] as String? ?? '',
      warranty: json['warranty'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      straps: (json['straps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      colors: (json['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
