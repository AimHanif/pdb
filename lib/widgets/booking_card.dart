// widgets/booking_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'info_row.dart';
import 'format_date.dart';
import 'reusable_popup_menu.dart';
import '../colors.dart';

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookingCard({
    Key? key,
    required this.booking,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;

    switch (booking['status'].toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Approved ✅';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected ❌';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pending ⌛';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            label: 'Kemudahan',
            valueWidget: Text(booking['selectedFacility'] ?? '-'),
          ),
          InfoRow(
            label: 'Tarikh Tempahan',
            valueWidget: Text(
              booking['bookingDate'] != null
                  ? DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['bookingDate']))
                  : '-',
            ),
          ),
          InfoRow(
            label: 'Masa Tempahan',
            valueWidget: Text(booking['bookingTime'] ?? '-'),
          ),
          InfoRow(
            label: 'Lokasi',
            valueWidget: Text(booking['selectedLokasi'] ?? '-'),
          ),
          InfoRow(
            label: 'Booking Date',
            valueWidget: booking['bookingDateTime'] != null
                ? FormatDate(date: DateTime.parse(booking['bookingDateTime'].toString()))
                : Text('-'),
          ),
          Row(
            children: [
              Text(
                'Status: ',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                statusText,
                style: GoogleFonts.poppins(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (booking['status'] == 'Pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ReusablePopupMenu(
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
