// widgets/application_list.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';
import 'application_card.dart';

class ApplicationList extends StatelessWidget {
  final List<Map<String, dynamic>> applications;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const ApplicationList({
    Key? key,
    required this.applications,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Applications 🗃',
            style: GoogleFonts.poppins(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16.0),
          ...applications.asMap().entries.map((entry) {
            final index = entry.key;
            final app = entry.value;
            return ApplicationCard(
              application: app,
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
