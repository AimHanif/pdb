import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    required this.onChanged,
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
        Container(
          width: double.infinity, // Ensure the dropdown takes up the full width
          decoration: BoxDecoration(
            color: Colors.white, // White background for better contrast
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonFormField<String>(
            isExpanded: true, // Ensure dropdown content takes up all available width
            value: items.contains(value) ? value : null, // Reset value if invalid
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            style: GoogleFonts.poppins(
              fontSize: 14.0,
              color: AppColors.textPrimary,
            ),
            hint: Text(
              'Pilih $label',
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis, // Handle overflow gracefully
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
