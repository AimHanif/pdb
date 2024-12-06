import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'colors.dart';
import 'navbar.dart';

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

  final TextEditingController fullNameController =
  TextEditingController(text: 'MUHAMAD HAZRIN HAKIM BIN HAZINOL');
  final TextEditingController idNumberController =
  TextEditingController(text: '030722080901');
  final TextEditingController phoneNumberController =
  TextEditingController(text: '0174869055');
  final TextEditingController emailController =
  TextEditingController(text: 'hazrinhakim35@gmail.com');
  final TextEditingController birthDateController =
  TextEditingController(text: '22/07/2003');
  final TextEditingController ageController = TextEditingController(text: '21');
  final TextEditingController birthPlaceController =
  TextEditingController(text: 'PERAK');
  final TextEditingController genderController =
  TextEditingController(text: 'LELAKI');
  final TextEditingController statusController =
  TextEditingController(text: 'AWAM');

  final TextEditingController spouseNameController = TextEditingController();
  final TextEditingController spouseJobController = TextEditingController();
  final TextEditingController spouseIncomeController = TextEditingController();
  final TextEditingController fatherNameController =
  TextEditingController(text: 'HAZINOL BIN ABDULLAH');
  final TextEditingController motherNameController =
  TextEditingController(text: 'MUSLINA BINTI MUHAMAD');
  final TextEditingController fatherIDController =
  TextEditingController(text: '780505085231');
  final TextEditingController motherIDController =
  TextEditingController(text: '790601085388');
  final TextEditingController fatherBirthPlaceController =
  TextEditingController(text: 'PERAK');
  final TextEditingController motherBirthPlaceController =
  TextEditingController(text: 'PERAK');
  final TextEditingController fatherJobController = TextEditingController(
      text: 'PLUS BHD(PEMBANTU KHIDMAT PELANGGAN)');
  final TextEditingController motherJobController =
  TextEditingController(text: 'SURI RUMAH');
  final TextEditingController familyMembersController =
  TextEditingController(text: '6');
  final TextEditingController siblingOrderController =
  TextEditingController(text: 'KEDUA');

  // Academics Controllers (not fully shown for brevity)
  final TextEditingController pt3YearController = TextEditingController();
  final TextEditingController pt3ExamController = TextEditingController();
  final TextEditingController pt3RankController = TextEditingController();
  final TextEditingController spmYearController = TextEditingController();
  final TextEditingController spmCertificateTypeController =
  TextEditingController();
  final TextEditingController spmRankController = TextEditingController();
  final TextEditingController svmYearController = TextEditingController();
  final TextEditingController svmCertificateTypeController =
  TextEditingController();
  final TextEditingController svmAcademicGPAController = TextEditingController();
  final TextEditingController svmVocationalGPAController =
  TextEditingController();
  final TextEditingController skmYearController = TextEditingController();
  final TextEditingController skmCertificateTypeController =
  TextEditingController();
  final TextEditingController stpmYearController = TextEditingController();
  final TextEditingController stpmExamTypeController = TextEditingController();
  final TextEditingController matriculationCertificateTypeController =
  TextEditingController();
  final TextEditingController matriculationCourseController =
  TextEditingController();
  final TextEditingController matriculationSessionController =
  TextEditingController();
  final TextEditingController matriculationCollegeController =
  TextEditingController();
  final TextEditingController matriculationCGPAController =
  TextEditingController();
  final TextEditingController higherEducationInstitutionController =
  TextEditingController();
  final TextEditingController higherEducationQualificationController =
  TextEditingController();
  final TextEditingController higherEducationFieldController =
  TextEditingController();
  final TextEditingController higherEducationGraduationDateController =
  TextEditingController();
  final TextEditingController higherEducationCGPAController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    print('[DEBUG] Initializing Hive...');
    await Hive.initFlutter();
    profileBox = await Hive.openBox('profileData');
    print('[DEBUG] Hive box "profileData" opened successfully.');

    // Load saved values for the controllers
    fullNameController.text =
        profileBox.get('fullName', defaultValue: fullNameController.text);
    idNumberController.text =
        profileBox.get('idNumber', defaultValue: idNumberController.text);

    print('[DEBUG] Loaded fullName: ${fullNameController.text}');
    print('[DEBUG] Loaded idNumber: ${idNumberController.text}');

    // Load saved profile image path
    String? imagePath = profileBox.get('profileImagePath');
    print('[DEBUG] Loaded profileImagePath from Hive: $imagePath');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
      print('[DEBUG] Profile image file set: $imagePath');
    } else {
      print('[DEBUG] No saved profile image found or file does not exist.');
    }
  }

  Future<void> _saveData(String key, dynamic value) async {
    await profileBox.put(key, value);
    print('[DEBUG] Data saved: $key = $value');
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    print('[DEBUG] Page changed to index: $_currentPageIndex');
  }

  void _navigateToPage(int index) {
    print('[DEBUG] Navigating to page: $index');
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImage() async {
    try {
      print('[DEBUG] Picking image from gallery...');
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
      await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        print('[DEBUG] Image picked: ${pickedFile.path}');
        File? croppedFile = await _cropImage(File(pickedFile.path));

        if (croppedFile != null) {
          setState(() {
            _profileImage = croppedFile;
          });
          print('[DEBUG] Cropped image set to state: ${croppedFile.path}');
          await _saveData('profileImagePath', croppedFile.path);
          print('[DEBUG] Profile image path saved to Hive: ${croppedFile.path}');
        } else {
          print('[DEBUG] Cropping returned null, image not set.');
        }
      } else {
        print('[DEBUG] No image picked.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      print('[DEBUG] Cropping image: ${imageFile.path}');
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
        print('[DEBUG] Cropped image path: ${croppedFile.path}');
        return File(croppedFile.path);
      } else {
        print('[DEBUG] Cropped file is null.');
      }
      return null;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // Page Indicators and Arrow Buttons
          Container(
            padding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
                // Page Indicators
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
                  ],
                ),
                // Left Arrow Button
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
                // Right Arrow Button
                if (_currentPageIndex < 2)
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
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                buildPersonalInfoSection(),
                buildFamilyInfoSection(),
                buildAcademicsSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          print('[DEBUG] NavBar item tapped: $index');
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget buildPersonalInfoSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture Section
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
                  backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
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
          // User Information Fields
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
            child: Column(
              children: [
                buildInfoTextField('Nama Penuh', fullNameController, 'fullName'),
                buildInfoTextField(
                    'No. Kad Pengenalan', idNumberController, 'idNumber'),
                buildInfoTextField(
                    'No. Telefon Bimbit', phoneNumberController, 'phoneNumber'),
                buildInfoTextField('Alamat E-Mel', emailController, 'email'),
                buildInfoTextField(
                    'Tarikh Lahir', birthDateController, 'birthDate'),
                buildInfoTextField('Umur', ageController, 'age'),
                buildInfoTextField(
                    'Tempat Lahir', birthPlaceController, 'birthPlace'),
                buildInfoTextField('Jantina', genderController, 'gender'),
                buildInfoTextField('Status Diri', statusController, 'status'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFamilyInfoSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Family Information Fields
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
            child: Column(
              children: [
                buildInfoTextField('Nama Suami/Isteri', spouseNameController,
                    'spouseName'),
                buildInfoTextField('Pekerjaan Suami/Isteri',
                    spouseJobController, 'spouseJob'),
                buildInfoTextField('Pendapatan Suami/Isteri (RM)',
                    spouseIncomeController, 'spouseIncome'),
                buildInfoTextField(
                    'Nama Bapa', fatherNameController, 'fatherName'),
                buildInfoTextField(
                    'Nama Ibu', motherNameController, 'motherName'),
                buildInfoTextField('No. Kad Pengenalan Bapa',
                    fatherIDController, 'fatherID'),
                buildInfoTextField(
                    'No. Kad Pengenalan Ibu', motherIDController, 'motherID'),
                buildInfoTextField('Tempat Lahir Bapa',
                    fatherBirthPlaceController, 'fatherBirthPlace'),
                buildInfoTextField('Tempat Lahir Ibu',
                    motherBirthPlaceController, 'motherBirthPlace'),
                buildInfoTextField(
                    'Pekerjaan Bapa', fatherJobController, 'fatherJob'),
                buildInfoTextField(
                    'Pekerjaan Ibu', motherJobController, 'motherJob'),
                buildInfoTextField('Bilangan Ahli Keluarga',
                    familyMembersController, 'familyMembers'),
                buildInfoTextField(
                    'Anak Ke-', siblingOrderController, 'siblingOrder'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAcademicsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAcademicSectionCard('PT3/PMR/SRP', [
            buildInfoTextField('Tahun', pt3YearController, 'pt3Year'),
            buildInfoTextField('Peperiksaan', pt3ExamController, 'pt3Exam'),
            buildInfoTextField('Pangkat', pt3RankController, 'pt3Rank'),
          ]),
          // ... Add other academic sections as needed
        ],
      ),
    );
  }

  Widget buildAcademicSectionCard(String title, List<Widget> fields) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16.0),
          ...fields,
        ],
      ),
    );
  }

  Widget buildInfoTextField(
      String label, TextEditingController controller, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: controller,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              color: AppColors.textPrimary,
            ),
            onChanged: (value) {
              _saveData(key, value);
              print('[DEBUG] $key changed to $value');
            },
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide:
                BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide:
                BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.primary, width: 2.0),
              ),
              hintText: label,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14.0,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
      {required bool isActive, required String label, required Color activeColor}) {
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
      default:
        return Colors.grey;
    }
  }
}
