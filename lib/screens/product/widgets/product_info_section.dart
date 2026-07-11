import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';

class ProductInfoSection extends StatelessWidget {
  final String brand;
  final String name;
  final int price;
  final int? salePrice;
  final String description;

  const ProductInfoSection({
    super.key,
    required this.brand,
    required this.name,
    required this.price,
    this.salePrice,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('vi');
    final hasDiscount = salePrice != null && salePrice! < price;
    final activePrice = salePrice ?? price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          brand.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${formatter.format(activePrice)}đ',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 8),
              Text(
                '${formatter.format(price)}đ',
                style: AppTextStyles.priceDiscount.copyWith(fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '-${((price - salePrice!) / price * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          AppStrings.productIntro,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
