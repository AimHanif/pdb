import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdb/profile_widgets/profile_bottom_arrows.dart';
import 'package:pdb/profile_widgets/profile_section_view.dart';
import 'package:pdb/profile_widgets/profile_step_indicator.dart';
import 'package:pdb/profile_widgets/resume_section.dart';
import 'package:pdb/profile_widgets/resume_section_view.dart';
import 'package:pdb/widgets/custom_app_bar.dart';

// Widgets (moved to separate files)
import 'colors.dart';
import 'login.dart';
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

  // For user profile image
  File? _profileImage;

  // Controllers for all fields
  final Map<String, TextEditingController> controllers = {};

  // For saving/loading data
  bool isSaving = false;
  Timer? _debounce;

  // For the Resume Section dynamic data
  List<Map<String, String>> skillsList = [];
  List<Map<String, String>> languagesList = [];
  List<Map<String, String>> sukanList = [];
  String pengalamanValue = '';
  bool isHealthy = true; // For "kesihatan"

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    profileBox = await Hive.openBox('profileData');

    // Initialize controllers for Personal, Family, Academics
    final allFields = [...personalFields, ...familyFields, ...academicsFields];
    for (var f in allFields) {
      final defaultValue = profileBox.get(f.key, defaultValue: '');
      controllers[f.key] = TextEditingController(text: defaultValue);
    }

    // Load image if exists
    String? imagePath = profileBox.get('profileImagePath');
    if (imagePath != null && File(imagePath).existsSync()) {
      _profileImage = File(imagePath);
    }

    // Load and validate skills list
    final storedSkills = profileBox.get('skillsList', defaultValue: []);
    if (storedSkills is List) {
      skillsList = storedSkills
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => e.map((key, value) => MapEntry(key.toString(), value.toString())))
          .toList();
    }

    // Load and validate languages list
    final storedLanguages = profileBox.get('languagesList', defaultValue: []);
    if (storedLanguages is List) {
      languagesList = storedLanguages
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => e.map((key, value) => MapEntry(key.toString(), value.toString())))
          .toList();
    }

    // Load and validate sukan list
    final storedSukan = profileBox.get('sukanList', defaultValue: []);
    if (storedSukan is List) {
      sukanList = storedSukan
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => e.map((key, value) => MapEntry(key.toString(), value.toString())))
          .toList();
    }

    pengalamanValue = profileBox.get('pengalaman', defaultValue: '');

    final storedKesihatan = profileBox.get('kesihatan', defaultValue: true);
    if (storedKesihatan is bool) {
      isHealthy = storedKesihatan;
    }

    setState(() {});
  }

  // -- Saving logic ------------------------------------------------
  Future<void> _saveData(String key, String value) async {
    setState(() => isSaving = true);
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await profileBox.put(key, value);
      } finally {
        if (mounted) {
          setState(() => isSaving = false);
        }
      }
    });
  }

  Future<void> _saveListData(String key, List<Map<String, String>> list) async {
    setState(() => isSaving = true);
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await profileBox.put(key, list);
      } finally {
        if (mounted) {
          setState(() => isSaving = false);
        }
      }
    });
  }

  Future<void> _saveKesihatan(String key, bool value) async {
    setState(() => isSaving = true);
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await profileBox.put(key, value);
      } finally {
        if (mounted) {
          setState(() => isSaving = false);
        }
      }
    });
  }

  // -- Page navigation logic ----------------------------------------
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

  // -- Image picking logic ------------------------------------------
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File? croppedFile = await _cropImage(File(pickedFile.path));

        if (croppedFile != null) {
          setState(() => _profileImage = croppedFile);
          await _saveData('profileImagePath', croppedFile.path);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
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
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If controllers are not yet initialized, show a loading indicator
    if (controllers.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Build the specific forms for each section
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
    final resumeSection = ResumeSection(
      skillsList: skillsList,
      languagesList: languagesList,
      sukanList: sukanList,
      pengalamanList: pengalamanValue.isNotEmpty
          ? [{'experienceName': pengalamanValue, 'duration': ''}]
          : [],
      isHealthy: isHealthy,
      onSaveSkills: (key, list) => _saveListData(key, list),
      onSaveLanguages: (key, list) => _saveListData(key, list),
      onSaveSukan: (key, list) => _saveListData(key, list),
      onSavePengalaman: (key, list) => _saveListData(key, list),
      onSaveKesihatan: (key, value) => _saveKesihatan(key, value),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Profil',
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // STEP INDICATORS (moved to profile_step_indicator.dart)
              ProfileStepIndicator(
                currentPageIndex: _currentPageIndex,
                onPageTapped: _navigateToPage,
              ),
              // MAIN PAGEVIEW
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    // Personal Section
                    ProfileSectionView(
                      currentPageIndex: _currentPageIndex,
                      pageIndex: 0,
                      formWidget: personalForm,
                      imageFile: _profileImage,
                      onImagePick: _pickImage,
                    ),
                    // Family Section
                    ProfileSectionView(
                      currentPageIndex: _currentPageIndex,
                      pageIndex: 1,
                      formWidget: familyForm,
                    ),
                    // Academics Section
                    ProfileSectionView(
                      currentPageIndex: _currentPageIndex,
                      pageIndex: 2,
                      formWidget: academicsForm,
                    ),
                    // Resume Section
                    ResumeSectionView(
                      resumeWidget: resumeSection,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Saving Indicator
          if (isSaving)
            Positioned(
              top: 20.0,
              right: 20.0,
              child: Container(
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
                      'Menyimpan...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // BOTTOM NAVIGATION BAR (includes the bottom arrows)
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // BOTTOM ARROWS (moved to profile_bottom_arrows.dart)
          ProfileBottomArrows(
            currentPageIndex: _currentPageIndex,
            onPageTapped: _navigateToPage,
          ),
          CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
