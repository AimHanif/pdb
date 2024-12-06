import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'colors.dart';
import 'navbar.dart';

class EInternshipScreen extends StatefulWidget {
  const EInternshipScreen({Key? key}) : super(key: key);

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
    applications = List<Map<String, dynamic>>.from(storedApps);
  }

  void _saveApplications() {
    eInternshipBox.put('applications', applications);
  }

  void _submitApplication() {
    if (applications.length >= 3 && !isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have reached the maximum of 3 applications.')),
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
        SnackBar(content: Text('Please fill in all required fields before submitting.')),
      );
      return;
    }

    if (startDate!.isAfter(endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Start Date cannot be after End Date.')),
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
          SnackBar(content: Text('You have already applied for this combination.'))
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
          SnackBar(content: Text('You cannot edit this application more than 3 times.')),
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
        SnackBar(content: Text('All statuses refreshed!'))
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
    if (app['editCount'] >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot edit this application more than 3 times.')),
      );
      return;
    }
    selectedPosition = app['position'];
    selectedCompany = app['company'];
    selectedDepartment = app['department'];
    selectedSupervisor = app['supervisor']; // Set supervisor
    startDate = DateTime.parse(app['startDate'].toString());
    endDate = DateTime.parse(app['endDate'].toString());
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

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? (startDate ?? DateTime.now()),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
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
        icon: Icon(Icons.arrow_back, color: Colors.white),
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
        decoration: BoxDecoration(
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
        style: GoogleFonts.poppins(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
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
                    icon: Icon(Icons.add, size: 18.0), // Changed to Icon
                    label: Text(
                      'Add Application',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
                    icon: Icon(Icons.refresh, size: 18.0), // Changed to Icon
                    label: Text(
                      'Refresh Status',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
      key: ValueKey('formView'),
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: _whiteCardDecoration(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (isEditing ? 'Edit Your Internship' : 'Submit Your Internship Application') + ' 📝',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildDropdownField('Position 💼', positions, (val) => selectedPosition = val, selectedPosition),
            const SizedBox(height: 16.0),
            _buildDropdownField('Agency / Department 🏢', companies, (val) => selectedCompany = val, selectedCompany),
            const SizedBox(height: 16.0),
            _buildDropdownField('Department 🗂', departments, (val) => selectedDepartment = val, selectedDepartment),
            const SizedBox(height: 16.0),
            _buildDropdownField('Supervisor 👨‍🏫', supervisors, (val) => selectedSupervisor = val, selectedSupervisor), // New field
            const SizedBox(height: 16.0),
            // Start and End Date in one row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date 📅',
                            style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            startDate == null ? 'Start Date' : _formatDate(startDate!),
                            style: GoogleFonts.poppins(fontSize: 16.0, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date 📅',
                            style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            endDate == null ? 'End Date' : _formatDate(endDate!),
                            style: GoogleFonts.poppins(fontSize: 16.0, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            _buildFileUploadButton('Upload Resume (Optional)', resumePath, _pickResume, Icons.description_outlined),
            const SizedBox(height: 16.0),
            _buildFileUploadButton('Upload Supporting Docs (Optional)', supportingDocs.isEmpty ? null : '${supportingDocs.length} files', _pickSupportingDocuments, Icons.attach_file),
            const SizedBox(height: 24.0),
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
      key: ValueKey('listView'),
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
          }).toList(),
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
          _buildInfoRow('Start Date', _formatDate(DateTime.parse(app['startDate'].toString()))),
          _buildInfoRow('End Date', _formatDate(DateTime.parse(app['endDate'].toString()))),
          _buildInfoRow('Application Date', _formatDate(DateTime.parse(app['applicationDate'].toString()))),
          _buildInfoRow('Last Update Date', _formatDate(DateTime.parse(app['latestUpdateDate'].toString()))),
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
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
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
              Icon(Icons.edit, color: AppColors.primary),
              const SizedBox(width: 8.0),
              Text('Edit', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 8.0),
              Text('Delete', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadButton(String label, String? fileInfo, VoidCallback onTap, IconData iconData) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(iconData, color: AppColors.primary),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                fileInfo == null ? label : '$label: $fileInfo',
                style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary),
              ),
            ),
            Icon(Icons.upload_file, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, ValueChanged<String?> onChanged, String? currentValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonFormField<String>(
            value: currentValue,
            decoration: const InputDecoration(border: InputBorder.none),
            style: GoogleFonts.poppins(fontSize: 16.0, color: AppColors.textPrimary),
            hint: Text(
              'Select $label',
              style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary.withOpacity(0.8)),
            ),
            items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
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
