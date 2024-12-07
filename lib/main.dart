// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdb/screens/eBantuan.dart';
import 'package:pdb/screens/ePensijilanHalal.dart';
import 'package:pdb/screens/eTempahan.dart';
import 'package:pdb/profile_screen.dart';
import 'package:pdb/screens/smartniaga_screen.dart';
import 'screens/eInternship.dart';
import 'screens/ePerjawatan.dart';
import 'home_screen.dart';
import 'login.dart'; // Assuming AuthScreen is here
import 'main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive storage
  await Hive.openBox('profileData'); // Open the box before using it

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perak Digital 3.0',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        textTheme: GoogleFonts.poppinsTextTheme(), // Google Fonts applied
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),               // login.dart
        '/home': (context) => const HomeScreen(),           // home_screen.dart
        '/main_menu': (context) => const MainMenu(),        // main_menu.dart
        '/information': (context) => const ProfileScreen(), // profile_screen.dart
        '/eInternship': (context) => const EInternshipScreen(),
        '/ePerjawatan': (context) => const EPerjawatanScreen(),
        '/ePensijilanHalal': (context) => const EPensijilanHalalScreen(),
        '/eTempahan': (context) => const ETempahanScreen(),
        '/smartNiaga': (context) => const SmartNiagaScreen(),
        '/eBantuan': (context) => const EBantuanScreen(),
      },
    );
  }
}
