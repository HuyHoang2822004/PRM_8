import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class StrapSelector extends StatelessWidget {
  final List<String> straps;
  final String? selectedStrap;
  final ValueChanged<String> onSelected;

  const StrapSelector({
    super.key,
    required this.straps,
    required this.selectedStrap,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (straps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          AppStrings.strapVariant,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: straps.map((strap) {
            final isSelected = selectedStrap == strap;
            return ChoiceChip(
              label: Text(strap),
              selected: isSelected,
              onSelected: (_) => onSelected(strap),
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
    );
  }
}
