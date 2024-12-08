import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Import pakej auto_size_text untuk teks yang boleh diubah saiz
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'navbar.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 1; // Indeks lalai untuk Menu Utama

  final List<PilihanMenu> pilihanMenu = [
    PilihanMenu(icon: Icons.work, label: 'e-Perjawatan', hoverColor: Colors.deepOrange),
    PilihanMenu(icon: Icons.school, label: 'e-Internship', hoverColor: Colors.blue),
    PilihanMenu(icon: Icons.verified_user, label: 'e-Pensijilan Halal', hoverColor: Colors.green),
    PilihanMenu(icon: Icons.store, label: 'S.M.A.R.T Niaga', hoverColor: Colors.purple),
    PilihanMenu(icon: Icons.book_online, label: 'e-Tempahan', hoverColor: Colors.cyan),
    PilihanMenu(icon: Icons.help_outline, label: 'e-Bantuan', hoverColor: Colors.teal),
  ];

  final List<PilihanMaklumat> pilihanMaklumat = [
    PilihanMaklumat(imagePath: 'assets/tourism.png', label: 'Perak’s Business Potentials and Investment Opportunities, Shines In MIDA Invest Series', description: 'The Malaysian Investment Development Authority (MIDA) held its distinguished “MIDA Invest Series – Perak: Unfolding Its Business Potentials”'),
    PilihanMaklumat(imagePath: 'assets/holdings.png', label: 'Maklumat 2', description: 'Ini adalah deskripsi ringkas Maklumat 2.'),
    PilihanMaklumat(imagePath: 'assets/tourism.png', label: 'Maklumat 3', description: 'Ini adalah deskripsi ringkas Maklumat 3.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
            // Bahagian Akses Pantas
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
                  'Akses Pantas',
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
            // Bahagian Butang Menu (Grid 2xN)
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
                  crossAxisCount: 2, // 2 ikon setiap baris
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: pilihanMenu.length,
                itemBuilder: (context, index) {
                  final option = pilihanMenu[index];
                  return ButangHover(
                    icon: option.icon,
                    label: option.label,
                    hoverColor: option.hoverColor,
                    onTap: () {
                      // Navigasi berdasarkan label
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
            // Bahagian Tajuk Maklumat
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
                  'Maklumat',
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
            // Bahagian Karusel Maklumat
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
              items: pilihanMaklumat.map((option) {
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

class PilihanMenu {
  final IconData icon;
  final String label;
  final Color hoverColor;

  PilihanMenu({required this.icon, required this.label, required this.hoverColor});
}

class PilihanMaklumat {
  final String imagePath;
  final String label;
  final String description;

  PilihanMaklumat({required this.imagePath, required this.label, required this.description});
}

class ButangHover extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color hoverColor;
  final VoidCallback onTap;

  const ButangHover({
    super.key,
    required this.icon,
    required this.label,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<ButangHover> createState() => _ButangHoverState();
}

class _ButangHoverState extends State<ButangHover> {
  bool _isHovered = false;

  void _setHover(bool hover) {
    setState(() => _isHovered = hover);
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = _isHovered ? 42.0 : 36.0;
    final double fontSize = _isHovered ? 16.0 : 14.0;

    // Tentukan warna berdasarkan keadaan hover
    const iconColor = Colors.white;
    const textColor = Colors.white;

    // Ikon dan teks
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
        style: const TextStyle(
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
