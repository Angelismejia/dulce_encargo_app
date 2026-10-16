import 'package:flutter/material.dart';
import 'colores.dart';

class AppTema {
  static const String fuenteTitulos = 'DancingScript';
  static const String fuenteTexto = 'Poppins';

  static ThemeData get claro {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.rosaPastel,
      surface: AppColors.background,
      error: AppColors.error,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fuenteTexto,
      scaffoldBackgroundColor: AppColors.background,
    );

    final texto = base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    TextStyle? titulo(TextStyle? s) =>
        s?.copyWith(fontFamily: fuenteTitulos, fontWeight: FontWeight.w700, color: AppColors.rosaFuerte);

    return base.copyWith(
      textTheme: texto.copyWith(
        displayLarge: titulo(texto.displayLarge),
        displayMedium: titulo(texto.displayMedium),
        displaySmall: titulo(texto.displaySmall),
        headlineLarge: titulo(texto.headlineLarge),
        headlineMedium: titulo(texto.headlineMedium),
        headlineSmall: titulo(texto.headlineSmall),
        titleLarge: texto.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: texto.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: texto.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.45),
        bodySmall: texto.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fuenteTitulos,
          fontWeight: FontWeight.w700,
          fontSize: 30,
          color: AppColors.rosaFuerte,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.rosaFuerte,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(fontFamily: fuenteTexto, fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosaFuerte,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(fontFamily: fuenteTexto, fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          textStyle: const TextStyle(fontFamily: fuenteTexto, fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.rosaFuerte,
          textStyle: const TextStyle(fontFamily: fuenteTexto, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rosaFuerte, width: 1.6),
        ),
        prefixIconColor: AppColors.textSecondary,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.rosaFuerte,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(fontFamily: fuenteTexto, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(fontFamily: fuenteTexto, fontWeight: FontWeight.w600, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.rosaClaro,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontFamily: fuenteTexto,
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
              color: states.contains(WidgetState.selected) ? AppColors.rosaFuerte : AppColors.gris,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? AppColors.rosaFuerte : AppColors.rosa,
            )),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.marron,
        contentTextStyle: const TextStyle(fontFamily: fuenteTexto, color: Colors.white, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        width: 420,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.rosaFuerte,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.rosaFuerte,
        dividerColor: AppColors.border,
        labelStyle: TextStyle(fontFamily: fuenteTexto, fontWeight: FontWeight.w700),
      ),
    );
  }
}
