import 'package:flutter/material.dart';

/// Paleta central de la app. Un solo lugar para cambiar colores.
class AppColors {
  AppColors._();

  // — Primarios —
  static const Color primary        = Color(0xFF0E5149); // verde bosque
  static const Color primaryLight   = Color(0xFF1A7A6E); // hover / estados
  static const Color primaryDark    = Color(0xFF093D36); // pressed / sombras

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
}