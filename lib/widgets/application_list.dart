import 'package:flutter/material.dart';
import 'application_card.dart';

class ApplicationList extends StatelessWidget {
  final List<Map<String, dynamic>> applications;
  final List<Map<String, String>> fieldConfigurations;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const ApplicationList({
    super.key,
    required this.applications,
    required this.fieldConfigurations,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: applications.asMap().entries.map((entry) {
          final index = entry.key;
          final app = entry.value;

          final fields = fieldConfigurations.map((config) {
            return {
              'label': config['label']!,
              'value': app[config['key']]?.toString(),
            };
          }).toList();

          return ApplicationCard(
            fields: fields,
            status: app['status'] ?? 'Pending',
            onEdit: () => onEdit(index),
            onDelete: () => onDelete(index),
          );
        }).toList(),
      ),
    );
  }
}
