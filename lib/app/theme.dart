import 'package:flutter/material.dart';

/// Paleta de la guía de estilo web (client/public/tailwind.config.js).
abstract class AppColors {
  static const primary = Color(0xFFE65100); // Naranja primario
  static const primaryBlue = Color(0xFF1E3A8A); // Azul primario
  static const backgroundStart = Color(0xFFA8E6CF); // Menta
  static const backgroundEnd = Color(0xFFFFF9C4); // Amarillo crema
  static const surface = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF374151); // Gris de la guía
  static const accentPink = Color(0xFFD81B60); // Rosa de realce

  static const textMuted = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  /// Degradado vertical global del fondo (menta → crema).
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundStart, backgroundEnd],
  );
}

/// Radios unificados (convención de la web: card 16, input 12, kid-card 24).
abstract class AppRadius {
  static const kidCard = 24.0;
  static const card = 16.0;
  static const input = 12.0;
}

/// Oscurece un color multiplicando sus canales (mirror de utils/colorUtils.js).
Color darken(Color color, [double amount = 0.2]) {
  final f = 1.0 - amount;
  return Color.fromARGB(
    (color.a * 255).round(),
    ((color.r * 255) * f).round().clamp(0, 255),
    ((color.g * 255) * f).round().clamp(0, 255),
    ((color.b * 255) * f).round().clamp(0, 255),
  );
}

ThemeData buildAppTheme() {
  const displayFont = 'Poppins';
  const bodyFont = 'PublicSans';

  final base = ThemeData(
    useMaterial3: true,
    fontFamily: bodyFont,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.primaryBlue,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: Colors.transparent,
  );

  return base.copyWith(
    textTheme: base.textTheme
        .apply(
          bodyColor: AppColors.textMain,
          displayColor: AppColors.textMain,
        )
        .copyWith(
          displayLarge: const TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain),
          displayMedium: const TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain),
          displaySmall: const TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain),
          headlineLarge: const TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain),
          headlineMedium: const TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain),
          headlineSmall: const TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain),
          titleLarge: const TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain),
          titleMedium: const TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.textMain,
      titleTextStyle: TextStyle(
        fontFamily: displayFont,
        fontWeight: FontWeight.w800,
        fontSize: 20,
        color: AppColors.textMain,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.textLight),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textMain,
      contentTextStyle: const TextStyle(
          fontFamily: bodyFont, color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input)),
    ),
  );
}

/// Fondo degradado global — envuelve el contenido de cada pantalla.
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: child,
    );
  }
}
