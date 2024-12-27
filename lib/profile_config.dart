// profile_config.dart

import 'package:flutter/material.dart';

enum FieldType {
  text,
  dropdown,
  date,
  number,
}

class FieldDefinition {
  final String key;
  final String label;
  final FieldType type;
  final List<String>? options;
  final String? Function(String?)? validator;

  FieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.validator,
  });
}

// Validation Helpers
String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
  if (RegExp(r'\d').hasMatch(value)) return 'Nama tidak boleh mengandungi nombor';
  return null;
}

String? validateIDNumber(String? value) {
  if (value == null || value.isEmpty) return 'No. Kad Pengenalan diperlukan';
  if (!RegExp(r'^\d{12}$').hasMatch(value)) return 'No. Kad Pengenalan tidak sah (12 digit)';
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) return 'No. Telefon diperlukan';
  if (!RegExp(r'^\d+$').hasMatch(value)) return 'No. Telefon hanya nombor sahaja';
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Emel diperlukan';
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return 'Emel tidak sah';
  return null;
}

String? validateAge(String? value) {
  if (value == null || value.isEmpty) return 'Umur diperlukan';
  if (int.tryParse(value) == null) return 'Umur mesti nombor';
  return null;
}

String? validateNotEmpty(String? value) {
  if (value == null || value.trim().isEmpty) return 'Medan ini diperlukan';
  return null;
}

String? validateGender(String? value) {
  if (value == null || value.isEmpty) return 'Sila pilih jantina';
  return null;
}

String? validateCGPA(String? value) {
  if (value == null || value.isEmpty) return 'CGPA diperlukan';
  if (double.tryParse(value) == null) return 'CGPA mesti nombor';
  if (double.parse(value) < 0 || double.parse(value) > 4.0) return 'CGPA mesti antara 0 hingga 4.0';
  return null;
}

// Personal Fields
List<FieldDefinition> personalFields = [
  FieldDefinition(key: 'fullName', label: 'Nama Penuh', type: FieldType.text, validator: validateName),
  FieldDefinition(key: 'idNumber', label: 'No. Kad Pengenalan', type: FieldType.text, validator: validateIDNumber),
  FieldDefinition(key: 'phoneNumber', label: 'No. Telefon Bimbit', type: FieldType.text, validator: validatePhoneNumber),
  FieldDefinition(key: 'email', label: 'Alamat E-Mel', type: FieldType.text, validator: validateEmail),
  FieldDefinition(key: 'birthDate', label: 'Tarikh Lahir', type: FieldType.date, validator: validateNotEmpty),
  FieldDefinition(key: 'age', label: 'Umur', type: FieldType.number, validator: validateAge),
  FieldDefinition(key: 'birthPlace', label: 'Tempat Lahir', type: FieldType.text, validator: validateNotEmpty),
  FieldDefinition(
    key: 'gender',
    label: 'Jantina',
    type: FieldType.dropdown,
    options: ['LELAKI', 'PEREMPUAN'],
    validator: validateGender,
  ),
  FieldDefinition(
    key: 'status',
    label: 'Status Diri',
    type: FieldType.dropdown,
    options: ['Bujang', 'Berkahwin', 'Janda', 'Duda'],
    validator: validateNotEmpty,
  ),
];

// Family Fields
List<FieldDefinition> familyFields = [
  FieldDefinition(key: 'spouseName', label: 'Nama Suami/Isteri', type: FieldType.text, validator: validateName),
  FieldDefinition(key: 'spouseJob', label: 'Pekerjaan Suami/Isteri', type: FieldType.text, validator: validateNotEmpty),
  FieldDefinition(key: 'spouseIncome', label: 'Pendapatan Suami/Isteri (RM)', type: FieldType.number, validator: validateNotEmpty),
  FieldDefinition(key: 'fatherName', label: 'Nama Bapa', type: FieldType.text, validator: validateName),
  FieldDefinition(key: 'motherName', label: 'Nama Ibu', type: FieldType.text, validator: validateName),
  FieldDefinition(key: 'fatherID', label: 'No. Kad Pengenalan Bapa', type: FieldType.text, validator: validateIDNumber),
  FieldDefinition(key: 'motherID', label: 'No. Kad Pengenalan Ibu', type: FieldType.text, validator: validateIDNumber),
  FieldDefinition(key: 'fatherBirthPlace', label: 'Tempat Lahir Bapa', type: FieldType.text, validator: validateNotEmpty),
  FieldDefinition(key: 'motherBirthPlace', label: 'Tempat Lahir Ibu', type: FieldType.text, validator: validateNotEmpty),
  FieldDefinition(key: 'fatherJob', label: 'Pekerjaan Bapa', type: FieldType.text, validator: validateNotEmpty),
  FieldDefinition(key: 'motherJob', label: 'Pekerjaan Ibu', type: FieldType.text, validator: validateNotEmpty),
  FieldDefinition(key: 'familyMembers', label: 'Bilangan Ahli Keluarga', type: FieldType.number, validator: validateNotEmpty),
  FieldDefinition(key: 'siblingOrder', label: 'Anak Ke-', type: FieldType.text, validator: validateNotEmpty),
];

// Academics Fields
List<FieldDefinition> academicsFields = [
  FieldDefinition(key: 'pt3Year', label: 'Tahun (PT3)', type: FieldType.number, validator: validateNotEmpty),
  FieldDefinition(key: 'pt3Exam', label: 'Peperiksaan (PT3)', type: FieldType.text, validator: validateNotEmpty),
  FieldDefinition(key: 'spmYear', label: 'Tahun (SPM)', type: FieldType.number, validator: validateNotEmpty),
  FieldDefinition(key: 'spmCertificateType', label: 'Keputusan (SPM)', type: FieldType.text, validator: validateNotEmpty),
  FieldDefinition(key: 'matriculationCGPA', label: 'CGPA (Matrikulasi)', type: FieldType.number, validator: validateCGPA),
  FieldDefinition(key: 'higherEducationField', label: 'Bidang Pengajian (HE)', type: FieldType.text, validator: validateNotEmpty),
  FieldDefinition(key: 'higherEducationCGPA', label: 'CGPA (HE)', type: FieldType.number, validator: validateCGPA),
];


//SPM and PT3 should ask berapa A kita dapat, tanya juga nasal jenis sijil SKM dan tahun bila data, kita juga boleh