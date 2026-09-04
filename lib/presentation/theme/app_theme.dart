import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color accentIndigo = Color(0xFF3F51B5);
  
  // Status Colors
  static const Color statusMovingBg = Color(0xFFE8F5E9);
  static const Color statusMovingText = Color(0xFF2E7D32);

  static const Color statusIdleBg = Color(0xFFFFF8E1);
  static const Color statusIdleText = Color(0xFFF57F17);

  static const Color statusStoppedBg = Color(0xFFE3F2FD);
  static const Color statusStoppedText = Color(0xFF1565C0);

  static const Color statusOfflineBg = Color(0xFFF5F5F5);
  static const Color statusOfflineText = Color(0xFF616161);

  // Verdict Pill Colors
  static const Color verdictNormalBg = Color(0xFFE8F5E9);
  static const Color verdictNormalText = Color(0xFF2E7D32);

  static const Color verdictAlertBg = Color(0xFFFFEBEE);
  static const Color verdictAlertText = Color(0xFFC62828);

  static const Color verdictStaleBg = Color(0xFFEEEEEE);
  static const Color verdictStaleText = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF212121),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
    );
  }
}
