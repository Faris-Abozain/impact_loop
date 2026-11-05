import 'package:flutter/material.dart';

import 'hex_color.dart';

class AppColors {
  // Brand – fresh light-green palette
  static Color primary = const Color(0xFF16A34A); // green-600
  static Color primaryDark = const Color(0xFF15803D); // green-700
  static Color primaryDeep = const Color(0xFF14532D); // green-900
  static Color primaryLight = const Color(0xFF4ADE80); // green-400
  static Color accent = const Color(0xFF22D3A6); // mint
  static Color secondPrimary = HexColor('#DCFCE7'); // green-100
  static Color mint = const Color(0xFFF0FDF4); // green-50
  static Color lime = const Color(0xFFBEF264);
  static Color gold = const Color(0xFFFBBF24);
  static Color sky = const Color(0xFF38BDF8);
  static Color violet = const Color(0xFF8B5CF6);

  // Neutrals
  static Color surface = const Color(0xFFF7FBF8);
  static Color card = Colors.white;
  static Color border = const Color(0xFFE3EDE6);
  static Color textPrimary = const Color(0xFF0B1F14);
  static Color textSecondary = const Color(0xFF5B6B61);
  static Color textMuted = const Color(0xFF94A39A);
  static Color warning = const Color(0xFFF59E0B);
  static Color info = const Color(0xFF0EA5E9);

  static Color red = HexColor('#EF4444');
  static Color black = Colors.black;
  static Color blackLite = Colors.black12;
  static Color success = const Color(0xFF22C55E);
  static Color white = Colors.white;
  static Color error = const Color(0xFFEF4444);
  static Color transparent = Colors.transparent;

  static Color gray = Colors.grey;
  static Color grey = HexColor('#8EA3AC');

  // Gradients
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryLight, primary, primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get heroGradient => const LinearGradient(
        colors: [Color(0xFF22C55E), Color(0xFF16A34A), Color(0xFF0F766E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get softGradient => const LinearGradient(
        colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static LinearGradient get walletGradient => const LinearGradient(
        colors: [Color(0xFF14532D), Color(0xFF166534), Color(0xFF16A34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF16A34A).withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: const Color(0xFF16A34A).withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lightens(String color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(HexColor(color));
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
