import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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

  // For the Resume Section dynamic data
  List<Map<String, String>> skillsList = [];
  List<Map<String, String>> languagesList = [];
  List<Map<String, String>> sukanList = [];
  String pengalamanValue = '';
  Map<String, bool> kesihatanMap = {'isHealthy': true}; // Placeholder

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

    // Load resume data from Hive
    final storedSkills = profileBox.get('skillsList', defaultValue: []);
    if (storedSkills is List) {
      skillsList = List<Map<String, String>>.from(storedSkills);
    }

    final storedLanguages = profileBox.get('languagesList', defaultValue: []);
    if (storedLanguages is List) {
      languagesList = List<Map<String, String>>.from(storedLanguages);
    }

    final storedSukan = profileBox.get('sukanList', defaultValue: []);
    if (storedSukan is List) {
      sukanList = List<Map<String, String>>.from(storedSukan);
    }

    pengalamanValue = profileBox.get('pengalaman', defaultValue: '');

    final storedKesihatan = profileBox.get('kesihatanMap', defaultValue: {});
    if (storedKesihatan is Map) {
      kesihatanMap = Map<String, bool>.from(storedKesihatan);
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

  Future<void> _saveListData(String key, List<Map<String, String>> list) async {
    setState(() {
      isSaving = true;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await profileBox.put(key, list);
      } finally {
        if (mounted) {
          setState(() {
            isSaving = false;
          });
        }
      }
    });
  }

  Future<void> _savePengalaman(String value) async {
    setState(() {
      isSaving = true;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await profileBox.put('pengalaman', value);
      } finally {
        if (mounted) {
          setState(() {
            isSaving = false;
          });
        }
      }
    });
  }

  Future<void> _saveKesihatan(Map<String, bool> data) async {
    setState(() {
      isSaving = true;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await profileBox.put('kesihatanMap', data);
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
    final List<String> pageTitles = [
      'Personal Info',
      'Family Info',
      'Academics',
      'Resume',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
      child: Column(
        children: [
          // Arrows with labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Page Button
              if (_currentPageIndex > 0)
                GestureDetector(
                  onTap: () => _navigateToPage(_currentPageIndex - 1),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _navigateToPage(_currentPageIndex - 1),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12.0),
                          backgroundColor: _getArrowColor(_currentPageIndex - 1),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pageTitles[_currentPageIndex - 1],
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 80),

              // Next Page Button
              if (_currentPageIndex < pageTitles.length - 1)
                GestureDetector(
                  onTap: () => _navigateToPage(_currentPageIndex + 1),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _navigateToPage(_currentPageIndex + 1),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12.0),
                          backgroundColor: _getArrowColor(_currentPageIndex + 1),
                        ),
                        child: const Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pageTitles[_currentPageIndex + 1],
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 80),
            ],
          ),
          const SizedBox(height: 16.0),
          // Page indicators
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
                  label: 'Resume',
                  activeColor: Colors.red,
                ),
              ),
            ],
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

    // Instead of a simple ReusableProfileForm for resume, we now have a custom dynamic section.
    final resumeSection = _buildResumeSection();

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
                    resumeSection,
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

  Widget _buildResumeSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
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
            // Skills Section
            Text("Skills", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildDynamicList(
              listData: skillsList,
              onAdd: () {
                setState(() {
                  skillsList.add({'skillName': '', 'skillLevel': ''});
                });
                _saveListData('skillsList', skillsList);
              },
              onRemove: (index) {
                setState(() {
                  skillsList.removeAt(index);
                });
                _saveListData('skillsList', skillsList);
              },
              fieldsBuilder: (index) {
                return Column(
                  children: [
                    TextFormField(
                      initialValue: skillsList[index]['skillName'],
                      decoration: const InputDecoration(labelText: 'Skill Name'),
                      onChanged: (val) {
                        skillsList[index]['skillName'] = val;
                        _saveListData('skillsList', skillsList);
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Skill Level'),
                      value: skillsList[index]['skillLevel']!.isEmpty ? null : skillsList[index]['skillLevel'],
                      onChanged: (val) {
                        if (val != null) {
                          skillsList[index]['skillLevel'] = val;
                          _saveListData('skillsList', skillsList);
                        }
                      },
                      items: ['SANGAT MAHIR', 'MAHIR', 'KURANG MAHIR']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
            // Languages Section
            Text("Languages", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildDynamicList(
              listData: languagesList,
              onAdd: () {
                setState(() {
                  languagesList.add({'languageName': '', 'languageLevel': ''});
                });
                _saveListData('languagesList', languagesList);
              },
              onRemove: (index) {
                setState(() {
                  languagesList.removeAt(index);
                });
                _saveListData('languagesList', languagesList);
              },
              fieldsBuilder: (index) {
                return Column(
                  children: [
                    TextFormField(
                      initialValue: languagesList[index]['languageName'],
                      decoration: const InputDecoration(labelText: 'Language Name'),
                      onChanged: (val) {
                        languagesList[index]['languageName'] = val;
                        _saveListData('languagesList', languagesList);
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Proficiency'),
                      value: languagesList[index]['languageLevel']!.isEmpty ? null : languagesList[index]['languageLevel'],
                      onChanged: (val) {
                        if (val != null) {
                          languagesList[index]['languageLevel'] = val;
                          _saveListData('languagesList', languagesList);
                        }
                      },
                      items: ['SANGAT FASIH', 'FASIH', 'KURANG FASIH']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
            // Sukan Section
            Text("Sukan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildDynamicList(
              listData: sukanList,
              onAdd: () {
                setState(() {
                  sukanList.add({'year': '', 'sportName': '', 'sportLevel': ''});
                });
                _saveListData('sukanList', sukanList);
              },
              onRemove: (index) {
                setState(() {
                  sukanList.removeAt(index);
                });
                _saveListData('sukanList', sukanList);
              },
              fieldsBuilder: (index) {
                return Column(
                  children: [
                    TextFormField(
                      initialValue: sukanList[index]['year'],
                      decoration: const InputDecoration(labelText: 'Year'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        sukanList[index]['year'] = val;
                        _saveListData('sukanList', sukanList);
                      },
                    ),
                    TextFormField(
                      initialValue: sukanList[index]['sportName'],
                      decoration: const InputDecoration(labelText: 'Sports Name'),
                      onChanged: (val) {
                        sukanList[index]['sportName'] = val;
                        _saveListData('sukanList', sukanList);
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Level'),
                      value: sukanList[index]['sportLevel']!.isEmpty ? null : sukanList[index]['sportLevel'],
                      onChanged: (val) {
                        if (val != null) {
                          sukanList[index]['sportLevel'] = val;
                          _saveListData('sukanList', sukanList);
                        }
                      },
                      items: ['Antarabangsa', 'Kebangsaan', 'Negeri', 'Daerah']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
            // Pengalaman Section
            Text("Pengalaman", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Tempoh Pengalaman'),
              value: pengalamanValue.isEmpty ? null : pengalamanValue,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    pengalamanValue = val;
                  });
                  _savePengalaman(pengalamanValue);
                }
              },
              items: ['Kurang Setahun', 'Kurang Tiga Tahun', 'Lebih Tiga Tahun']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),

            const SizedBox(height: 30),
            // Kesihatan Section (Placeholder)
            Text("Kesihatan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Adakah anda sihat?", style: GoogleFonts.poppins(fontSize: 16)),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: kesihatanMap['isHealthy'],
                  onChanged: (val) {
                    if (val != null) {
                      kesihatanMap['isHealthy'] = val;
                      _saveKesihatan(kesihatanMap);
                      setState(() {});
                    }
                  },
                ),
                const Text("Ya"),
                Radio<bool>(
                  value: false,
                  groupValue: kesihatanMap['isHealthy'],
                  onChanged: (val) {
                    if (val != null) {
                      kesihatanMap['isHealthy'] = val;
                      _saveKesihatan(kesihatanMap);
                      setState(() {});
                    }
                  },
                ),
                const Text("Tidak"),
              ],
            ),
            // Additional Kesihatan logic or fields can be added here
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicList({
    required List<Map<String, String>> listData,
    required Widget Function(int) fieldsBuilder,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Column(
      children: [
        for (int i = 0; i < listData.length; i++)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                fieldsBuilder(i),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => onRemove(i),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Remove"),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onAdd,
          child: const Text("Add"),
        ),
      ],
    );
  }
}
