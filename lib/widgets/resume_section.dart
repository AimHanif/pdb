// resume_section.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

typedef SaveListCallback = void Function(String key, List<Map<String, String>> list);
typedef SaveSingleCallback = void Function(String key, String value);
typedef SaveKesihatanCallback = void Function(String key, bool value);

class ResumeSection extends StatefulWidget {
  final List<Map<String, String>> skillsList;
  final List<Map<String, String>> languagesList;
  final List<Map<String, String>> sukanList;
  final List<Map<String, String>> pengalamanList; // Changed from pengalamanValue
  final bool isHealthy;

  final SaveListCallback onSaveSkills;
  final SaveListCallback onSaveLanguages;
  final SaveListCallback onSaveSukan;
  final SaveListCallback onSavePengalaman; // Updated to SaveListCallback
  final SaveKesihatanCallback onSaveKesihatan;

  const ResumeSection({
    super.key,
    required this.skillsList,
    required this.languagesList,
    required this.sukanList,
    required this.pengalamanList, // Updated
    required this.isHealthy,
    required this.onSaveSkills,
    required this.onSaveLanguages,
    required this.onSaveSukan,
    required this.onSavePengalaman, // Updated
    required this.onSaveKesihatan,
  });

  @override
  State<ResumeSection> createState() => _ResumeSectionState();
}

class _ResumeSectionState extends State<ResumeSection> {
  late List<Map<String, String>> skillsList;
  late List<Map<String, String>> languagesList;
  late List<Map<String, String>> sukanList;
  late List<Map<String, String>> pengalamanList; // Added
  late bool isHealthy;

  @override
  void initState() {
    super.initState();
    skillsList = List<Map<String, String>>.from(widget.skillsList);
    languagesList = List<Map<String, String>>.from(widget.languagesList);
    sukanList = List<Map<String, String>>.from(widget.sukanList);
    pengalamanList = List<Map<String, String>>.from(widget.pengalamanList); // Initialized
    isHealthy = widget.isHealthy;
  }

  final InputDecoration inputDecoration = InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
    ),
    hintStyle: GoogleFonts.poppins(
      fontSize: 14.0,
      color: AppColors.textSecondary.withOpacity(0.8),
    ),
  );

  final TextStyle labelStyle = GoogleFonts.poppins(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  final TextStyle headingStyle = GoogleFonts.poppins(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  Widget buildLabeledField(String labelText, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText, style: labelStyle),
          const SizedBox(height: 8.0),
          field,
        ],
      ),
    );
  }

  Widget buildDynamicList({
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
              color: AppColors.cardBackground,
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
                    child: const Text(
                      "Keluarkan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text(
            "Tambah",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Ensures content is scrollable
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills Section
          Text("Kemahiran", style: headingStyle),
          const SizedBox(height: 10),
          buildDynamicList(
            listData: skillsList,
            onAdd: () {
              setState(() {
                skillsList.add({'skillName': '', 'skillLevel': ''});
              });
              widget.onSaveSkills('skillsList', skillsList);
            },
            onRemove: (index) {
              setState(() {
                skillsList.removeAt(index);
              });
              widget.onSaveSkills('skillsList', skillsList);
            },
            fieldsBuilder: (index) {
              return Column(
                children: [
                  buildLabeledField(
                    'Nama Kemahiran (Contoh: Memasak)',
                    TextFormField(
                      initialValue: skillsList[index]['skillName'],
                      decoration: inputDecoration.copyWith(hintText: 'e.g. Memasak'),
                      onChanged: (val) {
                        skillsList[index]['skillName'] = val;
                        widget.onSaveSkills('skillsList', skillsList);
                      },
                    ),
                  ),
                  buildLabeledField(
                    'Tahap Kemahiran',
                    DropdownButtonFormField<String>(
                      decoration: inputDecoration.copyWith(hintText: 'Pilih Tahap Kemahiran'),
                      value: skillsList[index]['skillLevel']!.isEmpty ? null : skillsList[index]['skillLevel'],
                      onChanged: (val) {
                        if (val != null) {
                          skillsList[index]['skillLevel'] = val;
                          widget.onSaveSkills('skillsList', skillsList);
                        }
                      },
                      items: ['SANGAT MAHIR', 'MAHIR', 'KURANG MAHIR']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),
          // Languages Section
          Text("Bahasa", style: headingStyle),
          const SizedBox(height: 10),
          buildDynamicList(
            listData: languagesList,
            onAdd: () {
              setState(() {
                languagesList.add({'languageName': '', 'languageLevel': ''});
              });
              widget.onSaveLanguages('languagesList', languagesList);
            },
            onRemove: (index) {
              setState(() {
                languagesList.removeAt(index);
              });
              widget.onSaveLanguages('languagesList', languagesList);
            },
            fieldsBuilder: (index) {
              return Column(
                children: [
                  buildLabeledField(
                    'Nama Bahasa (Contoh: Bahasa Melayu)',
                    TextFormField(
                      initialValue: languagesList[index]['languageName'],
                      decoration: inputDecoration.copyWith(hintText: 'e.g. Bahasa Melayu'),
                      onChanged: (val) {
                        languagesList[index]['languageName'] = val;
                        widget.onSaveLanguages('languagesList', languagesList);
                      },
                    ),
                  ),
                  buildLabeledField(
                    'Tahap Kepakaran Bahasa',
                    DropdownButtonFormField<String>(
                      decoration: inputDecoration.copyWith(hintText: 'Pilih Tahap Kepakaran Bahasa'),
                      value: languagesList[index]['languageLevel']!.isEmpty ? null : languagesList[index]['languageLevel'],
                      onChanged: (val) {
                        if (val != null) {
                          languagesList[index]['languageLevel'] = val;
                          widget.onSaveLanguages('languagesList', languagesList);
                        }
                      },
                      items: ['SANGAT FASIH', 'FASIH', 'KURANG FASIH']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),
          // Sukan Section
          Text("Sukan", style: headingStyle),
          const SizedBox(height: 10),
          buildDynamicList(
            listData: sukanList,
            onAdd: () {
              setState(() {
                sukanList.add({'year': '', 'sportName': '', 'sportLevel': ''});
              });
              widget.onSaveSukan('sukanList', sukanList);
            },
            onRemove: (index) {
              setState(() {
                sukanList.removeAt(index);
              });
              widget.onSaveSukan('sukanList', sukanList);
            },
            fieldsBuilder: (index) {
              return Column(
                children: [
                  buildLabeledField(
                    'Tahun Penyertaan Sukan',
                    TextFormField(
                      initialValue: sukanList[index]['year'],
                      decoration: inputDecoration.copyWith(hintText: 'e.g. 2020'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        sukanList[index]['year'] = val;
                        widget.onSaveSukan('sukanList', sukanList);
                      },
                    ),
                  ),
                  buildLabeledField(
                    'Nama Sukan',
                    TextFormField(
                      initialValue: sukanList[index]['sportName'],
                      decoration: inputDecoration.copyWith(hintText: 'e.g. Bola Sepak'),
                      onChanged: (val) {
                        sukanList[index]['sportName'] = val;
                        widget.onSaveSukan('sukanList', sukanList);
                      },
                    ),
                  ),
                  buildLabeledField(
                    'Tahap Penyertaan Sukan',
                    DropdownButtonFormField<String>(
                      decoration: inputDecoration.copyWith(hintText: 'Pilih Tahap Penyertaan Sukan'),
                      value: sukanList[index]['sportLevel']!.isEmpty ? null : sukanList[index]['sportLevel'],
                      onChanged: (val) {
                        if (val != null) {
                          sukanList[index]['sportLevel'] = val;
                          widget.onSaveSukan('sukanList', sukanList);
                        }
                      },
                      items: ['Antarabangsa', 'Kebangsaan', 'Negeri', 'Daerah']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),
          // Pengalaman Section
          Text("Pengalaman", style: headingStyle),
          const SizedBox(height: 10),
          buildDynamicList(
            listData: pengalamanList,
            onAdd: () {
              setState(() {
                pengalamanList.add({'duration': '', 'experienceName': ''}); // Define appropriate fields
              });
              widget.onSavePengalaman('pengalamanList', pengalamanList);
            },
            onRemove: (index) {
              setState(() {
                pengalamanList.removeAt(index);
              });
              widget.onSavePengalaman('pengalamanList', pengalamanList);
            },
            fieldsBuilder: (index) {
              return Column(
                children: [
                  buildLabeledField(
                    'Tempoh Pengalaman',
                    TextFormField(
                      initialValue: pengalamanList[index]['duration'],
                      decoration: inputDecoration.copyWith(hintText: 'e.g. 2 tahun'),
                      onChanged: (val) {
                        pengalamanList[index]['duration'] = val;
                        widget.onSavePengalaman('pengalamanList', pengalamanList);
                      },
                    ),
                  ),
                  buildLabeledField(
                    'Nama Pengalaman',
                    TextFormField(
                      initialValue: pengalamanList[index]['experienceName'],
                      decoration: inputDecoration.copyWith(hintText: 'e.g. Pembangunan Perisian'),
                      onChanged: (val) {
                        pengalamanList[index]['experienceName'] = val;
                        widget.onSavePengalaman('pengalamanList', pengalamanList);
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),
          // Kesihatan Section
          Text("Kesihatan", style: headingStyle),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Adakah anda sihat?", style: labelStyle),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isHealthy,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            isHealthy = val;
                          });
                          widget.onSaveKesihatan('kesihatan', isHealthy);
                        }
                      },
                    ),
                    Text("Ya", style: GoogleFonts.poppins(color: AppColors.primary)),
                    Radio<bool>(
                      value: false,
                      groupValue: isHealthy,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            isHealthy = val;
                          });
                          widget.onSaveKesihatan('kesihatan', isHealthy);
                        }
                      },
                    ),
                    Text("Tidak", style: GoogleFonts.poppins(color: AppColors.primary)),
                  ],
                ),
                // Tambahan logik atau medan Kesihatan boleh ditambah di sini
              ],
            ),
          ),
          const SizedBox(height: 30), // Optional spacing at the bottom
        ],
      ),
    );
  }
}
