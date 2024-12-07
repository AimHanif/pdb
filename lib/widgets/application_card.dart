// widgets/application_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'info_row.dart';
import 'format_date.dart';
import 'reusable_popup_menu.dart';
import '../colors.dart';

class ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> application;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ApplicationCard({
    Key? key,
    required this.application,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;

    switch (application['status'].toLowerCase()) {
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
            label: 'Position',
            valueWidget: Text(application['position'] ?? '-'),
          ),
          InfoRow(
            label: 'Company/Agency/Dept.',
            valueWidget: Text(application['company'] ?? '-'),
          ),
          InfoRow(
            label: 'Department',
            valueWidget: Text(application['department'] ?? '-'),
          ),
          InfoRow(
            label: 'Application Date',
            valueWidget: Text(_formatDate(application['applicationDate'])),
          ),
          InfoRow(
            label: 'Last Update Date',
            valueWidget: Text(_formatDate(application['latestUpdateDate'])),
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
          // If pending, show edit/delete options
          if (application['status'].toLowerCase() == 'pending')
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

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
