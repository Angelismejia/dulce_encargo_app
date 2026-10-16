import 'package:flutter/material.dart';

/// Paleta de la marca Dulce Encargo.
class AppColors {
  static const Color rosa = Color(0xFFFF89B5);
  static const Color rosaFuerte = Color(0xFFF45B95);
  static const Color rosaPastel = Color(0xFFFFC4D6);
  static const Color rosaClaro = Color(0xFFFFF0F5);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color marron = Color(0xFF493139);
  static const Color gris = Color(0xFF8B8287);

  // Alias semánticos usados por la interfaz.
  static const Color primary = rosa;
  static const Color primaryDark = rosaFuerte;
  static const Color secondary = rosaPastel;
  static const Color accent = rosaClaro;
  static const Color background = blanco;
  static const Color surfaceMuted = rosaClaro;
  static const Color cardBackground = blanco;
  static const Color border = Color(0xFFFFDDE8);
  static const Color textPrimary = marron;
  static const Color textSecondary = gris;

  // Colores funcionales (estados y avisos).
  static const Color success = Color(0xFF3FA37A);
  static const Color warning = Color(0xFFE79A3B);
  static const Color error = Color(0xFFE0465E);
  static const Color whatsapp = Color(0xFF25D366);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [rosa, rosaFuerte],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color estado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return warning;
      case 'en proceso':
        return rosaFuerte;
      case 'listo':
      case 'entregado':
        return success;
      case 'cancelado':
        return error;
      default:
        return gris;
    }
  }
}

/// Sombras suaves reutilizables (teñidas de rosa para no ensuciar el diseño).
class AppShadows {
  static List<BoxShadow> get suave => [
        BoxShadow(
          color: AppColors.rosaFuerte.withValues(alpha: 0.10),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get elevada => [
        BoxShadow(
          color: AppColors.rosaFuerte.withValues(alpha: 0.20),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];
}
