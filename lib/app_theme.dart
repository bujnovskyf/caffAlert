import 'package:flutter/material.dart';

abstract final class AppColors {
  static const espresso = Color(0xFF35241D);
  static const roast = Color(0xFF6D4938);
  static const caramel = Color(0xFFC2865D);
  static const crema = Color(0xFFF4E9DE);
  static const foam = Color(0xFFFFFBF7);
  static const sage = Color(0xFF607466);
  static const error = Color(0xFFB42318);

  /// Warmer accent for a CAF level that is almost at zero.
  static const ember = Color(0xFFB4561F);

  /// Caramel that stays readable on the dark espresso snackbar.
  static const caramelLight = Color(0xFFE8B48C);
}

abstract final class AppRadii {
  static const hero = 32.0;
  static const card = 24.0;
  static const control = 18.0;
}

abstract final class AppText {
  static const mono = TextStyle(
    fontFamily: 'IBMPlexMono',
    color: AppColors.espresso,
  );

  /// Small uppercase label (e.g. "TVŮJ KÁVOVÝ RYTMUS", "CAF").
  static const eyebrow = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: AppColors.roast,
  );
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.roast,
      brightness: Brightness.light,
      primary: AppColors.roast,
      secondary: AppColors.sage,
      surface: AppColors.foam,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Raleway',
      scaffoldBackgroundColor: AppColors.crema,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.espresso,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.foam,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: AppColors.roast.withValues(alpha: 0.12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.roast.withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.roast, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 52),
          backgroundColor: AppColors.espresso,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          // Without an explicit family, button labels fall back to the
          // platform font instead of Raleway.
          textStyle: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          foregroundColor: AppColors.espresso,
          side: BorderSide(color: AppColors.roast.withValues(alpha: 0.28)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.foam
              : AppColors.roast,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.espresso
              : AppColors.crema,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.espresso,
        actionTextColor: AppColors.caramelLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
