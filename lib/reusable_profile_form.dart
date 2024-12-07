import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'profile_config.dart';
import 'package:intl/intl.dart';

typedef SaveCallback = void Function(String key, String value);

class ReusableProfileForm extends StatefulWidget {
  final List<FieldDefinition> fields;
  final Map<String, TextEditingController> controllers;
  final SaveCallback onSave;

  const ReusableProfileForm({
    Key? key,
    required this.fields,
    required this.controllers,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ReusableProfileForm> createState() => _ReusableProfileFormState();
}

class _ReusableProfileFormState extends State<ReusableProfileForm> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _showDateTimePicker(FieldDefinition fieldDef) async {
    final currentValue = widget.controllers[fieldDef.key]?.text ?? '';
    DateTime initialDate = DateTime.now();

    if (currentValue.isNotEmpty) {
      final datePart = currentValue.split('/');
      if (datePart.length == 3) {
        final day = int.tryParse(datePart[0]) ?? DateTime.now().day;
        final month = int.tryParse(datePart[1]) ?? DateTime.now().month;
        final year = int.tryParse(datePart[2]) ?? DateTime.now().year;
        initialDate = DateTime(year, month, day);
      }
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate == null) return;

    final formatted = DateFormat('d/M/yyyy').format(selectedDate); // Only date
    widget.controllers[fieldDef.key]?.text = formatted;
    widget.onSave(fieldDef.key, formatted);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: widget.fields.map((fieldDef) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: _buildField(fieldDef),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildField(FieldDefinition fieldDef) {
    final controller = widget.controllers[fieldDef.key]!;

    final inputDecoration = InputDecoration(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide:
        BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide:
        BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
      ),
      hintText: fieldDef.label,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14.0,
        color: AppColors.textSecondary.withOpacity(0.8),
      ),
    );

    if (fieldDef.type == FieldType.dropdown && fieldDef.options != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldDef.label,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            value: controller.text.isEmpty ? null : controller.text,
            decoration: inputDecoration,
            validator: fieldDef.validator,
            onChanged: (value) {
              if (value != null) {
                controller.text = value;
                widget.onSave(fieldDef.key, value);
              }
            },
            items: fieldDef.options!
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
          ),
        ],
      );
    }

    if (fieldDef.type == FieldType.date) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldDef.label,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          InkWell(
            onTap: () => _showDateTimePicker(fieldDef),
            child: IgnorePointer(
              child: TextFormField(
                controller: controller,
                validator: fieldDef.validator,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  color: AppColors.textPrimary,
                ),
                decoration: inputDecoration.copyWith(
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final keyboardType = (fieldDef.type == FieldType.number)
        ? TextInputType.number
        : TextInputType.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldDef.label,
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          validator: fieldDef.validator,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            color: AppColors.textPrimary,
          ),
          onChanged: (value) {
            widget.onSave(fieldDef.key, value);
            if (_formKey.currentState != null) {
              _formKey.currentState!.validate();
            }
          },
          decoration: inputDecoration,
        ),
      ],
    );
  }
}
