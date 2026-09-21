import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

import 'palette.dart';

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

ThemeData buildAppTheme(Brightness brightness) {
  const displayFont = 'Poppins';
  const bodyFont = 'PublicSans';
  final isDark = brightness == Brightness.dark;
  final palette = isDark ? AppPalette.dark : AppPalette.light;

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: bodyFont,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.primaryBlue,
      surface: palette.surface,
      error: AppColors.error,
    ),
    canvasColor: Colors.transparent,
    scaffoldBackgroundColor: Colors.transparent,
    dialogTheme: const DialogThemeData(backgroundColor: Colors.transparent),
    extensions: [palette],
  );

  return base.copyWith(
    textTheme: base.textTheme
        .apply(
          bodyColor: palette.textMain,
          displayColor: palette.textMain,
        )
        .copyWith(
          displayLarge: TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w900,
              color: palette.textMain),
          displayMedium: TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w900,
              color: palette.textMain),
          displaySmall: TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w800,
              color: palette.textMain),
          headlineLarge: TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w900,
              color: palette.textMain),
          headlineMedium: TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w800,
              color: palette.textMain),
          headlineSmall: TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w800,
              color: palette.textMain),
          titleLarge: TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w700,
              color: palette.textMain),
          titleMedium: TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w600,
              color: palette.textMain),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: palette.textMain,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: displayFont,
        fontWeight: FontWeight.w800,
        fontSize: 20,
        color: palette.textMain,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: TextStyle(color: palette.textLight),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.textMain,
      contentTextStyle: TextStyle(
          fontFamily: bodyFont, color: palette.surface, fontSize: 14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input)),
    ),
  );
}

/// Fondo degradado global — envuelve el contenido de cada pantalla.
/// Sigue el brillo del tema activo (claro/oscuro/según el sistema).
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final gradient = context.palette.backgroundGradient;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
