import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'colors.dart';
import 'navbar.dart';
import 'profile_config.dart';
import 'reusable_profile_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;
  late Box profileBox;
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  File? _profileImage;

  final Map<String, TextEditingController> controllers = {};

  bool isSaving = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    profileBox = await Hive.openBox('profileData');

    // Gather all fields: Personal, Family, Academics, Skills
    final allFields = [...personalFields, ...familyFields, ...academicsFields, ...skillsFields];

    for (var f in allFields) {
      final defaultValue = profileBox.get(f.key, defaultValue: '');
      controllers[f.key] = TextEditingController(text: defaultValue);
    }

    String? imagePath = profileBox.get('profileImagePath');
    if (imagePath != null && File(imagePath).existsSync()) {
      _profileImage = File(imagePath);
    }

    setState(() {});
  }

  Future<void> _saveData(String key, String value) async {
    setState(() {
      isSaving = true;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await profileBox.put(key, value);
      } finally {
        if (mounted) {
          setState(() {
            isSaving = false;
          });
        }
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File? croppedFile = await _cropImage(File(pickedFile.path));

        if (croppedFile != null) {
          setState(() {
            _profileImage = croppedFile;
          });
          await _saveData('profileImagePath', croppedFile.path);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  Widget _buildPageIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 4 sections: 0=Personal,1=Family,2=Academics,3=Skills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _navigateToPage(0),
                child: _buildStepIndicator(
                  isActive: _currentPageIndex == 0,
                  label: 'Personal Info',
                  activeColor: Colors.orange,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _navigateToPage(1),
                child: _buildStepIndicator(
                  isActive: _currentPageIndex == 1,
                  label: 'Family Info',
                  activeColor: Colors.purple,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _navigateToPage(2),
                child: _buildStepIndicator(
                  isActive: _currentPageIndex == 2,
                  label: 'Academics',
                  activeColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _navigateToPage(3),
                child: _buildStepIndicator(
                  isActive: _currentPageIndex == 3,
                  label: 'Skills',
                  activeColor: Colors.red,
                ),
              ),
            ],
          ),
          if (_currentPageIndex > 0)
            Positioned(
              left: 0,
              child: GestureDetector(
                onTap: () => _navigateToPage(_currentPageIndex - 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getArrowColor(_currentPageIndex - 1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (_currentPageIndex < 3)
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () => _navigateToPage(_currentPageIndex + 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getArrowColor(_currentPageIndex + 1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required bool isActive,
    required String label,
    required Color activeColor,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 10.0,
          backgroundColor: isActive ? activeColor : Colors.grey,
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.0,
            color: isActive ? activeColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getArrowColor(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.purple;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controllers.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final personalForm = ReusableProfileForm(
      fields: personalFields,
      controllers: controllers,
      onSave: _saveData,
    );

    final familyForm = ReusableProfileForm(
      fields: familyFields,
      controllers: controllers,
      onSave: _saveData,
    );

    final academicsForm = ReusableProfileForm(
      fields: academicsFields,
      controllers: controllers,
      onSave: _saveData,
    );

    final skillsForm = ReusableProfileForm(
      fields: skillsFields,
      controllers: controllers,
      onSave: _saveData,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildPageIndicators(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildSectionView(personalForm, _profileImage),
                    _buildSectionView(familyForm, null),
                    _buildSectionView(academicsForm, null),
                    _buildSectionView(skillsForm, null),
                  ],
                ),
              ),
            ],
          ),
          // Saving indicator
          Positioned(
            top: 20.0,
            right: 20.0,
            child: AnimatedOpacity(
              opacity: isSaving ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: isSaving
                  ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Saving...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
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

  Widget _buildSectionView(Widget formWidget, File? imageFile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_currentPageIndex == 0) // Only show profile image in Personal Info section
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20.0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundColor: AppColors.accent.withOpacity(0.1),
                    backgroundImage: imageFile != null ? FileImage(imageFile) : null,
                    child: imageFile == null
                        ? Icon(
                      FontAwesomeIcons.user,
                      size: 50.0,
                      color: AppColors.primary.withOpacity(0.8),
                    )
                        : null,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24.0),
          Container(
            padding: const EdgeInsets.all(16.0),
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
            child: formWidget,
          ),
        ],
      ),
    );
  }
}
