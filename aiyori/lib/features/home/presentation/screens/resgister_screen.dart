import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'home_professional_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectedRole = '';
  String? professionalType; // 'psychologist' o 'psychiatrist'

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final professionalLicenseController = TextEditingController();
  bool acceptedTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pinController.dispose();
    confirmPinController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    professionalLicenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F3F1),
              Color(0xFFF5FAF9),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo y titulo con animacion (no se si dejarlo)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6EC1C2),
                              Color(0xFF8DD3D4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6EC1C2).withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF1C3D3A),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start your wellness journey today',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF1C3D3A).withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Sección: Como quieres usar la app?
                _buildSectionTitle('Select Your Purpose'),
                const SizedBox(height: 16),

                // Opciones de rol con mejor diseño
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleOption(
                        title: 'Personal Wellness',
                        subtitle: 'For your emotional growth',
                        icon: Icons.self_improvement_rounded,
                        isSelected: selectedRole == 'Personal Wellness',
                        onTap: () => setState(() => selectedRole = 'Personal Wellness'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildRoleOption(
                        title: 'Professional',
                        subtitle: 'Patient monitoring',
                        icon: Icons.medical_services_rounded,
                        isSelected: selectedRole == 'Healthcare Professional',
                        onTap: () => setState(() => selectedRole = 'Healthcare Professional'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoleOption(
                        title: 'Patient',
                        subtitle: 'Professional follow-up',
                        icon: Icons.favorite_rounded,
                        isSelected: selectedRole == 'Patient',
                        onTap: () => setState(() => selectedRole = 'Patient'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Seccion: Datos personales
                _buildSectionTitle('Your Information'),
                const SizedBox(height: 16),

                // Campos de texto con disenio refinado
                _buildTextField(
                  controller: nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: emailController,
                  hint: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: pinController,
                        hint: 'PIN (4 digits)',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: confirmPinController,
                        hint: 'Confirm PIN',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Password Section
                _buildTextField(
                  controller: passwordController,
                  hint: 'Password (at least 8 characters)',
                  icon: Icons.vpn_key_rounded,
                  obscure: true,
                ),

                const SizedBox(height: 12),

                _buildTextField(
                  controller: confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.vpn_key_rounded,
                  obscure: true,
                ),

                const SizedBox(height: 20),

                // Campos profesionales (solo si es Healthcare Professional)
                if (selectedRole == 'Healthcare Professional') ...[
                  _buildSectionTitle('Professional Information'),
                  const SizedBox(height: 16),

                  // Selector de Profesional
                  const Text(
                    'Professional Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C3D3A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => professionalType = 'psychologist'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: professionalType == 'psychologist'
                                  ? const Color(0xFF6EC1C2).withOpacity(0.1)
                                  : Colors.white.withOpacity(0.5),
                              border: Border.all(
                                color: professionalType == 'psychologist'
                                    ? const Color(0xFF6EC1C2)
                                    : Colors.grey.withOpacity(0.3),
                                width: professionalType == 'psychologist' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: 'psychologist',
                                  groupValue: professionalType,
                                  onChanged: (value) =>
                                      setState(() => professionalType = value),
                                  activeColor: const Color(0xFF6EC1C2),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Psicólogo',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1C3D3A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => professionalType = 'psychiatrist'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: professionalType == 'psychiatrist'
                                  ? const Color(0xFF6EC1C2).withOpacity(0.1)
                                  : Colors.white.withOpacity(0.5),
                              border: Border.all(
                                color: professionalType == 'psychiatrist'
                                    ? const Color(0xFF6EC1C2)
                                    : Colors.grey.withOpacity(0.3),
                                width: professionalType == 'psychiatrist' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: 'psychiatrist',
                                  groupValue: professionalType,
                                  onChanged: (value) =>
                                      setState(() => professionalType = value),
                                  activeColor: const Color(0xFF6EC1C2),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Psiquiatra',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1C3D3A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Campo de Cédula Profesional
                  _buildTextField(
                    controller: professionalLicenseController,
                    hint: 'Cédula Profesional',
                    icon: Icons.badge_outlined,
                  ),

                  const SizedBox(height: 20),
                ],

                // Términos y condiciones
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: acceptedTerms,
                        onChanged: (value) {
                          setState(() => acceptedTerms = value ?? false);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        activeColor: const Color(0xFF6EC1C2),
                        side: BorderSide(
                          color: const Color(0xFF1C3D3A).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF1C3D3A).withOpacity(0.7),
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: const Color(0xFF6EC1C2),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Botón de registro con gradiente
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF6EC1C2),
                        Color(0xFF8DD3D4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6EC1C2).withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón volver
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1C3D3A).withOpacity(0.6),
                    ),
                    child: const Text(
                      'I Already Have an Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1C3D3A).withOpacity(0.8),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildRoleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6EC1C2)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6EC1C2).withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6EC1C2).withOpacity(0.1)
                    : const Color(0xFF1C3D3A).withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF6EC1C2)
                    : const Color(0xFF1C3D3A).withOpacity(0.5),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF1C3D3A)
                    : const Color(0xFF1C3D3A).withOpacity(0.7),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF1C3D3A).withOpacity(0.5),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1C3D3A),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF1C3D3A).withOpacity(0.35),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF6EC1C2).withOpacity(0.6),
            size: 22,
          ),
          counterText: '', // Hide character counter
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please select a purpose',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1C3D3A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'You must accept the Terms & Conditions',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1C3D3A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Validate required fields
    final email = emailController.text.trim();
    final pin = pinController.text.trim();
    final confirmPin = confirmPinController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || pin.isEmpty || name.isEmpty || password.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    // Validate PIN (4 digits)
    if (pin != confirmPin) {
      _showErrorDialog('PINs do not match');
      return;
    }

    if (pin.length != 4) {
      _showErrorDialog('PIN must be exactly 4 digits');
      return;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      _showErrorDialog('PIN must contain only digits (0-9)');
      return;
    }

    // Validate Password (stronger requirements)
    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    if (password.length < 8) {
      _showErrorDialog('Password must be at least 8 characters long');
      return;
    }

    // Check for password strength (at least 1 uppercase, 1 lowercase, 1 number)
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      _showErrorDialog('Password must contain at least 1 uppercase letter');
      return;
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      _showErrorDialog('Password must contain at least 1 lowercase letter');
      return;
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      _showErrorDialog('Password must contain at least 1 number');
      return;
    }

    // Validar campos profesionales si es Healthcare Professional
    if (selectedRole == 'Healthcare Professional') {
      if (professionalType == null) {
        _showErrorDialog('Please select your professional type (Psychologist or Psychiatrist)');
        return;
      }

      final professionalLicense = professionalLicenseController.text.trim();
      if (professionalLicense.isEmpty) {
        _showErrorDialog('Professional license (Cédula Profesional) is required');
        return;
      }

      if (professionalLicense.length < 5) {
        _showErrorDialog('Professional license must be at least 5 characters');
        return;
      }
    }

    // Create user in Firebase
    _createUserAndNavigate(
      email: email,
      password: password,
      name: name,
      role: selectedRole,
      pin: pin,
      professionalType: professionalType,
      professionalLicense: professionalLicenseController.text.trim(),
    );
  }

  Future<void> _createUserAndNavigate({
    required String email,
    required String password,
    required String name,
    required String role,
    required String pin,
    String? professionalType,
    String? professionalLicense,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Creating your account...'),
          ],
        ),
      ),
    );

    try {
      // 1. Create user in Firebase Auth (using strong password)
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // 2. Create user document in Firestore (storing PIN as well)
      final userData = {
        'uid': userId,
        'name': name,
        'email': email,
        'role': role,
        'pin': pin,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      // Add professional fields if Healthcare Professional
      if (role == 'Healthcare Professional') {
        userData.addAll({
          'professionalType': professionalType as String,
          'professionalLicense': professionalLicense as String,
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // 3. Navigate based on role
      if (role == 'Healthcare Professional') {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeProfessionalScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      String message = 'Error creating account';
      
      if (e.code == 'weak-password') {
        message = 'Your password is too weak. Use uppercase, lowercase, and numbers.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Try logging in instead.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Account creation is currently disabled. Please try again later.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      } else {
        message = 'Firebase Auth Error: ${e.message}';
      }
      _showErrorDialog(message);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Firebase Error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}