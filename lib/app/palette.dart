import 'package:flutter/material.dart';

import 'theme.dart';

/// Tokens de texto/superficie que sí cambian entre claro y oscuro (mirror
/// parcial de AppColors: los colores de marca —primary, warning, success…—
/// se quedan tal cual, ver [adaptBrand]).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color textMain;
  final Color textMuted;
  final Color textLight;
  final Color border;
  final Color borderLight;
  final Color surface;

  /// Sombra dura neutra (antes repetida a mano como `Color(0xFFCBD5E1)` en
  /// 4 archivos). En oscuro el negro desaparece contra el fondo, así que
  /// este valor se vuelve más oscuro que la superficie en vez de más claro.
  final Color shadowNeutral;

  final Gradient backgroundGradient;

  const AppPalette({
    required this.textMain,
    required this.textMuted,
    required this.textLight,
    required this.border,
    required this.borderLight,
    required this.surface,
    required this.shadowNeutral,
    required this.backgroundGradient,
  });

  static const light = AppPalette(
    textMain: AppColors.textMain,
    textMuted: AppColors.textMuted,
    textLight: AppColors.textLight,
    border: AppColors.border,
    borderLight: AppColors.borderLight,
    surface: AppColors.surface,
    shadowNeutral: Color(0xFFCBD5E1),
    backgroundGradient: AppColors.backgroundGradient,
  );

  static const dark = AppPalette(
    textMain: Color(0xFFE4E8E6),
    textMuted: Color(0xFF98A2A0),
    textLight: Color(0xFF7E8A87),
    border: Color(0xFF2C3633),
    borderLight: Color(0xFF232B28),
    surface: Color(0xFF1D2422),
    shadowNeutral: Color(0xFF151B19),
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF141E1A), Color(0xFF1E1D16)],
    ),
  );

  @override
  AppPalette copyWith({
    Color? textMain,
    Color? textMuted,
    Color? textLight,
    Color? border,
    Color? borderLight,
    Color? surface,
    Color? shadowNeutral,
    Gradient? backgroundGradient,
  }) {
    return AppPalette(
      textMain: textMain ?? this.textMain,
      textMuted: textMuted ?? this.textMuted,
      textLight: textLight ?? this.textLight,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      surface: surface ?? this.surface,
      shadowNeutral: shadowNeutral ?? this.shadowNeutral,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      shadowNeutral: Color.lerp(shadowNeutral, other.shadowNeutral, t)!,
      backgroundGradient:
          Gradient.lerp(backgroundGradient, other.backgroundGradient, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

/// Adapta un color de MARCA (naranja de un juego, verde de acierto…) para que
/// siga siendo legible en oscuro, conservando el tono y subiendo solo la
/// luminosidad — la misma regla de derivación que la paleta de texto.
/// Los ~15 colores de `activity_config.dart` y otros literales hardcodeados
/// (no solo los 6 nombrados en AppColors) pasan por aquí sin necesitar un
/// mapa exhaustivo.
Color adaptBrand(BuildContext context, Color color) {
  if (Theme.of(context).brightness == Brightness.light) return color;
  final hsl = HSLColor.fromColor(color);
  if (hsl.lightness >= 0.55) return color;
  return hsl.withLightness((hsl.lightness + 0.16).clamp(0.0, 0.92)).toColor();
}
