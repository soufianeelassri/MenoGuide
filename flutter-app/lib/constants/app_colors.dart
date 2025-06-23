import 'package:flutter/material.dart';

class AppColors {
  // New Color Palette - Soft, Calming, Feminine
  static const Color primary = Color(0xFFCDB4DB); // Soft lavender
  static const Color secondary = Color(0xFFFFC8DD); // Soft pink
  static const Color accent = Color(0xFFBDE0FE); // Soft blue
  static const Color tertiary = Color(0xFFFFAFCC); // Light pink
  static const Color quaternary = Color(0xFFA2D2FF); // Light blue

  // Background Colors - Softer, more calming
  static const Color background =
      Color(0xFFFFFEFE); // Almost white with slight warmth
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color wellnessCard = Color(0xFFF8F9FA); // Light gray for cards

  // Symptom-Specific Colors - Using new palette
  static const Color hotFlash = Color(0xFFFFAFCC); // Light pink for hot flashes
  static const Color nightSweat =
      Color(0xFFBDE0FE); // Soft blue for night sweats
  static const Color moodSwing =
      Color(0xFFCDB4DB); // Soft lavender for mood changes
  static const Color fatigue = Color(0xFFA2D2FF); // Light blue for fatigue
  static const Color anxiety = Color(0xFFFFC8DD); // Soft pink for anxiety
  static const Color depression =
      Color(0xFFCDB4DB); // Soft lavender for depression
  static const Color brainFog = Color(0xFFBDE0FE); // Soft blue for brain fog
  static const Color jointPain = Color(0xFFA2D2FF); // Light blue for joint pain

  // Status Colors - Using new palette
  static const Color success =
      Color(0xFFBDE0FE); // Soft blue for positive trends
  static const Color warning = Color(0xFFFFAFCC); // Light pink for warnings
  static const Color error = Color(0xFFFFC8DD); // Soft pink for errors
  static const Color info = Color(0xFFA2D2FF); // Light blue for information

  // Text Colors - Softer, more readable
  static const Color textPrimary = Color(0xFF2C3E50); // Softer dark blue-gray
  static const Color textSecondary = Color(0xFF7F8C8D); // Softer medium gray
  static const Color textLight =
      Color(0xFFBDC3C7); // Light gray for tertiary text
  static const Color textInverse = Colors.white;

  // Border and Shadow Colors
  static const Color border = Color(0xFFE0E0E0); // Light gray for borders
  static const Color shadow = Color(0x1A000000); // Subtle shadow

  // Gradients - Using new palette
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFEFE), // Almost white
      Color(0xFFF8F9FA), // Very light gray
    ],
  );

  static const LinearGradient softPinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFC8DD), // Soft pink
      Color(0xFFFFAFCC), // Light pink
    ],
  );

  static const LinearGradient lavenderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCDB4DB), // Soft lavender
      Color(0xFFFFC8DD), // Soft pink
    ],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCDB4DB), // Soft lavender
      Color(0xFFBDE0FE), // Soft blue
    ],
  );

  static const LinearGradient wellnessGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF0F5), // Very light pink
      Color(0xFFF0F8FF), // Very light blue
    ],
  );

  // Additional Symptom Gradients - Using new palette
  static const LinearGradient hotFlashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFAFCC), // Light pink
      Color(0xFFFFC8DD), // Soft pink
    ],
  );

  static const LinearGradient moodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCDB4DB), // Soft lavender
      Color(0xFFFFAFCC), // Light pink
    ],
  );

  static const LinearGradient sleepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFBDE0FE), // Soft blue
      Color(0xFFA2D2FF), // Light blue
    ],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA2D2FF), // Light blue
      Color(0xFFBDE0FE), // Soft blue
    ],
  );

  // Additional Gradients for variety
  static const LinearGradient pinkLavenderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFC8DD), // Soft pink
      Color(0xFFCDB4DB), // Soft lavender
    ],
  );

  static const LinearGradient bluePinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFBDE0FE), // Soft blue
      Color(0xFFFFAFCC), // Light pink
    ],
  );

  static const LinearGradient communityGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCDB4DB), // Soft lavender
      Color(0xFFBDE0FE), // Soft blue
    ],
  );

  static const LinearGradient weatherGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF87CEEB), // Sky blue
      Color(0xFF4682B4), // Steel blue
    ],
  );

  // Material 3 Color Scheme - Updated with new palette
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: textInverse,
    secondary: secondary,
    onSecondary: textInverse,
    tertiary: tertiary,
    onTertiary: textInverse,
    error: error,
    onError: textInverse,
    background: background,
    onBackground: textPrimary,
    surface: surface,
    onSurface: textPrimary,
    surfaceVariant: wellnessCard,
    onSurfaceVariant: textSecondary,
    outline: border,
    outlineVariant: textLight,
    shadow: shadow,
    scrim: Color(0x52000000),
    inverseSurface: textPrimary,
    onInverseSurface: textInverse,
    inversePrimary: primary,
    surfaceTint: primary,
  );

  // Legacy colors for backward compatibility
  static const Color mintGreen = Color(0xFF4ECDC4);
  static const Color progressBackground = Color(0xFFECF0F1);
  static const Color progressFill = primary;
  static const Color divider = Color(0xFFF8F9FA);

  // Calendar Colors
  static const Color calendarSelected = primary;
  static const Color calendarToday = Color(0xFFCDB4DB);
  static const Color calendarEvent = Color(0xFFFFAFCC);

  // Mood Colors
  static const Color moodHappy = Color(0xFFBDE0FE);
  static const Color moodCalm = Color(0xFFA2D2FF);
  static const Color moodNeutral = Color(0xFFCDB4DB);
  static const Color moodSad = Color(0xFFFFC8DD);
  static const Color moodStressed = Color(0xFFFFAFCC);
  static const Color moodTired = Color(0xFF95A5A6);
}
