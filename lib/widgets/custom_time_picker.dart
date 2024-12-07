// widgets/custom_time_picker.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class CustomTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeSelected;

  const CustomTimePicker({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = selectedTime ?? TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null && picked != selectedTime) {
      onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayTime = selectedTime != null
        ? selectedTime!.format(context)
        : 'Pilih Masa Tempahan';

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
        InkWell(
          onTap: () => _selectTime(context),
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
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    displayTime,
                    style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
