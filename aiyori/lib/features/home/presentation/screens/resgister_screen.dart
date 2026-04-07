import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectedRole = '';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // LOGO
              Column(
                children: const [
                  Icon(Icons.spa, size: 40, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text(
                    'AIYORI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Create your account and choose how you want to use AIYORI.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),

              const Text(
                'How do you want to use AIYORI?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // ROLES
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _roleCard('Bienestar emocional', Icons.favorite_outline),
                  _roleCard('Profesional de la salud', Icons.psychology_outlined),
                  _roleCard('Paciente', Icons.monitor_heart_outlined),
                ],
              ),

              const SizedBox(height: 24),

              _input(nameController, 'Nombre completo'),
              const SizedBox(height: 10),
              _input(emailController, 'Correo electrónico'),
              const SizedBox(height: 10),
              _input(pinController, 'PIN de 4 dígitos', obscure: true),
              const SizedBox(height: 10),
              _input(confirmPinController, 'Confirmar PIN', obscure: true),

              const SizedBox(height: 10),

              Row(
                children: const [
                  Checkbox(value: false, onChanged: null),
                  Expanded(
                    child: Text(
                      'He leído y acepto los Términos y Condiciones.',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Registrarme'),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(String title, IconData icon) {
    final isSelected = selectedRole == title;

    return GestureDetector(
      onTap: () {
        setState(() => selectedRole = title);
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.softShadow,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.softShadow,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un rol')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}