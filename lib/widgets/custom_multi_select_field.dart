// widgets/custom_multi_select_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class CustomMultiSelectField extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>> onSelectionChanged;

  const CustomMultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: GoogleFonts.poppins(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newSelectedOptions = List<String>.from(selectedOptions);
                if (selected) {
                  newSelectedOptions.add(option);
                } else {
                  newSelectedOptions.remove(option);
                }
                onSelectionChanged(newSelectedOptions);
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              backgroundColor: AppColors.background,
              checkmarkColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
