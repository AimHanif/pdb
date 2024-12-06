import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLoginForm = true;

  void toggleForm() {
    setState(() {
      showLoginForm = !showLoginForm;
    });
  }

  String get titleText => showLoginForm ? 'Welcome Back' : 'Create Account';
  String get subtitleText => showLoginForm
      ? 'Log in to explore more!'
      : 'Join us for an amazing experience!';
  String get toggleButtonText => showLoginForm
      ? "Don't have an account? Sign up"
      : "Already have an account? Log in";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Added a pinch of blue to the gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.blueAccent.withOpacity(0.7), // Adding blue accent
              AppColors.accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40.0),
              // Logo with AnimatedSwitcher for subtle fade/slide
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/test.png', // Placeholder image path
                  key: ValueKey(showLoginForm),
                  height: 80.0,
                  width: 80.0,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.star,
                      color: AppColors.iconColor,
                      size: 80.0,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30.0),
              // Title and subtitle with AnimatedSwitcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(showLoginForm ? -0.1 : 0.1, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: ValueKey(titleText + subtitleText),
                  children: [
                    Text(
                      titleText,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      subtitleText,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40.0),
              // White Container for forms
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30.0),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0.0, -4.0),
                        blurRadius: 15.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        // AnimatedSwitcher for forms
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(showLoginForm ? 0.1 : -0.1, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: showLoginForm
                              ? _buildLoginForm(key: const ValueKey('loginForm'))
                              : _buildRegisterForm(key: const ValueKey('registerForm')),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextButton(
                        onPressed: toggleForm,
                        child: Text(
                          toggleButtonText,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm({Key? key}) {
    return SingleChildScrollView(
      key: key,
      child: Column(
        children: [
          _buildTextField(
            icon: Icons.email_outlined,
            hint: 'Email',
          ),
          const SizedBox(height: 20.0),
          _buildTextField(
            icon: Icons.lock_outline,
            hint: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 20.0),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Add forgot password functionality here
              },
              child: Text(
                'Forgot password?',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          _buildActionButton(
            text: 'Log in',
            onPressed: () {
              // Navigate to HomeScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm({Key? key}) {
    return SingleChildScrollView(
      key: key,
      child: Column(
        children: [
          _buildTextField(
            icon: Icons.person_outline,
            hint: 'Name',
          ),
          const SizedBox(height: 20.0),
          _buildTextField(
            icon: Icons.email_outlined,
            hint: 'Email',
          ),
          const SizedBox(height: 20.0),
          _buildTextField(
            icon: Icons.lock_outline,
            hint: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 20.0),
          _buildActionButton(
            text: 'Sign up',
            onPressed: () {
              // Navigate to HomeScreen after successful registration
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    bool obscureText = false,
  }) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          shadowColor: AppColors.blueAccent.withOpacity(0.4), // Add blue touch to shadow
          elevation: 10.0,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: AppColors.buttonText,
          ),
        ),
      ),
    );
  }
}
