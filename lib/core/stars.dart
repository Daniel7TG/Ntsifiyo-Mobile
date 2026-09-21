/// Estrellas locales por actividad (0-5).
///
/// El backend no manda puntuación: `POST /api/activities/complete` devuelve
/// solo `RewardResponseDTO(xpGained, actualXp, currentLevel, isLevelUp)`
/// (`ActivityService.java` en el backend Spring) — nunca aciertos, total ni
/// estrellas. Los aciertos ya los cuenta cada vista de juego y ya se
/// persisten en `CompletedGames(correctAnswers, totalQuestions)`; esta es la
/// única función que los convierte en una puntuación mostrable, y es la
/// única fuente de verdad para no tener dos escalas de estrellas distintas
/// en la app (el resumen de partida y el progreso del mapa comparten esta
/// misma función).
library;

const int maxStars = 5;

/// Redondeo hacia abajo: 4 de 5 aciertos = 4 estrellas, 4 de 6 = 3.
int starsFor(int correctAnswers, int totalQuestions) {
  if (totalQuestions <= 0) return 0;
  return (correctAnswers * maxStars ~/ totalQuestions).clamp(0, maxStars);
}
