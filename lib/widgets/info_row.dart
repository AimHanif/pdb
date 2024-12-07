// widgets/info_row.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;

  const InfoRow({
    Key? key,
    required this.label,
    required this.valueWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: valueWidget,
          ),
        ],
      ),
    );
  }
}
