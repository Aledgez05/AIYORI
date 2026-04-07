import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'home_screen.dart';
import 'resgister_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // LOGO / NOMBRE
              const Text(
                'AIYORI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your mental wellness companion',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 40),

              // CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    // TOGGLE
                    Row(
                      children: [
                        _buildTab('Login', isLogin),
                        _buildTab('Sign Up', !isLogin),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // EMAIL
                    _buildInput(
                      controller: emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 12),

                    // PASSWORD
                    _buildInput(
                      controller: passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),

                    const SizedBox(height: 20),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isLogin) {
                            _handleLogin();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLogin ? 'Login' : 'Create Account',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // SWITCH TEXT
                    GestureDetector(
                      onTap: () {
                        setState(() => isLogin = !isLogin);
                      },
                      child: Text(
                        isLogin
                            ? "Don't have an account? Sign up"
                            : "Already have an account? Login",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => isLogin = text == 'Login');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // aqui luego va lo de firebase auth, por ahora solo navega al home screen :)
  void _handleLogin() {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
  );
}
}