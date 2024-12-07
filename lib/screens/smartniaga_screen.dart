// smart_niaga_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../navbar.dart';
import '../colors.dart';

// Import the custom widgets
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_multi_select_field.dart';

class SmartNiagaScreen extends StatefulWidget {
  const SmartNiagaScreen({super.key});

  @override
  State<SmartNiagaScreen> createState() => _SmartNiagaScreenState();
}

class _SmartNiagaScreenState extends State<SmartNiagaScreen> {
  int _selectedIndex = 0;
  late Box smartNiagaBox;
  bool isBoxReady = false;

  List<Map<String, dynamic>> applications = [];

  String? pbtArea; // Kawasan PBT
  String? zone; // Zon
  String? pbtLicense; // Lesen Perniagaan PBT
  String? pbtLicenseAccount; // No. Akaun Lesen Perniagaan PBT
  String? ssmRegistration; // Daftar SSM
  String? companyName; // Nama Syarikat
  String? ssmNumber; // No. Pendaftaran SSM
  String? brandName; // Nama Jenama
  String? websiteUrl; // URL Laman Web / Media Sosial
  List<String> marketingPlatforms = []; // Pemasaran (Platform Online)

  final List<String> yesNoOptions = ['Ya', 'Tidak'];
  final List<String> marketingOptions = ['Facebook', 'Instagram', 'Tiktok', 'Whatsapp', 'Shopee', 'Lazada'];

  bool isEditing = false;
  bool isCreating = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _initHiveData();
  }

  Future<void> _initHiveData() async {
    if (!Hive.isBoxOpen('smartNiagaData')) {
      await Hive.openBox('smartNiagaData');
    }
    smartNiagaBox = Hive.box('smartNiagaData');
    _loadApplications();
    setState(() {
      isBoxReady = true;
    });
  }

  void _loadApplications() {
    final storedApps = smartNiagaBox.get('applications', defaultValue: []);
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
    smartNiagaBox.put(
      'applications',
      applications.map((app) => Map<String, dynamic>.from(app)).toList(),
    );
  }

  void _submitApplication() {
    if (pbtArea == null ||
        zone == null ||
        pbtLicense == null ||
        ssmRegistration == null ||
        companyName == null ||
        companyName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila lengkapkan semua maklumat yang diperlukan sebelum meneruskan.')),
      );
      return;
    }

    final newApplication = {
      'pbtArea': pbtArea,
      'zone': zone,
      'pbtLicense': pbtLicense,
      'pbtLicenseAccount': pbtLicenseAccount,
      'ssmRegistration': ssmRegistration,
      'companyName': companyName,
      'ssmNumber': ssmNumber,
      'brandName': brandName,
      'websiteUrl': websiteUrl,
      'marketingPlatforms': marketingPlatforms,
      'status': 'Pending',
      'applicationDate': DateTime.now(),
      'latestUpdateDate': DateTime.now(),
    };

    if (isEditing && editingIndex != null) {
      final app = applications[editingIndex!];
      if (app['status'] != 'Pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only edit pending applications.')),
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
    pbtArea = null;
    zone = null;
    pbtLicense = null;
    pbtLicenseAccount = null;
    ssmRegistration = null;
    companyName = null;
    ssmNumber = null;
    brandName = null;
    websiteUrl = null;
    marketingPlatforms = [];
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
    pbtArea = app['pbtArea'];
    zone = app['zone'];
    pbtLicense = app['pbtLicense'];
    pbtLicenseAccount = app['pbtLicenseAccount'];
    ssmRegistration = app['ssmRegistration'];
    companyName = app['companyName'];
    ssmNumber = app['ssmNumber'];
    brandName = app['brandName'];
    websiteUrl = app['websiteUrl'];
    marketingPlatforms = List<String>.from(app['marketingPlatforms']);
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _onWillPop(),
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
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
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
        'Smart Niaga',
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
                    icon: const Icon(Icons.add, size: 18.0),
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
                    icon: const Icon(Icons.refresh, size: 18.0),
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
        decoration: _whiteCardDecoration(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Your Application 📝' : 'Submit Your Application 📝',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for Kawasan PBT
            CustomTextField(
              label: 'Kawasan PBT 🏙️',
              initialValue: pbtArea,
              onChanged: (val) => setState(() => pbtArea = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Zon
            CustomDropdown(
              label: 'Zon 📍',
              items: yesNoOptions,
              value: zone,
              onChanged: (val) => setState(() => zone = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Lesen Perniagaan PBT
            CustomDropdown(
              label: 'Lesen Perniagaan PBT 📝',
              items: yesNoOptions,
              value: pbtLicense,
              onChanged: (val) => setState(() => pbtLicense = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for No. Akaun Lesen Perniagaan PBT
            CustomTextField(
              label: 'No. Akaun Lesen Perniagaan PBT 💼',
              initialValue: pbtLicenseAccount,
              onChanged: (val) => setState(() => pbtLicenseAccount = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Daftar SSM
            CustomDropdown(
              label: 'Daftar SSM 📄',
              items: yesNoOptions,
              value: ssmRegistration,
              onChanged: (val) => setState(() => ssmRegistration = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for Nama Syarikat
            CustomTextField(
              label: 'Nama Syarikat 🏢',
              initialValue: companyName,
              onChanged: (val) => setState(() => companyName = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for No. Pendaftaran SSM
            CustomTextField(
              label: 'No. Pendaftaran SSM 📇',
              initialValue: ssmNumber,
              onChanged: (val) => setState(() => ssmNumber = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for Nama Jenama
            CustomTextField(
              label: 'Nama Jenama 🌟',
              initialValue: brandName,
              onChanged: (val) => setState(() => brandName = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTextField for URL Laman Web / Media Sosial
            CustomTextField(
              label: 'URL Laman Web / Media Sosial 🌐',
              initialValue: websiteUrl,
              onChanged: (val) => setState(() => websiteUrl = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomMultiSelectField for Pemasaran (Platform Online)
            CustomMultiSelectField(
              label: 'Pemasaran (Platform Online) 📱',
              options: marketingOptions,
              selectedOptions: marketingPlatforms,
              onSelectionChanged: (selected) => setState(() => marketingPlatforms = selected),
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
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Applications 🗃',
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
          _buildInfoRow('Kawasan PBT', app['pbtArea']),
          _buildInfoRow('Zon', app['zone']),
          _buildInfoRow('Lesen Perniagaan PBT', app['pbtLicense']),
          _buildInfoRow('No. Akaun Lesen Perniagaan PBT', app['pbtLicenseAccount'] ?? '-'),
          _buildInfoRow('Daftar SSM', app['ssmRegistration']),
          _buildInfoRow('Nama Syarikat', app['companyName']),
          _buildInfoRow('No. Pendaftaran SSM', app['ssmNumber'] ?? '-'),
          _buildInfoRow('Nama Jenama', app['brandName'] ?? '-'),
          _buildInfoRow('URL Laman Web / Media Sosial', app['websiteUrl'] ?? '-'),
          _buildInfoRow('Pemasaran (Platform Online)', (app['marketingPlatforms'] as List).join(', ')),
          _buildInfoRow('Application Date', _formatDate(app['applicationDate'])),
          _buildInfoRow('Last Update Date', _formatDate(app['latestUpdateDate'])),
          Row(
            children: [
              Text('Status: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
              Text(statusText, style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12.0),
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

  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return DateFormat('yyyy-MM-dd').format(date);
    } else if (date is String) {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
    }
    return 'Invalid Date';
  }
}
