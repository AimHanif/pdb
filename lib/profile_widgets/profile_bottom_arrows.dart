import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileBottomArrows extends StatelessWidget {
  final int currentPageIndex;
  final ValueChanged<int> onPageTapped;

  const ProfileBottomArrows({
    Key? key,
    required this.currentPageIndex,
    required this.onPageTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> pageTitles = [
      'Info Peribadi',
      'Info Keluarga',
      'Akademik',
      'Resume',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous page
          if (currentPageIndex > 0)
            GestureDetector(
              onTap: () => onPageTapped(currentPageIndex - 1),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => onPageTapped(currentPageIndex - 1),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12.0),
                      backgroundColor: _getArrowColor(currentPageIndex - 1),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pageTitles[currentPageIndex - 1],
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

          // Next page
          if (currentPageIndex < pageTitles.length - 1)
            GestureDetector(
              onTap: () => onPageTapped(currentPageIndex + 1),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => onPageTapped(currentPageIndex + 1),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12.0),
                      backgroundColor: _getArrowColor(currentPageIndex + 1),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pageTitles[currentPageIndex + 1],
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
}
