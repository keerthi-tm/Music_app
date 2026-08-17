import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // no instances — static access only

  // Brand / accent
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color deepPurple = Colors.deepPurple;
  static const Color deepPurpleAccent = Colors.deepPurpleAccent;
  static const Color purpleAccent = Colors.purpleAccent;

  static const Color lavenderAccent = Color.fromARGB(255, 220, 158, 231);

  static const List<Color> primaryGradient = [primaryPurple, primaryPink];

  // Background gradients (page-level)
  // Used by DashboardPage / DiscoverPage.
  static const List<Color> backgroundDark = [
    Color(0xff0D0714),
    Color(0xff1A0F2E),
    Color(0xff120A21),
  ];
  static const List<Color> backgroundLight = [
    Color(0xffF8F5FF),
    Color(0xffEDE6FA),
    Color(0xffF3EEFB),
  ];

  // Used by HomePage / MusicLayout (main.dart) / CategoryPage.
  static const List<Color> backgroundDarkAlt = [
    Color(0xff18071F),
    Color(0xff090814),
    Color(0xff220833),
  ];
  static const List<Color> backgroundLightAlt = [
    Color(0xffF8F4FF),
    Color(0xffEEE7FF),
    Color.fromARGB(255, 202, 195, 225),
  ];

  // CategoryPage's light variant ends on a slightly different tone.
  static const List<Color> categoryLightAlt = [
    Color(0xffF8F4FF),
    Color(0xffEEE7FF),
    Color.fromARGB(255, 129, 122, 151),
  ];

  // Song / feature palette — cycled across Discover's 20 songs, Home's
  // floating notes, and Home's feature grid cards.
  static const List<List<Color>> songPalette = [
    [Color(0xFF8B5CF6), Color(0xFFEC4899)], // purple -> pink
    [Color.fromARGB(255, 110, 149, 156), Color(0xFF3B82F6)], // cyan -> blue
    [Color(0xFFA855F7), Color(0xFF6366F1)], // violet -> indigo
    [Color.fromARGB(255, 226, 181, 149), Color(0xFFEC4899)], // orange -> pink
    [Color.fromARGB(255, 231, 88, 131), Color(0xFF06B6D4)], // green -> cyan
    [Color.fromARGB(255, 209, 242, 203), Color(0xFFA855F7)], // rose -> violet
  ];

  // Standalone shades pulled from the palette above, for one-off use
  // (e.g. individual floating notes on Home).
  static const Color cyan = Color(0xFF06B6D4);
  static const Color blue = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF6366F1);
  static const Color orange = Color.fromARGB(255, 210, 165, 133);
  static const Color green = Color.fromARGB(255, 128, 172, 144);
  static const Color rose = Color(0xFFF43F5E);
  static const Color violet = Color(0xFFA855F7);

  // Dashboard music-card gradients
  static const List<Color> cardHitz = [Color(0xff6C3FC5), Color(0xff8E54E9)];
  static const List<Color> cardRelax = [Color(0xff4B2E83), Color(0xff2D1B4E)];
  static const List<Color> cardPopPunk = [Color(0xffB24BF3), Color(0xff7A2FC9)];
  static const List<Color> cardNostalgic = [
    Color(0xff5A3E8C),
    Color(0xff36235E),
  ];
  static const List<Color> cardShakeSpirits = [
    Color(0xff7B2FF7),
    Color(0xffA663F2),
  ];
  static const List<Color> cardViral = [Color(0xff3B2168), Color(0xff1E1338)];

  // Login page gradients (Sign in / Google / Apple buttons)
  static const List<Color> loginButtonGradient = [
    Color.fromARGB(255, 102, 52, 133),
    Color.fromARGB(255, 125, 165, 198),
  ];
  static const List<Color> loginButtonGradientDarkHover = [
    Color.fromARGB(255, 130, 75, 170),
    Color.fromARGB(255, 150, 190, 230),
  ];
  static const List<Color> loginButtonGradientLight = [
    Color.fromARGB(255, 190, 165, 215),
    Color.fromARGB(255, 195, 215, 235),
  ];
  static const List<Color> loginButtonGradientLightHover = [
    Color.fromARGB(255, 205, 180, 225),
    Color.fromARGB(255, 210, 228, 246),
  ];

  // Apple button's hovered glow tint (dark / light mode).
  static const Color appleGlowDark = Color.fromARGB(255, 227, 120, 246);
  static const Color appleGlowLight = Color.fromARGB(255, 140, 60, 160);

  // Status colors (success / warning popups)
  static const Color successDark = Color.fromARGB(255, 178, 255, 199);
  static const Color successLight = Color(0xff2E7D32);

  static Color glassSurface(
    bool isDarkMode, {
    double darkAlpha = 0.08,
    double lightAlpha = 0.04,
  }) {
    return isDarkMode
        ? Colors.white.withValues(alpha: darkAlpha)
        : Colors.black.withValues(alpha: lightAlpha);
  }

  static Color glassBorder(
    bool isDarkMode, {
    double darkAlpha = 0.15,
    double lightAlpha = 0.10,
  }) {
    return isDarkMode
        ? Colors.white.withValues(alpha: darkAlpha)
        : Colors.black.withValues(alpha: lightAlpha);
  }

  static List<Color> accentGradient(Color accent) {
    final HSLColor hsl = HSLColor.fromColor(accent);
    final Color end = hsl
        .withHue((hsl.hue + 28) % 360)
        .withLightness((hsl.lightness + 0.14).clamp(0.0, 1.0))
        .toColor();
    return [accent, end];
  }

  static Color textPrimary(bool isDarkMode) =>
      isDarkMode ? Colors.white : Colors.black87;

  static Color textSecondary(bool isDarkMode) =>
      isDarkMode ? Colors.white70 : Colors.black54;

  static Color textMuted(bool isDarkMode) =>
      isDarkMode ? Colors.white54 : Colors.black45;

  static Color textFaint(bool isDarkMode) =>
      isDarkMode ? Colors.white38 : Colors.black38;
}
