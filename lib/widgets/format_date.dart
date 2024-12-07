// widgets/format_date.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../colors.dart';

class FormatDate extends StatelessWidget {
  final DateTime date;
  final String format;

  const FormatDate({
    super.key,
    required this.date,
    this.format = 'yyyy-MM-dd',
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(format).format(date);
    return Text(
      formattedDate,
      style: GoogleFonts.poppins(
        fontSize: 14.0,
        color: AppColors.textPrimary,
      ),
    );
  }
}
