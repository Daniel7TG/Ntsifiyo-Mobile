import 'activity_config.dart';

/// Zona del mapa de aventuras (mirror de GameMap.jsx) + qué actividades vive.
///
/// `topics` son temas de `CachedGames.topic`, tal cual los usa el resto de la
/// app. Las dos zonas de media (`FOREST`/Campamento, `PLAIN`/Llanura) no
/// filtran por tema: se llenan por `gameTypes`, porque esos tipos son
/// "historia + juego" (`MEDIA_ANECDOTE`/`MEDIA_LEGEND`/`MEDIA_SONG`/
/// `MEDIA_POEM`) y el tema con que venga tageado el juego, si tiene alguno,
/// es irrelevante para decidir en qué zona vive. Las zonas por tema, a la
/// inversa, excluyen los tipos de media al resolver sus juegos (ver
/// `progress_providers.dart`): un juego de media tageado con `topic:
/// ANIMALS` no debe aparecer también en la Granja ni contarse dos veces.
class MapZone {
  final String id;
  final String label;
  final String img;
  final double x, y, w, h;
  final List<(String, String)> topics;
  final List<String> gameTypes;

  const MapZone(
    this.id,
    this.label,
    this.img,
    this.x,
    this.y,
    this.w,
    this.h, {
    this.topics = const [],
    this.gameTypes = const [],
  });

  bool contains(double mx, double my) =>
      mx >= x && mx <= x + w && my >= y && my <= y + h;
}

/// Lienzo original de las capas del mapa; los WebP se exportan al 50 %.
const mapImageWidth = 5516.0;
const mapImageHeight = 3072.0;

/// Zonas del mapa: límites alfa de las capas originales sin recortar.
///
/// `FOREST` se etiqueta "Campamento", no "Bosque": `assets/map/forest.webp`
/// dibuja una fogata con troncos y tiendas de campaña, no un bosque, y es la
/// zona a la que el backend asocia `LEGENDS`/`ANECDOTES`
/// (`GameCategory.java`). El id se conserva para no tocar el resto del
/// mapeo zona → categoría.
const mapZones = <MapZone>[
  MapZone(
    'FOREST',
    'Campamento',
    'assets/map/forest.webp',
    526,
    364,
    1176,
    522,
    gameTypes: [ActivityTypes.mediaAnecdote, ActivityTypes.mediaLegend],
  ),
  MapZone(
    'PARK',
    'Parque',
    'assets/map/park.webp',
    2113,
    1853,
    2571,
    1170,
    topics: [('GREETINGS', 'Saludos'), ('COLORS', 'Colores')],
  ),
  MapZone(
    'COMMUNITY',
    'Comunidad',
    'assets/map/community.webp',
    3616,
    226,
    1836,
    1167,
    topics: [('CLOTHES', 'Ropa')],
  ),
  MapZone(
    'SCHOOL',
    'Escuela',
    'assets/map/school.webp',
    336,
    1681,
    1396,
    1152,
    topics: [('VOWELS', 'Vocales'), ('PRONOUNS', 'Pronombres')],
  ),
  MapZone(
    'CLINIC',
    'Clínica',
    'assets/map/clinic.webp',
    4582,
    1475,
    876,
    1325,
    topics: [
      ('BODY_PARTS', 'Partes del cuerpo'),
      ('FIVE_SENSES', 'Los cinco sentidos'),
    ],
  ),
  MapZone(
    'MARKET',
    'Mercado',
    'assets/map/market.webp',
    3554,
    1280,
    1029,
    569,
    topics: [('FRUITS', 'Frutas')],
  ),
  MapZone(
    'KITCHEN',
    'Cocina',
    'assets/map/kitchen.webp',
    2111,
    1149,
    1265,
    911,
    topics: [('FOOD', 'Comida')],
  ),
  MapZone(
    'PLAIN',
    'Llanura',
    'assets/map/plain.webp',
    2241,
    587,
    1308,
    563,
    // MEDIA_POEM no existe en el GameType del backend (sí MEDIA_SONG,
    // MEDIA_ANECDOTE, MEDIA_LEGEND) — es una invención del cliente en
    // activity_config.dart. Se deja igual: no cuesta nada y cubre el día
    // que se añada.
    gameTypes: [ActivityTypes.mediaSong, ActivityTypes.mediaPoem],
  ),
  MapZone(
    'FARM',
    'Granja',
    'assets/map/farm.webp',
    989,
    1308,
    1205,
    637,
    topics: [('ANIMALS', 'Animales')],
  ),
];
