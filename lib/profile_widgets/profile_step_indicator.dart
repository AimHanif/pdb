import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileStepIndicator extends StatelessWidget {
  final int currentPageIndex;
  final ValueChanged<int> onPageTapped;

  const ProfileStepIndicator({
    Key? key,
    required this.currentPageIndex,
    required this.onPageTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StepIndicatorItem(
            isActive: currentPageIndex == 0,
            label: 'Info Peribadi',
            activeColor: Colors.orange,
            onTap: () => onPageTapped(0),
          ),
          const SizedBox(width: 20),
          _StepIndicatorItem(
            isActive: currentPageIndex == 1,
            label: 'Info Keluarga',
            activeColor: Colors.purple,
            onTap: () => onPageTapped(1),
          ),
          const SizedBox(width: 20),
          _StepIndicatorItem(
            isActive: currentPageIndex == 2,
            label: 'Akademik',
            activeColor: Colors.blue,
            onTap: () => onPageTapped(2),
          ),
          const SizedBox(width: 20),
          _StepIndicatorItem(
            isActive: currentPageIndex == 3,
            label: 'Resume',
            activeColor: Colors.red,
            onTap: () => onPageTapped(3),
          ),
        ],
      ),
    );
  }
}

class _StepIndicatorItem extends StatelessWidget {
  final bool isActive;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;

  const _StepIndicatorItem({
    Key? key,
    required this.isActive,
    required this.label,
    required this.activeColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}
