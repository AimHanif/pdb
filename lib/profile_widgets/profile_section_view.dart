import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../colors.dart';


class ProfileSectionView extends StatelessWidget {
  final int currentPageIndex;
  final int pageIndex;
  final Widget formWidget;
  final File? imageFile;
  final VoidCallback? onImagePick;

  const ProfileSectionView({
    Key? key,
    required this.currentPageIndex,
    required this.pageIndex,
    required this.formWidget,
    this.imageFile,
    this.onImagePick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Show avatar only if this is page 0
          if (pageIndex == 0 && currentPageIndex == 0)
            Center(
              child: GestureDetector(
                onTap: onImagePick,
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
                    backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
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
          // The white container that holds the form
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
