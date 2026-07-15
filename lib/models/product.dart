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
    this.images,
    this.customSpecs,
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
  final List<String>? images;
  final Map<String, String>? customSpecs;

  int get activePrice => salePrice ?? price;
  bool get hasDiscount => salePrice != null && salePrice! < price;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rootSpecs = json['customSpecs'] as Map<String, dynamic>? ?? {};
    
    // Resolve helper for finding fields either at root or nested in customSpecs
    dynamic getValue(String key) {
      return json[key] ?? rootSpecs[key];
    }

    final idVal = getValue('id');
    final nameVal = getValue('name')?.toString() ?? '';
    final brandVal = getValue('brand')?.toString() ?? '';
    final priceVal = getValue('price');
    final salePriceVal = getValue('salePrice');
    final imageVal = getValue('image')?.toString() ?? '';
    final descriptionVal = getValue('description')?.toString() ?? '';
    final strapMaterialVal = getValue('strapMaterial')?.toString() ?? '';
    final movementVal = getValue('movement')?.toString() ?? '';
    final waterResistanceVal = getValue('waterResistance')?.toString() ?? '';
    final warrantyVal = getValue('warranty')?.toString() ?? '';
    final stockVal = getValue('stock');
    
    // Parsers
    final int parsedId = idVal is int ? idVal : (idVal != null ? int.tryParse(idVal.toString()) ?? 0 : 0);
    final int parsedPrice = priceVal is int ? priceVal : (priceVal != null ? int.tryParse(priceVal.toString()) ?? 0 : 0);
    final int? parsedSalePrice = salePriceVal is int ? salePriceVal : (salePriceVal != null ? int.tryParse(salePriceVal.toString()) : null);
    final int parsedStock = stockVal is int ? stockVal : (stockVal != null ? int.tryParse(stockVal.toString()) ?? 0 : 0);

    final mainImage = imageVal;
    
    // Build custom specs map, excluding the main fields if they were nested
    final Map<String, String> cleanedCustomSpecs = {};
    rootSpecs.forEach((k, v) {
      if (!['id', 'name', 'brand', 'price', 'salePrice', 'image', 'description', 'strapMaterial', 'movement', 'waterResistance', 'warranty', 'stock', 'straps', 'colors', 'images'].contains(k)) {
        cleanedCustomSpecs[k] = v.toString();
      }
    });

    return Product(
      id: parsedId,
      name: nameVal,
      brand: brandVal,
      price: parsedPrice,
      salePrice: parsedSalePrice,
      image: mainImage,
      description: descriptionVal,
      strapMaterial: strapMaterialVal,
      movement: movementVal,
      waterResistance: waterResistanceVal,
      warranty: warrantyVal,
      stock: parsedStock,
      straps: (json['straps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? 
              (rootSpecs['straps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      colors: (json['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? 
              (rootSpecs['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? 
              (rootSpecs['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [mainImage],
      customSpecs: cleanedCustomSpecs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'salePrice': salePrice,
      'image': image,
      'description': description,
      'strapMaterial': strapMaterial,
      'movement': movement,
      'waterResistance': waterResistance,
      'warranty': warranty,
      'stock': stock,
      'straps': straps,
      'colors': colors,
      'images': images ?? [image],
      'customSpecs': customSpecs ?? {},
    };
  }
}
