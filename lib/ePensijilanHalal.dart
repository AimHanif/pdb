import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'navbar.dart';
import 'colors.dart';

class EPensijilanHalalScreen extends StatefulWidget {
  const EPensijilanHalalScreen({Key? key}) : super(key: key);

  @override
  State<EPensijilanHalalScreen> createState() => _EPensijilanHalalScreenState();
}

class _EPensijilanHalalScreenState extends State<EPensijilanHalalScreen> {
  int _selectedIndex = 0;
  late Box ePensijilanBox;
  bool isBoxReady = false;

  List<Map<String, dynamic>> applications = [];

  String? hasSystem; // Sistem Jaminan Halal (HAS)
  String? halalSupervisor; // Penyelia / Eksekutif Halal
  String? salesValue; // Nilai Jualan
  String? companyName; // Nama Syarikat

  final List<String> hasOptions = ['Ada', 'Tiada'];
  final List<String> supervisorOptions = ['Ada', 'Tiada'];
  final List<String> salesOptions = [
    'Industri Mikro (RM300 Ribu Kebawah)',
    'Industri Kecil (RM300 Ribu - RM15 Juta)',
    'Perusahaan Kecil Sederhana (RM15 Juta - RM50 Juta)',
    'Multinasional (RM50 Juta Keatas)'
  ];

  bool isEditing = false;
  bool isCreating = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _initHiveData();
  }

  Future<void> _initHiveData() async {
    if (!Hive.isBoxOpen('ePensijilanData')) {
      await Hive.openBox('ePensijilanData');
    }
    ePensijilanBox = Hive.box('ePensijilanData');
    _loadApplications();
    setState(() {
      isBoxReady = true;
    });
  }

  void _loadApplications() {
    final storedApps = ePensijilanBox.get('applications', defaultValue: []);
    applications = List<Map<String, dynamic>>.from(storedApps);
  }

  void _saveApplications() {
    ePensijilanBox.put('applications', applications);
  }

  void _submitApplication() {
    if (hasSystem == null || halalSupervisor == null || salesValue == null || companyName == null || companyName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sila lengkapkan semua maklumat yang diperlukan sebelum meneruskan.')),
      );
      return;
    }

    final newApplication = {
      'hasSystem': hasSystem,
      'halalSupervisor': halalSupervisor,
      'salesValue': salesValue,
      'companyName': companyName,
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
    hasSystem = null;
    halalSupervisor = null;
    salesValue = null;
    companyName = null;
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
    hasSystem = app['hasSystem'];
    halalSupervisor = app['halalSupervisor'];
    salesValue = app['salesValue'];
    companyName = app['companyName'];
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
        'e-Pensijilan Halal',
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
            _buildDropdownField('Sistem Jaminan Halal (HAS)', hasOptions, (val) => setState(() => hasSystem = val), hasSystem),
            const SizedBox(height: 16.0),
            _buildDropdownField('Penyelia / Eksekutif Halal (Muslim)', supervisorOptions, (val) => setState(() => halalSupervisor = val), halalSupervisor),
            const SizedBox(height: 16.0),
            _buildDropdownField('Nilai Jualan', salesOptions, (val) => setState(() => salesValue = val), salesValue),
            const SizedBox(height: 16.0),
            _buildTextField('Nama Syarikat', (val) => setState(() => companyName = val), companyName),
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
          _buildInfoRow('Sistem Jaminan Halal (HAS)', app['hasSystem']),
          _buildInfoRow('Penyelia / Eksekutif Halal', app['halalSupervisor']),
          _buildInfoRow('Nilai Jualan', app['salesValue']),
          _buildInfoRow('Nama Syarikat', app['companyName']),
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
