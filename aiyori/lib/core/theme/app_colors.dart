import 'package:flutter/material.dart';

/// Paleta central de la app. Un solo lugar para cambiar colores.
class AppColors {
  AppColors._();

  // — Primarios —
  static const Color primary     = Color(0xFF6EC1C2);
  static const Color primaryLight  = Color(0xFF1A7A6E); // hover / estados
  static const Color primaryDark = Color(0xFF0B1020);

  // — Acentos —
  static const Color accent         = Color(0xFF4DB6A4); // menta vibrante
  static const Color accentSoft     = Color(0xFF80CBC4); // menta suave

  // — Neutros —
  static const Color surface        = Color(0xFFF2F7F6); // fondo claro
  static const Color surfaceDark    = Color(0xFF0D1F1D); // fondo oscuro
  static const Color card           = Color(0xFFFFFFFF);
  static const Color cardDark       = Color(0xFF132E2A);

  // — Texto —
  static const Color textPrimary    = Color(0xFF0D1F1D);
  static const Color textSecondary  = Color(0xFF4A6B66);
  static const Color textOnDark     = Color(0xFFF2F7F6);

  // — Estado —
  static const Color success        = Color(0xFF2E7D5A);
  static const Color warning        = Color(0xFFF5A623);
  static const Color error          = Color(0xFFD64545);

  // — Divisores —
  static const Color divider        = Color(0xFFCCDEDB);

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x14000000), // negro con opacidad baja
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ========== NUEVAS ADICIONES ==========
  
  // — Colores adicionales para variantes —
  static const Color primaryLighter = Color(0xFFB8DFDE);
  static const Color surfaceLight = Color(0xFFF8FCFB);
  
  // — Degradados predefinidos —
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6EC1C2),
      Color(0xFF8DD3D4),
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F3F1),
      Color(0xFFF5FAF9),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Color adicional para el nuevo diseño
  static const Color primaryVariant = Color(0xFF8DD3D4);
  
  // — Sombras adicionales —
  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: const Color(0xFF6EC1C2).withOpacity(0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get lightShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];
}