import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color deepNavy = Color(0xFF07172E);
  static const Color oceanTeal = Color(0xFF0B5568);
  static const Color aquaGlow = Color(0xFF38B6A9);
  static const Color card = Color(0xFF0E223F);
  static const Color cardMuted = Color(0xFF15325A);
  static const Color textPrimary = Color(0xFFF4FAFF);
  static const Color textSecondary = Color(0xFF9EB7D2);
  static const Color success = Color(0xFF62D2A2);
  static const Color warning = Color(0xFFF0C674);
}

class AppGradients {
  static const LinearGradient mainBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.deepNavy,
      AppColors.oceanTeal,
      Color(0xFF083645),
    ],
  );
}

class AppRadius {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
}

class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppShadows {
  static List<BoxShadow> soft = const [
    BoxShadow(
      color: Color(0x5502121F),
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
  ];
}

class AppTextStyles {
  static TextStyle get headline => GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 26,
        letterSpacing: -0.2,
      );

  static TextStyle get title => GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      );
}

class AppTheme {
  static ThemeData get themeData {
    final baseText = GoogleFonts.dmSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.aquaGlow,
        secondary: AppColors.success,
        surface: AppColors.card,
      ),
      textTheme: baseText.copyWith(
        headlineLarge: AppTextStyles.headline,
        titleLarge: AppTextStyles.title,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.aquaGlow,
          foregroundColor: AppColors.deepNavy,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppTextStyles.caption,
      ),
    );
  }
}
