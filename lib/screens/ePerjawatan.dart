// e_perjawatan_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../colors.dart';
import '../navbar.dart';
import '../widgets/application_list.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_file_upload_button.dart';

class EPerjawatanScreen extends StatefulWidget {
  const EPerjawatanScreen({super.key});

  @override
  State<EPerjawatanScreen> createState() => _EPerjawatanScreenState();
}

class _EPerjawatanScreenState extends State<EPerjawatanScreen> {
  int _selectedIndex = 0;
  late Box ePerjawatanBox;
  bool isBoxReady = false;

  List<Map<String, dynamic>> applications = [];

  final fieldConfigurations = [
    {'label': 'Position', 'key': 'position'},
    {'label': 'Company', 'key': 'company'},
    {'label': 'Department', 'key': 'department'},
    {'label': 'Application Date', 'key': 'applicationDate'},
    {'label': 'Status', 'key': 'status'},
  ];

  final List<String> positions = ['Pengurus', 'Pegawai', 'Kerani', 'Tukang Kebun'];
  final List<String> companies = ['Syarikat Ahza', 'PPD Ipoh', 'JPJ Tanjung Malim'];
  final List<String> departments = ['Sumber Manusia', 'Kewangan', 'IT', 'Pentadbiran'];

  String? selectedPosition;
  String? selectedCompany;
  String? selectedDepartment;

  String? resumePath;
  List<String> supportingDocs = [];

  bool isEditing = false;
  bool isCreating = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _initHiveData();
  }

  Future<void> _initHiveData() async {
    if (!Hive.isBoxOpen('ePerjawatanData')) {
      await Hive.openBox('ePerjawatanData');
    }
    ePerjawatanBox = Hive.box('ePerjawatanData');
    _loadApplications();
    setState(() {
      isBoxReady = true;
    });
  }

  void _loadApplications() {
    final storedApps = ePerjawatanBox.get('applications', defaultValue: []);
    if (storedApps is List) {
      applications = storedApps
          .whereType<Map>() // Ensure only maps are processed
          .map((app) => Map<String, dynamic>.from(app)) // Cast to Map<String, dynamic>
          .toList();
    } else {
      applications = [];
    }
  }

  void _saveApplications() {
    ePerjawatanBox.put(
      'applications',
      applications.map((app) => Map<String, dynamic>.from(app)).toList(),
    );
  }

  void _submitApplication() {
    if (applications.length >= 3 && !isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached the maximum of 3 applications.')),
      );
      return;
    }

    if (selectedPosition == null || selectedCompany == null || selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Position, Company/Agency, and Department before submitting.')),
      );
      return;
    }

    // Check for duplicates
    bool duplicate = applications.any((app) =>
    app['position'] == selectedPosition &&
        app['company'] == selectedCompany &&
        app['department'] == selectedDepartment
    );

    if (!isEditing && duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already applied for this combination.'))
      );
      return;
    }

    final newApp = {
      'position': selectedPosition!,
      'company': selectedCompany!,
      'department': selectedDepartment!,
      'status': 'Pending',
      'applicationDate': DateTime.now(),
      'latestUpdateDate': DateTime.now(),
      'resumePath': resumePath,
      'supportingDocs': supportingDocs,
      'editCount': isEditing ? applications[editingIndex!]['editCount'] : 0,
    };

    if (isEditing && editingIndex != null) {
      final app = applications[editingIndex!];
      if (app['editCount'] >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot edit this application more than 3 times.')),
        );
        return;
      }
      newApp['editCount'] = app['editCount'] + 1;
      applications[editingIndex!] = newApp;
    } else {
      applications.add(newApp);
    }

    _saveApplications();
    _resetForm();
    setState(() {
      isCreating = false;
      isEditing = false;
    });
  }


  void _resetForm() {
    selectedPosition = null;
    selectedCompany = null;
    selectedDepartment = null;
    resumePath = null;
    supportingDocs = [];
    isEditing = false;
    editingIndex = null;
  }

  void _refreshStatus() {
    _loadApplications();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All statuses refreshed!'))
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
        const SnackBar(content: Text('You can only edit pending applications.')),
      );
      return;
    }

    if (app['editCount'] >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot edit this application more than 3 times.')),
      );
      return;
    }

    selectedPosition = app['position'];
    selectedCompany = app['company'];
    selectedDepartment = app['department'];
    resumePath = app['resumePath'];
    supportingDocs = List<String>.from(app['supportingDocs']);

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

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      resumePath = result.files.single.path;
      setState(() {});
    }
  }

  Future<void> _pickSupportingDocuments() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);
    if (result != null) {
      supportingDocs.addAll(result.files.map((f) => f.path!).toList());
      setState(() {});
    }
  }

  Future<bool> _onWillPop() async {
    // If editing or creating, just revert to list view
    if (isEditing || isCreating) {
      setState(() {
        isEditing = false;
        isCreating = false;
      });
      return false; // Don't pop
    }
    return true; // Pop if not editing/creating
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
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

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () async {
          // If editing/creating, revert to list, else pop
          if (isEditing || isCreating) {
            setState(() {
              isEditing = false;
              isCreating = false;
            });
          } else {
            Navigator.pop(context);
          }
        },
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      title: Text(
        'e-Perjawatan 🏢',
        style: GoogleFonts.poppins(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent() {
    if (isCreating || isEditing || applications.isEmpty) {
      return _buildApplicationFormWidget();
    }
    return Stack(
      children: [
        _buildApplicationsList(),
        // Big buttons row at the bottom
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
                    icon: const Text('  ➕', style: TextStyle(fontSize: 18.0)),
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
                    icon: const Text('🔄', style: TextStyle(fontSize: 18.0)),
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
      key: const ValueKey('formView'),
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: _whiteCardDecoration(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (isEditing ? 'Edit Your Application' : 'Submit Your Application') + ' 📝',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Position
            CustomDropdown(
              label: 'Jawatan 💼',
              items: positions,
              value: selectedPosition,
              onChanged: (val) => setState(() {
                selectedPosition = val;
              }),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Company/Agency
            CustomDropdown(
              label: 'Agensi / Jabatan 🏢',
              items: companies,
              value: selectedCompany,
              onChanged: (val) => setState(() {
                selectedCompany = val;
              }),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Department
            CustomDropdown(
              label: 'Jabatan 🗂',
              items: departments,
              value: selectedDepartment,
              onChanged: (val) => setState(() {
                selectedDepartment = val;
              }),
            ),
            const SizedBox(height: 16.0),
            // Using CustomFileUploadButton for Resume
            CustomFileUploadButton(
              label: 'Muat Naik Resume (Jika berkaitan)',
              fileInfo: resumePath != null ? resumePath!.split('/').last : null,
              onTap: _pickResume,
              iconData: Icons.description_outlined,
            ),
            const SizedBox(height: 16.0),
            // Using CustomFileUploadButton for Supporting Docs
            CustomFileUploadButton(
              label: 'Muat Naik Dokument Sokongan (Jika berkaitan)',
              fileInfo: supportingDocs.isEmpty ? null : supportingDocs.length.toString(),
              onTap: _pickSupportingDocuments,
              iconData: Icons.attach_file,
              multiple: true,
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
                  isEditing ? 'Simpan' : 'Mohon',
                  style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.buttonText),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'You can edit pending applications up to 3 times before they are approved or rejected.\nResume and supporting documents are optional.',
              style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsList() {
    return   ApplicationList(
      applications: applications,
      fieldConfigurations: fieldConfigurations,
      onEdit: (index) => print('Edit application at $index'),
      onDelete: (index) => print('Delete application at $index'),
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 15.0,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
