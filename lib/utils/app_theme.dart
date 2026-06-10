import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors
  static const Color bgBlack = Color(0xFF0A0A0F);
  static const Color bgDark = Color(0xFF111118);
  static const Color cardBg = Color(0xFF1A1A24);
  static const Color cardBorder = Color(0xFF2A2A38);

  // Gold Palette
  static const Color goldPrimary = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF0A0);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldAccent = Color(0xFFFFAA00);

  // Glow Colors
  static const Color glowGold = Color(0x60FFD700);
  static const Color glowGoldBright = Color(0x99FFD700);

  // Text Colors
  static const Color textWhite = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF9090A0);
  static const Color textDim = Color(0xFF505060);

  // Game Colors
  static const Color memoryPurple = Color(0xFF9B59B6);
  static const Color tttBlue = Color(0xFF3498DB);
  static const Color snakeGreen = Color(0xFF2ECC71);
  static const Color game2048Orange = Color(0xFFE67E22);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF111118), Color(0xFF0D0D15)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E2E), Color(0xFF15151F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgBlack,
      primaryColor: goldPrimary,
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        secondary: goldAccent,
        surface: cardBg,
        background: bgBlack,
      ),
      fontFamily: 'RoyalFont',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: goldPrimary,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
        displayMedium: TextStyle(
          color: textWhite,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        titleLarge: TextStyle(
          color: textWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        titleMedium: TextStyle(
          color: goldPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
        bodyLarge: TextStyle(color: textWhite, fontSize: 16),
        bodyMedium: TextStyle(color: textGrey, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: goldPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
          fontFamily: 'RoyalFont',
        ),
        iconTheme: IconThemeData(color: goldPrimary),
      ),
    );
  }
}
