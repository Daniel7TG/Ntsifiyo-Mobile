/// Fórmulas de nivel/XP — mirror exacto de User.java (LEVEL_BASE = 50).
///
/// Las 3 fórmulas clave:
///   1. Costo por nivel:  cost(L → L+1) = 50 × L
///   2. XP acumulada para nivel L:  xp(L) = 25 × L × (L-1)  (cuadrática)
///   3. Nivel a partir de XP:  level = ⌊(1 + √(1 + 8·xp/50)) / 2⌋
///
/// La XP ganada por actividad es proporcional a los aciertos:
///   xpGained = game.experience × correctAnswers / totalQuestions
library;

import 'dart:math' as math;

/// Base del sistema de niveles (idéntica a `User.LEVEL_BASE` en el backend).
const int levelBase = 50;

/// XP acumulada necesaria para *alcanzar* el nivel [level].
///
/// Fórmula: 25 × L × (L − 1).
/// Nivel 1 → 0 XP, Nivel 2 → 50, Nivel 3 → 150, Nivel 4 → 300…
int cumulativeXpFor(int level) => 25 * level * (level - 1);

/// Costo de subir del nivel [level] al siguiente: 50 × L.
int costToNextLevel(int level) => levelBase * level;

/// Nivel que corresponde a [xp] puntos de experiencia acumulados.
///
/// Inversión de la cuadrática: ⌊(1 + √(1 + 8·xp/50)) / 2⌋.
int levelFromXp(int xp) {
  if (xp <= 0) return 1;
  return ((1 + math.sqrt(1 + 8 * xp / levelBase)) / 2).floor();
}

/// Datos de progreso hacia el siguiente nivel, calculados a partir de la
/// XP total acumulada.
class LevelProgress {
  /// Nivel actual.
  final int level;

  /// XP dentro del nivel actual (cuánto se ha avanzado).
  final int xpInLevel;

  /// XP que cuesta completar el nivel actual (ancho de la barra).
  final int xpForLevel;

  /// XP que falta para subir al siguiente nivel.
  int get xpRemaining => xpForLevel - xpInLevel;

  /// Porcentaje de progreso [0.0, 1.0].
  double get progress => xpForLevel > 0 ? xpInLevel / xpForLevel : 0;

  const LevelProgress({
    required this.level,
    required this.xpInLevel,
    required this.xpForLevel,
  });

  /// Calcula el progreso a partir de la XP total acumulada.
  factory LevelProgress.fromTotalXp(int totalXp) {
    final level = levelFromXp(totalXp);
    final xpAtCurrentLevel = cumulativeXpFor(level);
    final xpInLevel = totalXp - xpAtCurrentLevel;
    final xpForLevel = costToNextLevel(level);
    return LevelProgress(
      level: level,
      xpInLevel: xpInLevel,
      xpForLevel: xpForLevel,
    );
  }
}
