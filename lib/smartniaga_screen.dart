import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'navbar.dart';
import 'colors.dart';

class SmartNiagaScreen extends StatefulWidget {
  const SmartNiagaScreen({Key? key}) : super(key: key);

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
    applications = List<Map<String, dynamic>>.from(storedApps);
  }

  void _saveApplications() {
    smartNiagaBox.put('applications', applications);
  }

  void _submitApplication() {
    if (pbtArea == null ||
        zone == null ||
        pbtLicense == null ||
        ssmRegistration == null ||
        companyName == null ||
        companyName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sila lengkapkan semua maklumat yang diperlukan sebelum meneruskan.')),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildContent(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
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
                    icon: Icon(Icons.add, size: 18.0),
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
                    icon: Icon(Icons.refresh, size: 18.0),
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
            _buildTextField('Kawasan PBT', (val) => setState(() => pbtArea = val), pbtArea),
            const SizedBox(height: 16.0),
            _buildDropdownField('Zon', yesNoOptions, (val) => setState(() => zone = val), zone),
            const SizedBox(height: 16.0),
            _buildDropdownField('Lesen Perniagaan PBT', yesNoOptions, (val) => setState(() => pbtLicense = val), pbtLicense),
            const SizedBox(height: 16.0),
            _buildTextField('No. Akaun Lesen Perniagaan PBT', (val) => setState(() => pbtLicenseAccount = val), pbtLicenseAccount),
            const SizedBox(height: 16.0),
            _buildDropdownField('Daftar SSM', yesNoOptions, (val) => setState(() => ssmRegistration = val), ssmRegistration),
            const SizedBox(height: 16.0),
            _buildTextField('Nama Syarikat', (val) => setState(() => companyName = val), companyName),
            const SizedBox(height: 16.0),
            _buildTextField('No. Pendaftaran SSM', (val) => setState(() => ssmNumber = val), ssmNumber),
            const SizedBox(height: 16.0),
            _buildTextField('Nama Jenama', (val) => setState(() => brandName = val), brandName),
            const SizedBox(height: 16.0),
            _buildTextField('URL Laman Web / Media Sosial', (val) => setState(() => websiteUrl = val), websiteUrl),
            const SizedBox(height: 16.0),
            _buildMultiSelectField('Pemasaran (Platform Online)', marketingOptions, (val) => setState(() => marketingPlatforms = val)),
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
          _buildInfoRow('Kawasan PBT', app['pbtArea']),
          _buildInfoRow('Zon', app['zone']),
          _buildInfoRow('Lesen Perniagaan PBT', app['pbtLicense']),
          _buildInfoRow('No. Akaun Lesen Perniagaan PBT', app['pbtLicenseAccount'] ?? '-'),
          _buildInfoRow('Daftar SSM', app['ssmRegistration']),
          _buildInfoRow('Nama Syarikat', app['companyName']),
          _buildInfoRow('No. Pendaftaran SSM', app['ssmNumber'] ?? '-'),
          _buildInfoRow('Nama Jenama', app['brandName'] ?? '-'),
          _buildInfoRow('URL Laman Web / Media Sosial', app['websiteUrl'] ?? '-'),
          _buildInfoRow('Pemasaran (Platform Online)', app['marketingPlatforms'].join(', ')),
          _buildInfoRow('Application Date', _formatDate(DateTime.parse(app['applicationDate'].toString()))),
          _buildInfoRow('Last Update Date', _formatDate(DateTime.parse(app['latestUpdateDate'].toString()))),
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
            style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textPrimary),
            hint: Text(
              'Pilih $label',
              style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary.withOpacity(0.8)),
            ),
            items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item, overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
            onChanged: onChanged,
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, ValueChanged<String?> onChanged, String? currentValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          initialValue: currentValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.5),
            ),
            hintText: 'Masukkan $label',
            hintStyle: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary.withOpacity(0.8)),
          ),
          style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textPrimary),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMultiSelectField(String label, List<String> items, ValueChanged<List<String>> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: items.map((item) {
            return FilterChip(
              label: Text(item, style: GoogleFonts.poppins(color: AppColors.textPrimary)),
              selected: marketingPlatforms.contains(item),
              onSelected: (isSelected) {
                setState(() {
                  isSelected ? marketingPlatforms.add(item) : marketingPlatforms.remove(item);
                  onChanged(marketingPlatforms);
                });
              },
              backgroundColor: AppColors.background,
              selectedColor: AppColors.primary.withOpacity(0.2),
            );
          }).toList(),
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

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
