import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdb/profile_screen.dart';
import 'colors.dart';
import 'main_menu.dart';
import 'navbar.dart';
import 'dart:io';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreenContent();
      case 1:
        return const MainMenu();
      case 2:
        return const ProfileScreen();
      default:
        return const HomeScreenContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
          'Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _getScreenForIndex(_selectedIndex),
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
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  late Box profileBox;

  String fullName = 'Pengguna';
  String idNumber = 'N/A';
  String lastLogin = 'Unknown';
  String verifiedAt = 'Unknown';
  File? _profileImage;
  bool _isAcknowledged = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    profileBox = await Hive.openBox('profileData');

    fullName = profileBox.get('fullName', defaultValue: 'Pengguna');
    idNumber = profileBox.get('idNumber', defaultValue: 'N/A');
    lastLogin = profileBox.get('lastLogin', defaultValue: 'Unknown');
    profileBox.put('lastLogin', DateTime.now().toString());
    verifiedAt = profileBox.get('verifiedAt', defaultValue: DateTime.now().toString());

    String? imagePath = profileBox.get('profileImagePath');
    if (imagePath != null && File(imagePath).existsSync()) {
      _profileImage = File(imagePath);
    }

    _isAcknowledged = profileBox.get('isAcknowledged', defaultValue: false);

    setState(() {});
  }

  void _saveAcknowledgment(bool value) {
    profileBox.put('isAcknowledged', value);
    setState(() {
      _isAcknowledged = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: const [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: _profileImage != null
                      ? ClipOval(
                    child: Image.file(
                      _profileImage!,
                      fit: BoxFit.cover,
                      width: 120.0,
                      height: 120.0,
                    ),
                  )
                      : const Icon(
                    Icons.person,
                    size: 60.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Selamat Datang, $fullName',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Portal Perak Digital 3.0',
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 5,
            color: AppColors.cardBackground,
            shadowColor: Colors.black.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: AppColors.iconColor),
                    title: Text(
                      'ID Pengguna',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      idNumber,
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.access_time, color: AppColors.iconColor),
                    title: Text(
                      'Log Masuk Terakhir',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      lastLogin,
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: AppColors.iconColor),
                    title: Text(
                      'Akuan Pada',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      verifiedAt,
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Divider(),
                  CheckboxListTile(
                    title: Text(
                      'Akuan Pengguna',
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    subtitle: Text(
                      'Saya akui bahawa keterangan yang saya beri adalah benar.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.0,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                    value: _isAcknowledged,
                    onChanged: (value) {
                      if (value != null) {
                        _saveAcknowledgment(value);
                        if (!_isAcknowledged) {
                          profileBox.put('verifiedAt', DateTime.now().toString());
                        }
                      }
                    },
                    activeColor: AppColors.primary,
                    checkColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
