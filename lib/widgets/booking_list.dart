// widgets/booking_list.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdb/widgets/booking_card.dart';
import '../colors.dart';

class BookingList extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const BookingList({
    super.key,
    required this.bookings,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Bookings 🏟',
            style: GoogleFonts.poppins(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16.0),
          ...bookings.asMap().entries.map((entry) {
            final index = entry.key;
            final booking = entry.value;
            return BookingCard(
              booking: booking,
              index: index,
              onEdit: () => onEdit(index),
              onDelete: () => onDelete(index),
            );
          }).toList(),
        ],
      ),
    );
  }
}
