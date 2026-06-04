import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedStrap;
  String? selectedColor;
  int quantity = 1;
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.product.straps.isNotEmpty) {
      selectedStrap = widget.product.straps.first;
    }
    if (widget.product.colors.isNotEmpty) {
      selectedColor = widget.product.colors.first;
    }
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    cart.addToCart(
      widget.product,
      strap: selectedStrap ?? 'Mặc định',
      color: selectedColor ?? 'Mặc định',
      quantity: quantity,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm $quantity chiếc ${widget.product.name} vào giỏ hàng!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('vi');
    final isOutOfStock = widget.product.stock == 0;
    
    // Technical specifications list
    final specs = [
      {'label': 'Thương hiệu', 'value': widget.product.brand},
      {'label': 'Bộ máy hoạt động', 'value': widget.product.movement},
      {'label': 'Chất liệu dây đeo', 'value': widget.product.strapMaterial},
      {'label': 'Độ chống nước', 'value': widget.product.waterResistance},
      {'label': 'Chế độ bảo hành', 'value': widget.product.warranty},
      {'label': 'Trạng thái', 'value': isOutOfStock ? 'Hết hàng' : 'Còn hàng (${widget.product.stock} chiếc)'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CHI TIẾT SẢN PHẨM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Area
            Container(
              color: Colors.white,
              height: 320,
              width: double.infinity,
              child: Stack(
                children: [
                  PageView.builder(
                    onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      final imageWidget = CachedNetworkImage(
                        imageUrl: widget.product.image,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                        errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, size: 64),
                      );
                      
                      if (index == 0) {
                        return Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: imageWidget,
                          ),
                        );
                      }
                      return imageWidget;
                    },
                  ),
                  // Page Indicators
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        2,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _activeImageIndex == index
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            
            // Product Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.brand.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Price Tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${formatter.format(widget.product.activePrice)}đ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (widget.product.hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${formatter.format(widget.product.price)}đ',
                          style: AppTextStyles.priceDiscount.copyWith(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'GIỚI THIỆU SẢN PHẨM',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                  ),
                  
                  // Strap Variant Selector
                  if (widget.product.straps.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'CHỌN LOẠI DÂY ĐEO',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.straps.map((strap) {
                        final isSelected = selectedStrap == strap;
                        return ChoiceChip(
                          label: Text(strap),
                          selected: isSelected,
                          onSelected: (_) => setState(() => selectedStrap = strap),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // Color Variant Selector
                  if (widget.product.colors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'CHỌN MÀU SẮC VỎ / MẶT',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.colors.map((color) {
                        final isSelected = selectedColor == color;
                        return ChoiceChip(
                          label: Text(color),
                          selected: isSelected,
                          onSelected: (_) => setState(() => selectedColor = color),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // Quantity
                  const SizedBox(height: 20),
                  const Text(
                    'SỐ LƯỢNG MUA',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: quantity > 1 && !isOutOfStock
                                  ? () => setState(() => quantity--)
                                  : null,
                              icon: const Icon(Icons.remove, size: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            IconButton(
                              onPressed: !isOutOfStock && quantity < widget.product.stock
                                  ? () => setState(() => quantity++)
                                  : null,
                              icon: const Icon(Icons.add, size: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!isOutOfStock)
                        Text(
                          'Còn lại ${widget.product.stock} sản phẩm',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                  
                  // Specs Table
                  const SizedBox(height: 28),
                  const Text(
                    'THÔNG SỐ KỸ THUẬT',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Table(
                      border: TableBorder.all(color: AppColors.border, width: 1, borderRadius: BorderRadius.circular(4)),
                      columnWidths: const {
                        0: FixedColumnWidth(130),
                        1: FlexColumnWidth(),
                      },
                      children: specs.map((spec) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: specs.indexOf(spec) % 2 == 0 ? Colors.white : Colors.grey.shade50,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                spec['label']!,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                spec['value']!,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  // Buy Button
                  CustomButton(
                    onPressed: isOutOfStock ? null : _addToCart,
                    label: isOutOfStock ? 'HẾT HÀNG TẠM THỜI' : 'THÊM VÀO GIỎ HÀNG',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
