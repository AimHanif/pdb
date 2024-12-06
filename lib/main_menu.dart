import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Importing auto_size_text package for text resizing
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'navbar.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 1; // Default index to Main Menu

  final List<MenuOption> menuOptions = [
    MenuOption(icon: Icons.work, label: 'e-Perjawatan', hoverColor: Colors.deepOrange),
    MenuOption(icon: Icons.school, label: 'e-Internship', hoverColor: Colors.blue),
    MenuOption(icon: Icons.verified_user, label: 'e-Pensijilan Halal', hoverColor: Colors.green),
    MenuOption(icon: Icons.store, label: 'S.M.A.R.T Niaga', hoverColor: Colors.purple),
    MenuOption(icon: Icons.book_online, label: 'e-Tempahan', hoverColor: Colors.cyan),
    MenuOption(icon: Icons.help_outline, label: 'e-Bantuan', hoverColor: Colors.teal),
  ];

  final List<InformationOption> infoOptions = [
    InformationOption(imagePath: 'assets/test.png', label: 'Information 1', description: 'This is a brief description of Information 1.'),
    InformationOption(imagePath: 'assets/test.png', label: 'Information 2', description: 'This is a brief description of Information 2.'),
    InformationOption(imagePath: 'assets/test.png', label: 'Information 3', description: 'This is a brief description of Information 3.'),
    InformationOption(imagePath: 'assets/test.png', label: 'Information 4', description: 'This is a brief description of Information 4.'),
  ];

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
          'Menu',
          style: GoogleFonts.poppins(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Access Section Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Menu Buttons Section (2xN grid)
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 icons per row
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: menuOptions.length,
                itemBuilder: (context, index) {
                  final option = menuOptions[index];
                  return HoverEffectButton(
                    icon: option.icon,
                    label: option.label,
                    hoverColor: option.hoverColor,
                    onTap: () {
                      // Navigate based on the label
                      switch (option.label) {
                        case 'e-Perjawatan':
                          Navigator.pushNamed(context, '/ePerjawatan');
                          break;
                        case 'e-Internship':
                          Navigator.pushNamed(context, '/eInternship');
                          break;
                        case 'e-Pensijilan Halal':
                          Navigator.pushNamed(context, '/ePensijilanHalal');
                          break;
                        case 'S.M.A.R.T Niaga':
                          Navigator.pushNamed(context, '/smartNiaga');
                          break;
                        case 'e-Tempahan':
                          Navigator.pushNamed(context, '/eTempahan');
                          break;
                        case 'e-Bantuan':
                          Navigator.pushNamed(context, '/eBantuan');
                          break;
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30.0),
            // Information Section Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Information',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Information Carousel Section
            CarouselSlider(
              options: CarouselOptions(
                height: 320.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items: infoOptions.map((option) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10.0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16.0),
                              ),
                              child: Image.asset(
                                option.imagePath,
                                height: 150.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150.0,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image,
                                      size: 60.0,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: AutoSizeText(
                                option.label,
                                maxLines: 1,
                                minFontSize: 10,
                                maxFontSize: 16,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Text(
                              option.description,
                              style: GoogleFonts.poppins(
                                fontSize: 14.0,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
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
}

class MenuOption {
  final IconData icon;
  final String label;
  final Color hoverColor;

  MenuOption({required this.icon, required this.label, required this.hoverColor});
}

class InformationOption {
  final String imagePath;
  final String label;
  final String description;

  InformationOption({required this.imagePath, required this.label, required this.description});
}

class HoverEffectButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color hoverColor;
  final VoidCallback onTap;

  const HoverEffectButton({
    super.key,
    required this.icon,
    required this.label,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<HoverEffectButton> createState() => _HoverEffectButtonState();
}

class _HoverEffectButtonState extends State<HoverEffectButton> {
  bool _isHovered = false;

  void _setHover(bool hover) {
    setState(() => _isHovered = hover);
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = _isHovered ? 42.0 : 36.0;
    final double fontSize = _isHovered ? 16.0 : 14.0;

    // Determine colors based on hover state
    final iconColor = Colors.white;
    final textColor = Colors.white;

    // Icon and text widgets
    final iconWidget = Icon(
      widget.icon,
      size: iconSize,
      color: iconColor,
    );

    final textWidget = Center(
      child: AutoSizeText(
        widget.label,
        maxLines: 1,
        minFontSize: 10,
        maxFontSize: fontSize,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setHover(true),
      onTapUp: (_) => _setHover(false),
      onTapCancel: () => _setHover(false),
      child: MouseRegion(
        onEnter: (_) => _setHover(true),
        onExit: (_) => _setHover(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: _isHovered ? const EdgeInsets.all(18.0) : const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              colors: [widget.hoverColor, widget.hoverColor.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.hoverColor.withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                blurRadius: _isHovered ? 20.0 : 5.0,
                offset: const Offset(0.0, 5.0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: 8.0),
              textWidget,
            ],
          ),
        ),
      ),
    );
  }
}
