import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class SpecsTable extends StatelessWidget {
  final String brand;
  final String movement;
  final String strapMaterial;
  final String waterResistance;
  final String warranty;
  final int stock;
  final List<String>? colors;
  final List<String>? straps;
  final Map<String, String>? customSpecs;

  const SpecsTable({
    super.key,
    required this.brand,
    required this.movement,
    required this.strapMaterial,
    required this.waterResistance,
    required this.warranty,
    required this.stock,
    this.colors,
    this.straps,
    this.customSpecs,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = stock == 0;
    final activeColors = colors;
    final activeStraps = straps;
    
    final specs = [
      {'label': AppStrings.specsBrand, 'value': brand},
      {'label': AppStrings.specsMovement, 'value': movement},
      {'label': AppStrings.specsStrap, 'value': strapMaterial},
      if (activeStraps != null && activeStraps.isNotEmpty)
        {'label': 'Loại dây đeo', 'value': activeStraps.join(', ')},
      if (activeColors != null && activeColors.isNotEmpty)
        {'label': 'Màu sắc', 'value': activeColors.join(', ')},
      {'label': AppStrings.specsWater, 'value': waterResistance},
      {'label': AppStrings.specsWarranty, 'value': warranty},
      {
        'label': AppStrings.specsStatus,
        'value': isOutOfStock ? AppStrings.outOfStockText : '${AppStrings.inStockText} ($stock chiếc)'
      },
    ];

    if (customSpecs != null) {
      customSpecs!.forEach((key, val) {
        specs.add({'label': key, 'value': val});
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const Text(
          AppStrings.specsTitle,
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
            border: TableBorder.all(
              color: AppColors.border,
              width: 1,
              borderRadius: BorderRadius.circular(4),
            ),
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      spec['value']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
