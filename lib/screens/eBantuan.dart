// screens/e_bantuan_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import '../navbar.dart';
import '../colors.dart';

// Import the custom widgets
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_file_upload_button.dart';
import '../widgets/format_date.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/application_list.dart';

class EBantuanScreen extends StatefulWidget {
  const EBantuanScreen({Key? key}) : super(key: key);

  @override
  State<EBantuanScreen> createState() => _EBantuanScreenState();
}

class _EBantuanScreenState extends State<EBantuanScreen> {
  int _selectedIndex = 0;
  late Box eBantuanBox;
  bool isBoxReady = false;

  List<Map<String, dynamic>> applications = [];

  String? applicantName; // Nama Pemohon
  String? applicantIC; // Nombor Kad Pengenalan
  String? assistanceType; // Jenis Bantuan
  String? householdIncome; // Pendapatan Isi Rumah
  String? dependentsCount; // Bilangan Tanggungan
  String? employmentStatus; // Status Pekerjaan
  String? assistanceReason; // Sebab Permohonan
  String? documentsPath; // Dokumen Sokongan

  final List<String> assistanceOptions = [
    'Bantuan Kewangan',
    'Bantuan Makanan',
    'Bantuan Pendidikan',
    'Bantuan Kesihatan'
  ];
  final List<String> employmentOptions = ['Bekerja', 'Menganggur', 'Berniaga Sendiri'];

  bool isEditing = false;
  bool isCreating = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _initHiveData();
  }

  Future<void> _initHiveData() async {
    if (!Hive.isBoxOpen('eBantuanData')) {
      await Hive.openBox('eBantuanData');
    }
    eBantuanBox = Hive.box('eBantuanData');
    _loadApplications();
    setState(() {
      isBoxReady = true;
    });
  }

  void _loadApplications() {
    final storedApps = eBantuanBox.get('applications', defaultValue: []);
    if (storedApps is List) {
      applications = storedApps
          .where((app) => app is Map)
          .map((app) => Map<String, dynamic>.from(app as Map))
          .toList();
    } else {
      applications = [];
    }
  }

  void _saveApplications() {
    eBantuanBox.put(
      'applications',
      applications.map((app) => Map<String, dynamic>.from(app)).toList(),
    );
  }

  void _submitApplication() {
    if (applicantName == null ||
        applicantIC == null ||
        assistanceType == null ||
        householdIncome == null ||
        dependentsCount == null ||
        employmentStatus == null ||
        assistanceReason == null ||
        applicantName!.isEmpty ||
        applicantIC!.isEmpty ||
        householdIncome!.isEmpty ||
        dependentsCount!.isEmpty ||
        assistanceReason!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sila lengkapkan semua maklumat yang diperlukan sebelum meneruskan.')),
      );
      return;
    }

    final newApplication = {
      'applicantName': applicantName,
      'applicantIC': applicantIC,
      'assistanceType': assistanceType,
      'householdIncome': householdIncome,
      'dependentsCount': dependentsCount,
      'employmentStatus': employmentStatus,
      'assistanceReason': assistanceReason,
      'documentsPath': documentsPath,
      'status': 'Pending',
      'applicationDate': DateTime.now(),
      'latestUpdateDate': DateTime.now(),
    };

    if (isEditing && editingIndex != null) {
      final app = applications[editingIndex!];
      if (app['status'] != 'Pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can only edit pending applications.')),
        );
        return;
      }
      applications[editingIndex!] = newApplication;
    } else {
      applications.add(newApplication);
    }

    _saveApplications();
    _resetForm();
    setState(() {
      isCreating = false;
      isEditing = false;
    });
  }

  void _resetForm() {
    applicantName = null;
    applicantIC = null;
    assistanceType = null;
    householdIncome = null;
    dependentsCount = null;
    employmentStatus = null;
    assistanceReason = null;
    documentsPath = null;
    isEditing = false;
    editingIndex = null;
  }

  void _refreshStatus() {
    _loadApplications();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All statuses refreshed!')),
    );
    setState(() {});
  }

  void _deleteApplication(int index) {
    applications.removeAt(index);
    _saveApplications();
    setState(() {});
  }

  void _editApplication(int index) {
    final app = applications[index];
    if (app['status'] != 'Pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only edit pending applications.')),
      );
      return;
    }
    applicantName = app['applicantName'];
    applicantIC = app['applicantIC'];
    assistanceType = app['assistanceType'];
    householdIncome = app['householdIncome'];
    dependentsCount = app['dependentsCount'];
    employmentStatus = app['employmentStatus'];
    assistanceReason = app['assistanceReason'];
    documentsPath = app['documentsPath'];
    isEditing = true;
    isCreating = false;
    editingIndex = index;
    setState(() {});
  }

  void _startCreating() {
    _resetForm();
    isCreating = true;
    isEditing = false;
    setState(() {});
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      documentsPath = result.files.single.path;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _onWillPop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'e-Bantuan',
          onLeadingPressed: () {
            Navigator.pop(context);
          },
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _buildContent(),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isCreating || isEditing || applications.isEmpty) {
      return _buildApplicationFormWidget();
    }
    return Stack(
      children: [
        ApplicationList(
          applications: applications,
          onEdit: _editApplication,
          onDelete: _deleteApplication,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startCreating,
                    icon: Icon(Icons.add, size: 18.0, color: AppColors.textPrimary),
                    label: Text(
                      'Add Application',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshStatus,
                    icon: Icon(Icons.refresh, size: 18.0, color: AppColors.textPrimary),
                    label: Text(
                      'Refresh Status',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationFormWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
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
            Text(
              isEditing ? 'Edit Your Application 🗒' : 'Submit Your Application 🗒',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for Nama Pemohon
            CustomTextField(
              label: 'Nama Pemohon',
              initialValue: applicantName,
              onChanged: (val) => setState(() => applicantName = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for Nombor Kad Pengenalan
            CustomTextField(
              label: 'Nombor Kad Pengenalan',
              initialValue: applicantIC,
              onChanged: (val) => setState(() => applicantIC = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Jenis Bantuan
            CustomDropdown(
              label: 'Jenis Bantuan',
              items: assistanceOptions,
              value: assistanceType,
              onChanged: (val) => setState(() => assistanceType = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for Pendapatan Isi Rumah
            CustomTextField(
              label: 'Pendapatan Isi Rumah',
              initialValue: householdIncome,
              onChanged: (val) => setState(() => householdIncome = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for Bilangan Tanggungan
            CustomTextField(
              label: 'Bilangan Tanggungan',
              initialValue: dependentsCount,
              onChanged: (val) => setState(() => dependentsCount = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Status Pekerjaan
            CustomDropdown(
              label: 'Status Pekerjaan',
              items: employmentOptions,
              value: employmentStatus,
              onChanged: (val) => setState(() => employmentStatus = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for Sebab Permohonan
            CustomTextField(
              label: 'Sebab Permohonan',
              initialValue: assistanceReason,
              onChanged: (val) => setState(() => assistanceReason = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomFileUploadButton for Dokumen Sokongan
            CustomFileUploadButton(
              label: 'Dokumen Sokongan',
              fileInfo: documentsPath,
              onTap: _pickDocuments,
              iconData: Icons.attach_file,
            ),
            const SizedBox(height: 24.0),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Submit Application',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // If editing or creating, revert to list view
    if (isEditing || isCreating) {
      setState(() {
        isEditing = false;
        isCreating = false;
      });
      return false; // Don't pop
    }
    return true; // Pop if not editing/creating
  }
}
