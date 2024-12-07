// widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final TextInputType keyboardType;
  final bool isReadOnly;

  const CustomTextField({
    Key? key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.isReadOnly = false,
  }) : super(key: key);

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
        TextField(
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          controller: TextEditingController(text: initialValue),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            hintText: 'Enter $label',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14.0,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
