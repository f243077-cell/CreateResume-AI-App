import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Creates the Material 3 light theme for CreateResume AI.
ThemeData buildAppTheme() {
  return _buildTheme(Brightness.light);
}

/// Creates the Material 3 dark theme for CreateResume AI.
ThemeData buildAppDarkTheme() {
  return _buildTheme(Brightness.dark);
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.navy800,
    primary: AppColors.navy800,
    onPrimary: AppColors.textOnPrimary,
    secondary: AppColors.blue400,
    onSecondary: AppColors.textOnPrimary,
    tertiary: AppColors.success,
    error: AppColors.error,
    surface: isDark ? AppColors.navy900 : AppColors.surfaceLight,
    onSurface: isDark ? AppColors.white : AppColors.textPrimary,
    surfaceContainerHighest: isDark ? const Color(0xFF1E293B) : AppColors.surfaceCard,
    outline: isDark ? const Color(0xFF334155) : AppColors.border,
    brightness: brightness,
  );

  final textTheme = TextTheme(
    headlineLarge: GoogleFonts.josefinSans(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: isDark ? AppColors.white : AppColors.textPrimary,
      height: 1.2,
    ),
    headlineMedium: GoogleFonts.josefinSans(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.white : AppColors.textPrimary,
      height: 1.25,
    ),
    headlineSmall: GoogleFonts.josefinSans(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.white : AppColors.textPrimary,
      height: 1.3,
    ),
    titleLarge: GoogleFonts.josefinSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.white : AppColors.textPrimary,
      height: 1.3,
    ),
    titleMedium: GoogleFonts.lora(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.white : AppColors.textPrimary,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.lora(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.white : AppColors.textPrimary,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.lora(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.white70 : AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.lora(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.white70 : AppColors.textSecondary,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.lora(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.white54 : AppColors.textSecondary,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.josefinSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.white : AppColors.textPrimary,
      height: 1.3,
    ),
    labelMedium: GoogleFonts.josefinSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.white70 : AppColors.textSecondary,
      height: 1.3,
    ),
    labelSmall: GoogleFonts.josefinSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.white54 : AppColors.textTertiary,
      height: 1.2,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: isDark ? AppColors.navy900 : AppColors.surfaceLight,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.surfaceCard,
      foregroundColor: isDark ? AppColors.white : AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium,
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy800,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.josefinSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.white : AppColors.navy800,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border),
        textStyle: GoogleFonts.josefinSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blue400,
        textStyle: GoogleFonts.josefinSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : AppColors.surfaceCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.blue400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: GoogleFonts.lora(fontSize: 14, color: isDark ? AppColors.white54 : AppColors.textTertiary),
      labelStyle: GoogleFonts.josefinSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.white70 : AppColors.textSecondary,
      ),
      prefixIconColor: isDark ? AppColors.white70 : AppColors.textSecondary,
      suffixIconColor: isDark ? AppColors.white70 : AppColors.textSecondary,
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? const Color(0xFF334155) : AppColors.border,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.surfaceCard,
      selectedItemColor: AppColors.navy800,
      unselectedItemColor: AppColors.textTertiary,
      selectedLabelStyle: GoogleFonts.josefinSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.josefinSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.navy900,
      contentTextStyle: GoogleFonts.lora(
        fontSize: 14,
        color: AppColors.textOnPrimary,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.navy800,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.surfaceCard,
      indicatorColor: AppColors.blue100,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.josefinSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.navy800,
          );
        }
        return GoogleFonts.josefinSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.white54 : AppColors.textTertiary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.navy800, size: 24);
        }
        return IconThemeData(color: isDark ? AppColors.white54 : AppColors.textTertiary, size: 24);
      }),
    ),
  );
}
