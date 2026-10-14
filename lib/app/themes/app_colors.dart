import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors from Rotary & Rotaract Logos
  static const Color rotaryBlue = Color(0xFF00246C); // Official Rotary Royal Blue (Pantone 286C)
  static const Color rotaryAzure = Color(0xFF005DAA); // Rotary Azure Blue
  static const Color rotaryGold = Color(0xFFF7A81B); // Official Rotary Gold / Yellow (Pantone 1235C)
  static const Color rotaryYellow = Color(0xFFFFB81C); // Bright Rotary Yellow Accent
  static const Color rotaractPink = Color(0xFFE11383); // Official Rotaract Cranberry / Pink (Pantone 214C)
  static const Color rotaractPinkDark = Color(0xFFD41367); // Deep Rotaract Pink
  static const Color rotaractPinkLight = Color(0xFFFDF2F8); // Soft Pastel Pink Tint
  static const Color rotaractPinkBorder = Color(0xFFFBCFE8); // Soft Pink Border

  // Main Action & Brand Aliases
  static const Color primaryBlue = rotaryBlue;
  static const Color primaryBlueDark = Color(0xFF001B52);
  static const Color primary = rotaryBlue;
  static const Color secondary = rotaractPink;
  static const Color accent = rotaryGold;
  static const Color darkPrimary = rotaryBlue;
  static const Color lightPrimary = rotaryBlue;
  static const Color lightPrimaryBlack = rotaryBlue;

  // Status Indicators
  static const Color amberRating = rotaryGold;
  static const Color greenOpen = Color(0xFF10B981);
  static const Color redLogout = Color(0xFFEF4444);

  // Single White Theme Palette (Pure White with Logo Brand Colors)
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure White Background
  static const Color lightCard = Color(0xFFFFFFFF); // Pure White Card Surface
  static const Color lightSecondary = Color(0xFFF8FAFC); // Crisp Light Surface (Slate 50)
  static const Color lightTertiary = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFE2E8F0); // Crisp Clean Border (Slate 200)
  static const Color lightBorder2 = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF0F172A); // Deep Slate Text (High Contrast)
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightIcon = Color(0xFF64748B);
  static const Color lightDivider = Color(0xFFF1F5F9);

  // Mapped constants ensuring 100% White Theme consistency across any remaining widgets
  static const Color darkBackground = Color(0xFFFFFFFF); // Pure White
  static const Color darkCard = Color(0xFFFFFFFF); // Pure White
  static const Color darkSecondary = Color(0xFFF8FAFC);
  static const Color darkTertiary = Color(0xFFF1F5F9);
  static const Color darkBorder = Color(0xFFE2E8F0);
  static const Color darkTextPrimary = Color(0xFF0F172A);
  static const Color darkTextSecondary = Color(0xFF64748B);
  static const Color darkIcon = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFFF1F5F9);
  static const Color darkSurface = Color(0xFFFFFFFF);
}
