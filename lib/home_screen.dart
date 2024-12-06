import 'dart:math';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Importing auto_size_text package for text resizing
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
    // Navigate between the three main screens
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
        // Gradient AppBar for a modern and appealing effect
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
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Only pop if a previous screen exists
          },
        )
            : null,
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
  File? _profileImage; // To hold the loaded profile image
  bool _isAcknowledged = false; // To track if the user has acknowledged

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  String _generateRandomId() {
    // Simple random ID based on current time and a random number
    final rand = Random().nextInt(999999);
    return 'ID${DateTime.now().millisecondsSinceEpoch}$rand';
  }

  void _loadProfileData() {
    profileBox = Hive.box('profileData');

    // Full Name
    fullName = profileBox.get('fullName', defaultValue: 'Pengguna');

    // ID Pengguna: If not available, generate and save a random ID
    if (!profileBox.containsKey('idNumber')) {
      String newId = _generateRandomId();
      profileBox.put('idNumber', newId);
      idNumber = newId;
    } else {
      idNumber = profileBox.get('idNumber', defaultValue: 'N/A');
    }

    // Log Masuk Terakhir: Show old login time and then update to current
    String oldLogin = profileBox.get('lastLogin', defaultValue: 'Unknown');
    lastLogin = oldLogin; // Display the old login time
    profileBox.put('lastLogin', DateTime.now().toString()); // Update for next time

    // Akuan Pada (verifiedAt)
    verifiedAt = profileBox.get('verifiedAt', defaultValue: DateTime.now().toString());

    // Load profile image
    String? imagePath = profileBox.get('profileImagePath');
    if (imagePath != null && File(imagePath).existsSync()) {
      _profileImage = File(imagePath);
    }

    // Load acknowledgment status
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
          // Profile Section - Vibrant, modern, and engaging
          Center(
            child: Column(
              children: [
                Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
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
                  'Selamat Datang, Encik $fullName',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Portal Perak Digital 2.0',
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30.0),
          // User Info Card
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
                      'Saya akui bahawa keterangan yang saya beri adalah benar. Saya memahami bahawa sekiranya maklumat itu didapati palsu, permohonan saya akan terbatal dan jika saya telah ditawarkan jawatan, perkhidmatan saya akan ditamatkan.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.0,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                    value: _isAcknowledged,
                    onChanged: (value) {
                      if (value != null && !_isAcknowledged) {
                        _saveAcknowledgment(value);
                        profileBox.put('verifiedAt', DateTime.now().toString());
                      }
                      if (value != null && !_isAcknowledged) {
                        _saveAcknowledgment(value);
                      }
                    },
                    activeColor: AppColors.primary,
                    checkColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          // Warning Notice Section - Bold and Attention-grabbing
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            color: Colors.red.shade50,
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700, size: 40),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Text(
                      'PERINGATAN: Sila lengkapi Maklumat Peribadi terlebih dahulu sebelum memohon sebarang jawatan kosong. Kemaskini Maklumat Peribadi',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
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