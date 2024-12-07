// widgets/custom_file_upload_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class CustomFileUploadButton extends StatelessWidget {
  final String label;
  final String? fileInfo;
  final VoidCallback onTap;
  final IconData iconData;
  final bool multiple;

  const CustomFileUploadButton({
    super.key,
    required this.label,
    this.fileInfo,
    required this.onTap,
    required this.iconData,
    this.multiple = false,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = fileInfo == null
        ? label
        : multiple
        ? '$label: $fileInfo files selected'
        : '$label: $fileInfo';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(iconData, color: AppColors.primary),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                displayText,
                style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary),
              ),
            ),
            const Icon(Icons.upload_file, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
