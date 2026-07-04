import 'package:flutter/material.dart';

/// Named color constants for the CreateResume AI navy/blue palette.
abstract final class AppColors {
  // ── Primary Navy ──────────────────────────────────────────────────
  static const navy900 = Color(0xFF0A1128);
  static const navy800 = Color(0xFF0D1B4A);
  static const navy700 = Color(0xFF132257);
  static const navy600 = Color(0xFF1B3A7B);
  static const navy500 = Color(0xFF1E40AF);

  // ── Accent Blue ───────────────────────────────────────────────────
  static const blue400 = Color(0xFF3B82F6);
  static const blue300 = Color(0xFF60A5FA);
  static const blue200 = Color(0xFF93C5FD);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue50 = Color(0xFFEFF6FF);

  // ── Surfaces ──────────────────────────────────────────────────────
  static const surfaceLight = Color(0xFFF8FAFC);
  static const surfaceCard = Colors.white;
  static const surfaceDark = Color(0xFF0F172A);

  // ── Semantic ──────────────────────────────────────────────────────
  static const success = Color(0xFF22C55E);
  static const successBg = Color(0xFFDCFCE7);
  static const green600 = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFEF3C7);
  static const orange600 = Color(0xFFEA580C);
  static const error = Color(0xFFEF4444);
  static const errorBg = Color(0xFFFEE2E2);

  // ── Text ──────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const textOnPrimary = Colors.white;

  // ── Border / Divider ──────────────────────────────────────────────
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFF1F5F9);

  // ── White Variants ───────────────────────────────────────────────────
  static const white = Colors.white;
  static const white70 = Color(0xB3FFFFFF);
  static const white54 = Color(0x8AFFFFFF);
  static const white24 = Color(0x3DFFFFFF);
  static const amber = Color(0xFFFFB300);
  static const gold = Color(0xFFD4A92E);
}
