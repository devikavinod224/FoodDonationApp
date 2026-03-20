import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color shopkeeperPrimary = Color(0xFFFB923C); // orange-400
  static const Color shopkeeperSecondary = Color(0xFFEA580C); // orange-600
  static const Color receiverPrimary = Color(0xFF22C55E); // green-500
  static const Color receiverSecondary = Color(0xFF16A34A); // green-600
  static const Color background = Color(0xFFF9FAFB); // gray-50
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937); // gray-800
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
  static const Color textLight = Color(0xFF9CA3AF); // gray-400

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: shopkeeperPrimary,
        primary: shopkeeperPrimary,
        secondary: shopkeeperSecondary,
        surface: background,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: background,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration gradientDecoration(List<Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
    );
  }
}
