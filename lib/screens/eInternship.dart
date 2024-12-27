// eInternship.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../colors.dart';
import '../navbar.dart';

// Import the custom widgets
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_date_picker.dart';
import '../widgets/custom_file_upload_button.dart';
// If you have a custom text field

class EInternshipScreen extends StatefulWidget {
  const EInternshipScreen({super.key});

  @override
  State<EInternshipScreen> createState() => _EInternshipScreenState();
}

class _EInternshipScreenState extends State<EInternshipScreen> {
  int _selectedIndex = 0;
  late Box eInternshipBox;
  bool isBoxReady = false;

  List<Map<String, dynamic>> applications = [];

  final List<String> positions = ['Manager', 'Officer', 'Clerk', 'Intern'];
  final List<String> companies = ['Company A', 'Agency B', 'Department C'];
  final List<String> departments = ['HR', 'Finance', 'IT', 'Admin'];

  // New field: Supervisors
  final List<String> supervisors = ['Dr. Ahmad', 'Prof. Lim', 'Ms. Siti', 'Mr. Tan'];

  String? selectedPosition;
  String? selectedCompany;
  String? selectedDepartment;
  String? selectedSupervisor; // New field

  DateTime? startDate; // New field
  DateTime? endDate; // New field

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
    if (!Hive.isBoxOpen('eInternshipData')) { // Updated box name
      await Hive.openBox('eInternshipData');
    }
    eInternshipBox = Hive.box('eInternshipData');
    _loadApplications();
    setState(() {
      isBoxReady = true;
    });
  }

  void _loadApplications() {
    final storedApps = eInternshipBox.get('applications', defaultValue: []);
    if (storedApps is List) {
      applications = storedApps
          .whereType<Map>()
          .map((app) => Map<String, dynamic>.from(app))
          .toList();
    } else {
      applications = [];
    }
  }

  void _saveApplications() {
    eInternshipBox.put(
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

    if (selectedPosition == null ||
        selectedCompany == null ||
        selectedDepartment == null ||
        selectedSupervisor == null || // Validate supervisor
        startDate == null ||
        endDate == null) { // Validate dates
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields before submitting.')),
      );
      return;
    }

    if (startDate!.isAfter(endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start Date cannot be after End Date.')),
      );
      return;
    }

    // Check for duplicates
    bool duplicate = applications.any((app) =>
    app['position'] == selectedPosition &&
        app['company'] == selectedCompany &&
        app['department'] == selectedDepartment &&
        app['supervisor'] == selectedSupervisor &&
        app['startDate'] == startDate &&
        app['endDate'] == endDate
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
      'supervisor': selectedSupervisor!, // New field
      'startDate': startDate!,
      'endDate': endDate!,
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
    selectedSupervisor = null; // Reset supervisor
    startDate = null; // Reset dates
    endDate = null;
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
    selectedSupervisor = app['supervisor']; // Set supervisor
    startDate = app['startDate'] as DateTime;
    endDate = app['endDate'] as DateTime;
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

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
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
        'e-Internship 🏢',
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
              '${isEditing ? 'Edit Your Internship' : 'Submit Your Internship Application'} 📝',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Position
            CustomDropdown(
              label: 'Position 💼',
              items: positions,
              value: selectedPosition,
              onChanged: (val) => setState(() {
                selectedPosition = val;
              }),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Company/Agency
            CustomDropdown(
              label: 'Agency / Department 🏢',
              items: companies,
              value: selectedCompany,
              onChanged: (val) => setState(() {
                selectedCompany = val;
              }),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Department
            CustomDropdown(
              label: 'Department 🗂',
              items: departments,
              value: selectedDepartment,
              onChanged: (val) => setState(() {
                selectedDepartment = val;
              }),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Supervisor
            CustomDropdown(
              label: 'Supervisor 👨‍🏫',
              items: supervisors,
              value: selectedSupervisor,
              onChanged: (val) => setState(() {
                selectedSupervisor = val;
              }),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDatePicker for Start Date
            CustomDatePicker(
              label: 'Start Date 📅',
              selectedDate: startDate,
              onDateSelected: (date) => setState(() {
                startDate = date;
              }),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDatePicker for End Date
            CustomDatePicker(
              label: 'End Date 📅',
              selectedDate: endDate,
              onDateSelected: (date) => setState(() {
                endDate = date;
              }),
            ),
            const SizedBox(height: 16.0),
            // Using CustomFileUploadButton for Resume
            CustomFileUploadButton(
              label: 'Upload Resume (Optional)',
              fileInfo: resumePath?.split('/').last,
              onTap: _pickResume,
              iconData: Icons.description_outlined,
              multiple: false,
            ),
            const SizedBox(height: 16.0),
            // Using CustomFileUploadButton for Supporting Docs
            CustomFileUploadButton(
              label: 'Upload Supporting Docs (Optional)',
              fileInfo: supportingDocs.isEmpty ? null : '${supportingDocs.length} files',
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
                  isEditing ? 'Save Changes' : 'Submit Application',
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
    return SingleChildScrollView(
      key: const ValueKey('listView'),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Internship Applications 🗃',
            style: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16.0),
          ...applications.asMap().entries.map((entry) {
            final index = entry.key;
            final app = entry.value;
            return _buildApplicationCard(app, index);
          }),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app, int index) {
    String statusText;
    Color statusColor;

    switch (app['status'].toLowerCase()) {
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
      decoration: _whiteCardDecoration(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Position', app['position']),
          _buildInfoRow('Company/Agency/Dept.', app['company']),
          _buildInfoRow('Department', app['department']),
          _buildInfoRow('Supervisor', app['supervisor']), // Display supervisor
          _buildInfoRow('Start Date', _formatDate(app['startDate'])),
          _buildInfoRow('End Date', _formatDate(app['endDate'])),
          _buildInfoRow('Application Date', _formatDate(app['applicationDate'])),
          _buildInfoRow('Last Update Date', _formatDate(app['latestUpdateDate'])),
          Row(
            children: [
              Text('Status: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
              Text(statusText, style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12.0),
          // If pending, show edit/delete. If not, no edit/delete.
          if (app['status'] == 'Pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildPopupMenu(index),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(int index) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      onSelected: (value) {
        if (value == 'edit') {
          _editApplication(index);
        } else if (value == 'delete') {
          _deleteApplication(index);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit, color: AppColors.primary),
              const SizedBox(width: 8.0),
              Text('Edit', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 8.0),
              Text('Delete', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
