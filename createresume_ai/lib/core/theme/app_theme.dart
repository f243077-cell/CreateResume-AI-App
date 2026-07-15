import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Creates the single Material 3 theme for CreateResume AI.
/// The app no longer supports light/dark mode switching — this is the
/// only theme used throughout the app.
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.burntOrange,
    brightness: Brightness.light,
    primary: AppColors.burntOrange,
    onPrimary: AppColors.textOnPrimary,
    secondary: AppColors.vanilla,
    onSecondary: AppColors.textPrimary,
    tertiary: AppColors.navy800,
    error: AppColors.error,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceCard,
    outline: AppColors.border,
  );

  final textTheme = TextTheme(
    headlineLarge: GoogleFonts.josefinSans(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1.2,
    ),
    headlineMedium: GoogleFonts.josefinSans(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.25,
    ),
    headlineSmall: GoogleFonts.josefinSans(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    titleLarge: GoogleFonts.josefinSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    titleMedium: GoogleFonts.josefinSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.josefinSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.lora(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.lora(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.lora(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.josefinSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    labelMedium: GoogleFonts.josefinSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      height: 1.3,
    ),
    labelSmall: GoogleFonts.josefinSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textTertiary,
      height: 1.2,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.surfaceLight,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceCard,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.burntOrange,
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
        foregroundColor: AppColors.burntOrange,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.border),
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
        foregroundColor: AppColors.burntOrange,
        textStyle: GoogleFonts.josefinSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.burntOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: GoogleFonts.lora(fontSize: 14, color: AppColors.textTertiary),
      labelStyle: GoogleFonts.josefinSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceCard,
      selectedItemColor: AppColors.burntOrange,
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
      backgroundColor: AppColors.burntOrange,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceCard,
      indicatorColor: AppColors.vanilla,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.josefinSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.burntOrange,
          );
        }
        return GoogleFonts.josefinSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.burntOrange, size: 24);
        }
        return const IconThemeData(color: AppColors.textTertiary, size: 24);
      }),
    ),
  );
}
