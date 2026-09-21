import 'package:flutter/material.dart';

/// Tipos de actividad del backend (mirror de client/src/config/activityConfig.jsx).
/// PUZZLE está deshabilitado en la web y no se migra.
abstract class ActivityTypes {
  static const questionnaire = 'QUESTIONNAIRE';
  static const fastMemory = 'FAST_MEMORY';
  static const intruder = 'INTRUDER';
  static const findTheWord = 'FIND_THE_WORD';
  static const mediaSong = 'MEDIA_SONG';
  static const mediaAnecdote = 'MEDIA_ANECDOTE';
  static const mediaLegend = 'MEDIA_LEGEND';
  static const mediaPoem = 'MEDIA_POEM';
  static const memoryGame = 'MEMORY_GAME';
  static const lottery = 'LOTTERY';
  static const maze = 'MAZE';
  static const pairs = 'PAIRS';
  static const catLines = 'CAT_LINES';
  static const fillBlank = 'FILL_BLANK';
}

/// Juegos cuyo resumen se basa en preguntas.
const questionnaireTypes = [
  ActivityTypes.questionnaire,
  ActivityTypes.intruder,
  ActivityTypes.fillBlank,
];

/// Juegos basados en pares de palabras.
const pairTypes = [
  ActivityTypes.memoryGame,
  ActivityTypes.fastMemory,
  ActivityTypes.lottery,
  ActivityTypes.maze,
  ActivityTypes.pairs,
  ActivityTypes.catLines,
  ActivityTypes.findTheWord,
];

const mediaTypes = [
  ActivityTypes.mediaSong,
  ActivityTypes.mediaAnecdote,
  ActivityTypes.mediaLegend,
  ActivityTypes.mediaPoem,
];

/// Tipos no disponibles en teléfono. El laberinto necesita arrastrar sobre
/// una superficie que una pantalla de móvil no da. Se deja la entrada en
/// `activityConfig` y la vista en `views/laberinto_game_view.dart` intacta:
/// volver a habilitarlo es sacarlo de este set.
const disabledGameTypes = {ActivityTypes.maze};

bool isGameTypeEnabled(String? type) =>
    type != null && !disabledGameTypes.contains(type);

class GameInfo {
  final String type;
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final String svgAsset;
  final IconData icon;

  const GameInfo({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.svgAsset,
    required this.icon,
  });
}

/// Configuración de los 10 juegos activos + 4 tipos de media.
const Map<String, GameInfo> activityConfig = {
  ActivityTypes.fastMemory: GameInfo(
    type: ActivityTypes.fastMemory,
    id: 'memoria_rapida',
    title: 'Memoria Rápida',
    subtitle: 'Tarjetas de Memoria',
    description:
        'Aprende vocabulario y pronunciación mazahua emparejando tarjetas interactivas. Ejercita tu memoria mientras descubres nuevas palabras.',
    color: Color(0xFFE65100),
    svgAsset: 'assets/svgs/juegos/memoria_rapida_premium.svg',
    icon: Icons.style,
  ),
  ActivityTypes.questionnaire: GameInfo(
    type: ActivityTypes.questionnaire,
    id: 'quiz',
    title: 'Quiz',
    subtitle: 'Preguntas y Respuestas',
    description:
        'Pon a prueba tus conocimientos del idioma mazahua con preguntas desafiantes. Evalúa gramática, vocabulario y comprensión.',
    color: Color(0xFF7C3AED),
    svgAsset: 'assets/svgs/juegos/quiz_premium.svg',
    icon: Icons.quiz,
  ),
  ActivityTypes.intruder: GameInfo(
    type: ActivityTypes.intruder,
    id: 'intruso',
    title: 'El Intruso',
    subtitle: 'Encuentra al Intruso',
    description:
        'Identifica qué palabra no pertenece al grupo. Mejora tu vocabulario y capacidad de categorización.',
    color: Color(0xFFD97706),
    svgAsset: 'assets/svgs/juegos/intruso_premium.svg',
    icon: Icons.psychology,
  ),
  ActivityTypes.memoryGame: GameInfo(
    type: ActivityTypes.memoryGame,
    id: 'memorama',
    title: 'Memorama',
    subtitle: 'Emparejar Pares',
    description:
        'Voltea las cartas y encuentra todas las parejas. Aprende vocabulario mazahua emparejando palabras con su significado en español o imágenes.',
    color: Color(0xFFE65100),
    svgAsset: 'assets/svgs/juegos/memorama_premium.svg',
    icon: Icons.style,
  ),
  ActivityTypes.lottery: GameInfo(
    type: ActivityTypes.lottery,
    id: 'loteria',
    title: 'Lotería',
    subtitle: 'Selecciona las cartas',
    description:
        'Selecciona las cartas de tu tablero que coincidan con las que van apareciendo en la pila. ¡Rápido y sin penalizaciones para ganar más puntos!',
    color: Color(0xFFB45309),
    svgAsset: 'assets/svgs/juegos/loteria_premium.svg',
    icon: Icons.casino,
  ),
  ActivityTypes.maze: GameInfo(
    type: ActivityTypes.maze,
    id: 'laberinto',
    title: 'Laberinto',
    subtitle: 'Traza el camino',
    description:
        'Encuentra tu camino en el laberinto y une los conceptos sin equivocarte.',
    color: Color(0xFF10B981),
    svgAsset: 'assets/svgs/juegos/laberinto_premium.svg',
    icon: Icons.route,
  ),
  ActivityTypes.findTheWord: GameInfo(
    type: ActivityTypes.findTheWord,
    id: 'encuentra_palabra',
    title: 'Sopa de Letras',
    subtitle: 'Encuentra las palabras escondidas',
    description:
        'Localiza cada palabra mazahua escondida en la cuadrícula de letras. Arrastra para marcar la palabra; según la dificultad la cuadrícula crece y aparecen más direcciones.',
    color: Color(0xFF0284C7),
    svgAsset: 'assets/svgs/juegos/sopa_letras_premium.svg',
    icon: Icons.search,
  ),
  ActivityTypes.pairs: GameInfo(
    type: ActivityTypes.pairs,
    id: 'pares',
    title: 'Pares',
    subtitle: 'Enlaza los pares',
    description:
        'Une las cartas del lado izquierdo con su par del lado derecho para completar los desafíos.',
    color: Color(0xFF10B981),
    svgAsset: 'assets/svgs/juegos/pares_premium.svg',
    icon: Icons.link,
  ),
  ActivityTypes.catLines: GameInfo(
    type: ActivityTypes.catLines,
    id: 'tripas',
    title: 'Tripas del Gato',
    subtitle: 'Une los pares con líneas',
    description:
        'Traza líneas libres para unir cada carta con su par sin cruzar las líneas ya dibujadas. Completa todos los pares antes de que se acabe el tiempo.',
    color: Color(0xFF0EA5E9),
    svgAsset: 'assets/svgs/juegos/tripas_premium.svg',
    icon: Icons.gesture,
  ),
  ActivityTypes.fillBlank: GameInfo(
    type: ActivityTypes.fillBlank,
    id: 'fill_blank',
    title: 'Completar Oración',
    subtitle: 'Rellena el espacio en blanco',
    description:
        'Completa las oraciones seleccionando la palabra correcta para el espacio en blanco. Practica vocabulario y gramática mazahua en contexto.',
    color: Color(0xFF0284C7),
    svgAsset: 'assets/svgs/juegos/completar_oracion_premium.svg',
    icon: Icons.edit_note,
  ),
  ActivityTypes.mediaSong: GameInfo(
    type: ActivityTypes.mediaSong,
    id: 'cancion',
    title: 'Canción',
    subtitle: 'Actividad con canción',
    description: 'Disfruta y aprende con esta actividad musical en mazahua.',
    color: Color(0xFFDB2777),
    svgAsset: 'assets/svgs/diccionario/topic_canciones.svg',
    icon: Icons.music_note,
  ),
  ActivityTypes.mediaAnecdote: GameInfo(
    type: ActivityTypes.mediaAnecdote,
    id: 'anecdota',
    title: 'Anécdota',
    subtitle: 'Actividad con anécdota',
    description: 'Aprende del contexto y la historia mediante anécdotas.',
    color: Color(0xFF059669),
    svgAsset: 'assets/svgs/diccionario/topic_anecdotas.svg',
    icon: Icons.menu_book,
  ),
  ActivityTypes.mediaLegend: GameInfo(
    type: ActivityTypes.mediaLegend,
    id: 'leyenda',
    title: 'Leyenda',
    subtitle: 'Actividad con leyenda',
    description:
        'Descubre historias tradicionales y expande tu conocimiento cultural.',
    color: Color(0xFF7C3AED),
    svgAsset: 'assets/svgs/diccionario/topic_leyendas.svg',
    icon: Icons.map,
  ),
  ActivityTypes.mediaPoem: GameInfo(
    type: ActivityTypes.mediaPoem,
    id: 'poema',
    title: 'Poema',
    subtitle: 'Actividad con poema',
    description:
        'Aprende vocabulario a través de la poesía y cultura mazahua.',
    color: Color(0xFFF59E0B),
    svgAsset: 'assets/svgs/diccionario/topic_poemas.svg',
    icon: Icons.auto_stories,
  ),
};

/// Juegos jugables mostrados en la navegación/panel (orden de la web).
/// MAZE no aparece: ver [disabledGameTypes].
const playableGameTypes = [
  ActivityTypes.memoryGame,
  ActivityTypes.questionnaire,
  ActivityTypes.intruder,
  ActivityTypes.lottery,
  ActivityTypes.fastMemory,
  ActivityTypes.pairs,
  ActivityTypes.catLines,
  ActivityTypes.fillBlank,
  ActivityTypes.findTheWord,
];

GameInfo gameInfoFor(String? type) =>
    activityConfig[type] ??
    const GameInfo(
      type: 'UNKNOWN',
      id: 'unknown',
      title: 'Juego',
      subtitle: '',
      description: '',
      color: Color(0xFF6B7280),
      svgAsset: 'assets/svgs/QuestionMark.svg',
      icon: Icons.videogame_asset,
    );
