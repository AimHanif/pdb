import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../colors.dart';

class AdminEPerjawatanScreen extends StatefulWidget {
  const AdminEPerjawatanScreen({Key? key}) : super(key: key);

  @override
  State<AdminEPerjawatanScreen> createState() => _AdminEPerjawatanScreenState();
}

class _AdminEPerjawatanScreenState extends State<AdminEPerjawatanScreen> {
  late Box ePerjawatanBox;
  bool isBoxReady = false;
  List<Map<String, dynamic>> applications = [];

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
    applications = List<Map<String, dynamic>>.from(storedApps);
  }

  void _saveApplications() {
    ePerjawatanBox.put('applications', applications);
  }

  void _approveApplication(int index) {
    applications[index]['status'] = 'Approved';
    applications[index]['latestUpdateDate'] = DateTime.now();
    _saveApplications();
    setState(() {});
  }

  void _rejectApplication(int index) {
    applications[index]['status'] = 'Rejected';
    applications[index]['latestUpdateDate'] = DateTime.now();
    _saveApplications();
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (!isBoxReady) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: applications.isEmpty
          ? Center(
        child: Text(
          'No Applications Found',
          style: GoogleFonts.poppins(fontSize: 18.0, color: AppColors.textPrimary),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];
          return _buildApplicationCard(app, index);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'e-Perjawatan Admin',
        style: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app, int index) {
    Color statusColor;
    switch (app['status'].toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
          _buildInfoRow('Position', app['position']),
          _buildInfoRow('Company/Agency/Dept.', app['company']),
          if ((app['department'] as String).isNotEmpty) _buildInfoRow('Department', app['department']),
          _buildInfoRow('Application Date', _formatDate(app['applicationDate'])),
          _buildInfoRow('Last Update Date', _formatDate(app['latestUpdateDate'])),
          Row(
            children: [
              Text('Status: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
              Text(app['status'], style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12.0),
          if (app['status'] == 'Pending')
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _approveApplication(index),
                  icon: Icon(Icons.check),
                  label: Text('Approve'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton.icon(
                  onPressed: () => _rejectApplication(index),
                  icon: Icon(Icons.close),
                  label: Text('Reject'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
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

