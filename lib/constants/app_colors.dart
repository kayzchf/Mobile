import 'package:flutter/material.dart';

class AppColors {
  // Void & Dark Cosmic Backgrounds
  static const Color voidBlack = Color(0xFF090A15);
  static const Color deepSpace = Color(0xFF0E0F26);
  static const Color astralIndigo = Color(0xFF14133A);
  static const Color cardSurface = Color(0xFF1C1A4A);
  static const Color cardSurfaceLight = Color(0xFF282566);

  // Mystic Neon Violets & Purples
  static const Color mysticViolet = Color(0xFF8A2BE2);
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color brightLavender = Color(0xFFC77DFF);
  static const Color deepViolet = Color(0xFF5A189A);

  // Celestial Accents & Mystic Silver Highlights (Replacing Gold with Silver)
  static const Color celestialCyan = Color(0xFF00D2FF);
  static const Color arcaneSilver = Color(0xFFF1F5F9);     // Crisp Mystic Silver
  static const Color shimmerSilver = Color(0xFFE2E8F0);    // Light Silver
  static const Color mutedSilver = Color(0xFFCBD5E1);      // Soft Readable Silver

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFFB4B7C9);

  // Status & Utility Colors
  static const Color successEmerald = Color(0xFF00E676);
  static const Color errorCrimson = Color(0xFFFF3366);
  static const Color warningOrange = Color(0xFFFF9100);

  // Gradients
  static const LinearGradient cosmicNebula = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [voidBlack, astralIndigo, deepSpace],
  );

  static const LinearGradient mysticButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonPurple, mysticViolet],
  );

  static const LinearGradient silverShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [arcaneSilver, shimmerSilver],
  );

  static const LinearGradient cyanPulse = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [celestialCyan, neonPurple],
  );
}
