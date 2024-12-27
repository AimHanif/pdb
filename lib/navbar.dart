// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:pdb/profile_screen.dart';
import 'colors.dart';
import 'home_screen.dart';
import 'main_menu.dart';
import 'route_transitions.dart'; // Importing the custom route transitions

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          createRoute(const HomeScreen(), type: TransitionType.fade),
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          createRoute(const MainMenu(), type: TransitionType.fade),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          createRoute(const ProfileScreen(), type: TransitionType.fade),
        );
        break;
    }
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Softer, less colorful background gradient
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.blueGrey.shade50, // Very subtle hint of blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10.0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        child: BottomNavigationBar(
          items: [
            _buildBottomNavItem(Icons.home, 'Home', 0),
            _buildBottomNavItem(Icons.dashboard, 'Menu', 1),
            _buildBottomNavItem(Icons.info, 'Profile', 2),
          ],
          currentIndex: widget.selectedIndex,
          onTap: _onNavItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = widget.selectedIndex == index;

    // Softer highlight gradient for selected item
    final selectedGradient = LinearGradient(
      colors: [Colors.blueAccent, Colors.lightBlueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final iconColor = isSelected ? Colors.white : Colors.black87;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        // Reduced padding to decrease overall height
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
            : const EdgeInsets.all(6.0),
        decoration: isSelected
            ? BoxDecoration(
          gradient: selectedGradient,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        )
            : null,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Row(
            key: ValueKey<bool>(isSelected),
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: isSelected ? 0.05 : 0.0, // Slight rotation if selected
                child: Icon(
                  icon,
                  size: isSelected ? 28.0 : 24.0, // Slightly smaller icons
                  color: iconColor,
                ),
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      label: label,
    );
  }
}
