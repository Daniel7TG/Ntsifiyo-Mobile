import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/theme.dart';
import '../../core/storage/app_database.dart';
import '../../data/models/models.dart';
import '../../data/services/activity_service.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/states.dart';
import '../games/game_session.dart';

/// Dimensiones naturales de map.webp (mirror de GameMap.jsx).
const _mapW = 2729.0;
const _mapH = 1521.0;

class _Zone {
  final String id;
  final String label;
  final String img;
  final double x, y, w, h;

  const _Zone(this.id, this.label, this.img, this.x, this.y, this.w, this.h);

  bool contains(double mx, double my) =>
      mx >= x && mx <= x + w && my >= y && my <= y + h;
}

/// Zonas del mapa con coordenadas sobre la imagen base (de GameMap.jsx).
const _zones = [
  _Zone('FOREST', 'Bosque', 'assets/map/forest.webp', 278, 196, 542, 232),
  _Zone('PARK', 'Parque', 'assets/map/park.webp', 1057, 920, 1363, 589),
  _Zone('COMMUNITY', 'Comunidad', 'assets/map/community.webp', 1791, 119, 918, 546),
  _Zone('SCHOOL', 'Escuela', 'assets/map/school.webp', 169, 832, 660, 565),
  _Zone('CLINIC', 'Clínica', 'assets/map/clinic.webp', 2207, 818, 502, 406),
  _Zone('MARKET', 'Mercado', 'assets/map/market.webp', 1760, 642, 504, 279),
  _Zone('KITCHEN', 'Cocina', 'assets/map/kitchen.webp', 1047, 474, 620, 547),
  _Zone('PLAIN', 'Llanura', 'assets/map/plain.webp', 1102, 287, 656, 281),
  _Zone('FARM', 'Granja', 'assets/map/farm.webp', 505, 657, 551, 299),
];

/// Tópicos por zona (mirror de utils/gameCategories.js).
const _topicsByZone = <String, List<(String, String)>>{
  'SCHOOL': [('VOWELS', 'Vocales'), ('PRONOUNS', 'Pronombres')],
  'COMMUNITY': [('CLOTHES', 'Ropa')],
  'KITCHEN': [('FOOD', 'Comida')],
  'FARM': [('ANIMALS', 'Animales')],
  'MARKET': [('FRUITS', 'Frutas')],
  'CLINIC': [
    ('BODY_PARTS', 'Partes del cuerpo'),
    ('FIVE_SENSES', 'Los cinco sentidos')
  ],
  'PARK': [('GREETINGS', 'Saludos'), ('COLORS', 'Colores')],
  'FOREST': [],
  'PLAIN': [],
};

/// Juegos por tópico, con fallback al caché offline.
final gamesByTopicProvider = FutureProvider.autoDispose
    .family<List<GameSummaryDto>, String>((ref, topic) async {
  final service = ref.read(activityServiceProvider);
  final db = ref.read(appDatabaseProvider);
  try {
    final paged = await service.getGamesByTopic(topic);
    return paged.content;
  } catch (_) {
    final cached = await db.cachedGamesByTopic(topic);
    return [
      for (final g in cached)
        GameSummaryDto(
          id: g.gameId,
          title: g.title,
          difficult: g.difficult,
          gameType: g.gameType,
          topic: g.topic,
          experience: g.experience,
          totalQuestions: g.totalQuestions,
        ),
    ];
  }
});

/// Mapa interactivo por zonas, rotado 90° para aprovechar toda la pantalla
/// en vertical. Un solo GestureDetector resuelve la zona tocada por
/// coordenadas (más confiable que apilar detectores dentro del zoom).
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? _highlightedZone;

  void _onTapMap(Offset local, Size displaySize) {
    final mx = local.dx / displaySize.width * _mapW;
    final my = local.dy / displaySize.height * _mapH;

    for (final zone in _zones) {
      if (zone.contains(mx, my)) {
        setState(() => _highlightedZone = zone.id);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          setState(() => _highlightedZone = null);
          _openZone(zone);
        });
        return;
      }
    }
  }

  void _openZone(_Zone zone) {
    final topics = _topicsByZone[zone.id] ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ZoneSheet(zone: zone, topics: topics),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Mapa de Aventuras'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Toca una zona 👆',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Rotado 90°: el eje largo del mapa corre a lo largo del teléfono.
          final viewportW = constraints.maxHeight; // ancho tras rotación
          final viewportH = constraints.maxWidth; // alto tras rotación

          // Llenar el alto disponible del viewport rotado; el resto se
          // recorre con pan/zoom.
          var displayH = viewportH;
          var displayW = displayH * (_mapW / _mapH);
          if (displayW < viewportW) {
            displayW = viewportW;
            displayH = displayW * (_mapH / _mapW);
          }
          final displaySize = Size(displayW, displayH);

          return RotatedBox(
            quarterTurns: 1,
            child: InteractiveViewer(
              constrained: false,
              minScale: 0.8,
              maxScale: 4,
              boundaryMargin: const EdgeInsets.all(40),
              child: SizedBox(
                width: displayW,
                height: displayH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) =>
                      _onTapMap(details.localPosition, displaySize),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset('assets/map/map.webp',
                            fit: BoxFit.fill),
                      ),

                      // Resaltado de la zona tocada
                      for (final zone in _zones)
                        if (_highlightedZone == zone.id)
                          Positioned(
                            left: zone.x / _mapW * displayW,
                            top: zone.y / _mapH * displayH,
                            width: zone.w / _mapW * displayW,
                            height: zone.h / _mapH * displayH,
                            child: IgnorePointer(
                              child: Image.asset(zone.img,
                                  fit: BoxFit.fill),
                            ),
                          ),

                      // Etiquetas de zona (contra-rotadas para leerse
                      // derechas con el teléfono en vertical)
                      for (final zone in _zones)
                        Positioned(
                          left: (zone.x + zone.w / 2) / _mapW * displayW - 44,
                          top: (zone.y + zone.h / 2) / _mapH * displayH - 16,
                          child: IgnorePointer(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: _ZoneLabel(zone: zone),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  final _Zone zone;
  const _ZoneLabel({required this.zone});

  @override
  Widget build(BuildContext context) {
    final hasGames = (_topicsByZone[zone.id] ?? []).isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: hasGames ? AppColors.primary : AppColors.border,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasGames ? Icons.sports_esports : Icons.construction,
            size: 14,
            color: hasGames ? AppColors.primary : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            zone.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: hasGames ? AppColors.textMain : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneSheet extends ConsumerStatefulWidget {
  final _Zone zone;
  final List<(String, String)> topics;

  const _ZoneSheet({required this.zone, required this.topics});

  @override
  ConsumerState<_ZoneSheet> createState() => _ZoneSheetState();
}

class _ZoneSheetState extends ConsumerState<_ZoneSheet> {
  String? _activeTopic;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    if (widget.topics.isNotEmpty) _activeTopic = widget.topics.first.$1;
  }

  Future<void> _play(GameSummaryDto game) async {
    setState(() => _starting = true);
    try {
      await ref.read(gameSessionProvider.notifier).startFromGame(game);
      if (!mounted) return;
      final info = gameInfoFor(game.gameType);
      Navigator.of(context).pop();
      context.push('/games/${info.id}/jugar');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el juego: $e')),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(widget.zone.img,
                      width: 64, height: 48, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.zone.label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (widget.topics.isEmpty)
            const Expanded(
              child: EmptyState(
                title: 'Zona en construcción',
                subtitle: 'Muy pronto habrá juegos en esta zona.',
                emoji: '🚧',
              ),
            )
          else ...[
            // Selector de tópicos
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final (id, label) in widget.topics)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _activeTopic == id,
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: _activeTopic == id
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        onSelected: (_) =>
                            setState(() => _activeTopic = id),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _activeTopic == null
                  ? const SizedBox.shrink()
                  : _buildGamesList(scrollController),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGamesList(ScrollController scrollController) {
    final games = ref.watch(gamesByTopicProvider(_activeTopic!));
    return games.when(
      loading: () => const LoadingState(message: 'Buscando juegos...'),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(gamesByTopicProvider(_activeTopic!)),
      ),
      data: (list) => list.isEmpty
          ? const EmptyState(
              title: 'Sin juegos por ahora',
              subtitle: 'Este tema aún no tiene actividades.',
              emoji: '🎒',
            )
          : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final game = list[index];
                final info = gameInfoFor(game.gameType);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: KidCard(
                    accentColor: info.color,
                    shadowOffset: 4,
                    padding: const EdgeInsets.all(12),
                    onTap: _starting ? null : () => _play(game),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: info.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(info.icon,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${info.title} · +${game.experience ?? 0} XP',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.play_circle_fill,
                            color: info.color, size: 34),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
