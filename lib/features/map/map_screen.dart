import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/map_zones.dart';
import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../core/api/error_messages.dart';
import '../../core/stars.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/immersive_chrome.dart';
import '../../shared/widgets/states.dart';
import '../games/game_launcher.dart';
import 'map_geometry.dart';
import '../progress/progress_providers.dart';

/// El mapa se vive en horizontal: pantalla completa, sin AppBar ni bottom
/// nav. Delega en `lib/shared/immersive_chrome.dart`, que también usa el
/// reproductor de contenido para su modo pantalla completa con video.
Future<void> enterMapChrome() => enterImmersiveLandscape();
Future<void> exitMapChrome() => exitImmersiveLandscape();

/// Mapa interactivo por zonas, a pantalla completa y en horizontal. El mapa
/// es *la* progresión de la app (ver CLAUDE.md): cada zona lleva un anillo
/// con el porcentaje de estrellas ganadas sobre las posibles
/// (`zoneProgressProvider`), calculado sobre un universo cerrado — solo los
/// juegos compilados en `assets/games/manifest.json`
/// (`GameCacheService.bundleGameIds`) — para que publicar contenido nuevo
/// nunca haga retroceder el progreso de nadie. Al elegir un juego la vista
/// regresa a vertical; al volver del juego se restaura el horizontal.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? _highlightedZone;
  bool _sheetOpen = false;
  final _masks = <String, ZoneMask>{};
  String? _hoveredZone;
  String? _labelHovered;

  @override
  void initState() {
    super.initState();
    // El mapa se administra a sí mismo: entra en horizontal inmersivo sin
    // depender de en qué rama del shell viva (hoy cuelga de Explorar).
    enterMapChrome();
    _loadMasks();
  }

  @override
  void dispose() {
    exitMapChrome();
    super.dispose();
  }

  Future<void> _loadMasks() async {
    await Future.wait(
      mapZones.map((zone) async {
        try {
          final mask = await ZoneMask.load(zone.img);
          if (mounted) _masks[zone.id] = mask;
        } catch (error) {
          // Las etiquetas siguen disponibles si falla la decodificación.
          debugPrint('No se pudo cargar la silueta de ${zone.label}: $error');
        }
      }),
    );
  }

  MapZone? _zoneAt(Offset local, Size displaySize) {
    final point = Offset(
      local.dx / displaySize.width * mapImageWidth,
      local.dy / displaySize.height * mapImageHeight,
    );
    for (final zone in mapZones.reversed) {
      if (_masks[zone.id]?.contains(zone, point) ?? false) return zone;
    }
    return null;
  }

  void _hover(String? id) {
    if (_hoveredZone != id) setState(() => _hoveredZone = id);
  }

  Future<void> _selectZone(MapZone zone) async {
    if (_sheetOpen || _highlightedZone != null) return;
    setState(() => _highlightedZone = zone.id);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() {
      _highlightedZone = null;
      _hoveredZone = null;
    });
    await _openZone(zone);
  }

  void _onTapMap(Offset local, Size displaySize) {
    final zone = _zoneAt(local, displaySize);
    if (zone != null) _selectZone(zone);
  }

  Future<void> _openZone(MapZone zone) async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    final selectedGame = await showModalBottomSheet<GameSummaryDto>(
      context: context,
      backgroundColor: context.palette.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ZoneSheet(zone: zone),
    );
    _sheetOpen = false;
    if (!mounted) return;

    if (selectedGame != null) {
      await launchGameWithLoading(context, ref, game: selectedGame);
      // El anillo de esta zona (y el total) pudieron cambiar mientras se
      // jugaba, tanto si terminó online como si quedó encolada offline.
      ref.invalidate(progressSnapshotProvider);
    }

    if (mounted) await enterMapChrome();
  }

  void _exitMap() => context.canPop() ? context.pop() : context.go('/explorar');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewportW = constraints.maxWidth;
          final viewportH = constraints.maxHeight;

          // Cubrir el viewport completo; el excedente se recorre con
          // pan/zoom del InteractiveViewer.
          // Reserva espacio para botones legibles, también con texto grande.
          // El excedente se puede recorrer con el gesto de arrastre.
          final textScale = math.max(
            1.0,
            MediaQuery.textScalerOf(context).scale(12) / 12,
          );
          var displayH = math.max(viewportH, 500.0 * textScale);
          var displayW = displayH * (mapImageWidth / mapImageHeight);
          if (displayW < viewportW) {
            displayW = viewportW;
            displayH = displayW * (mapImageHeight / mapImageWidth);
          }
          final displaySize = Size(displayW, displayH);

          return Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  constrained: false,
                  minScale: 0.8,
                  maxScale: 4,
                  boundaryMargin: const EdgeInsets.all(40),
                  child: SizedBox(
                    width: displayW,
                    height: displayH,
                    child: MouseRegion(
                      cursor: _hoveredZone == null
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                      onHover: (event) => _hover(
                        _labelHovered ??
                            _zoneAt(event.localPosition, displaySize)?.id,
                      ),
                      onExit: (_) => _hover(null),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (details) =>
                            _onTapMap(details.localPosition, displaySize),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/map/map.webp',
                                fit: BoxFit.fill,
                              ),
                            ),

                            // El brillo respeta el alfa del recorte y no altera su tamaño.
                            for (final zone in mapZones)
                              Positioned(
                                left: zone.x / mapImageWidth * displayW,
                                top: zone.y / mapImageHeight * displayH,
                                width: zone.w / mapImageWidth * displayW,
                                height: zone.h / mapImageHeight * displayH,
                                child: IgnorePointer(
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 150),
                                    opacity:
                                        _highlightedZone == zone.id ||
                                            _hoveredZone == zone.id
                                        ? 1
                                        : 0,
                                    child: ColorFiltered(
                                      colorFilter: const ColorFilter.matrix([
                                        1.10,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1.10,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1.10,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                      ]),
                                      child: Image.asset(
                                        zone.img,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: CustomMultiChildLayout(
                                delegate: MapLabelLayout(),
                                children: [
                                  for (var i = 0; i < mapZones.length; i++)
                                    LayoutId(
                                      id: i,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        onEnter: (_) {
                                          _labelHovered = mapZones[i].id;
                                          _hover(_labelHovered);
                                        },
                                        onHover: (_) => _hover(mapZones[i].id),
                                        onExit: (_) {
                                          _labelHovered = null;
                                          _hover(null);
                                        },
                                        child: Semantics(
                                          button: true,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () =>
                                                _selectZone(mapZones[i]),
                                            child: _ZoneLabel(
                                              zone: mapZones[i],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Botón para salir del mapa (única navegación visible)
              Positioned(
                top: 12,
                left: 12,
                child: SafeArea(
                  child: _RoundMapButton(icon: Icons.close, onTap: _exitMap),
                ),
              ),

              // Pista de uso
              Positioned(
                top: 12,
                right: 12,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Toca una zona',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.touch_app,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundMapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), offset: Offset(0, 3)),
          ],
        ),
        child: Icon(icon, color: AppColors.textMain, size: 24),
      ),
    );
  }
}

/// Etiqueta de zona con su anillo de progreso: estrellas ganadas / posibles
/// sobre los juegos compilados en el bundle. Una zona sin juegos elegibles
/// se ve al 100% (`ZoneProgress.percent`) — no debe leerse como "en
/// construcción", es simplemente una zona que no frena a nadie.
class _ZoneLabel extends ConsumerWidget {
  final MapZone zone;
  const _ZoneLabel({required this.zone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress =
        ref.watch(zoneProgressProvider)[zone.id] ?? ZoneProgress.empty;
    final percent = (progress.percent * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProgressRing(
            value: progress.percent,
            max: 1,
            size: 26,
            strokeWidth: 4,
            color: AppColors.success,
            semanticLabel: '${zone.label}: $percent% completado',
            centerLabel: Text(
              '$percent',
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w900,
                color: AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            zone.label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cinco estrellas compactas para la mejor puntuación de una actividad
/// (`lib/core/stars.dart`), reutilizada en la tarjeta de cada juego.
class _MiniStars extends StatelessWidget {
  final int stars;
  const _MiniStars({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= maxStars; i++)
          Icon(
            i <= stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i <= stars ? AppColors.warning : Colors.grey.shade400,
            size: 13,
          ),
      ],
    );
  }
}

class _ZoneSheet extends ConsumerStatefulWidget {
  final MapZone zone;

  const _ZoneSheet({required this.zone});

  @override
  ConsumerState<_ZoneSheet> createState() => _ZoneSheetState();
}

class _ZoneSheetState extends ConsumerState<_ZoneSheet> {
  String? _activeTopic;

  bool get _isMediaZone => widget.zone.gameTypes.isNotEmpty;

  void _play(GameSummaryDto game) {
    Navigator.of(context).pop(game);
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        ref.watch(zoneProgressProvider)[widget.zone.id] ?? ZoneProgress.empty;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.zone.img,
                    width: 64,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.zone.label,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${progress.earnedStars} de ${progress.possibleStars} '
                        'estrellas · ${progress.completedGames} de '
                        '${progress.totalGames} actividades',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                ProgressRing(
                  value: progress.percent,
                  max: 1,
                  size: 42,
                  strokeWidth: 6,
                  color: AppColors.success,
                  centerLabel: Text(
                    '${(progress.percent * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (_isMediaZone)
            Expanded(child: _buildGamesList(scrollController, null))
          else
            Expanded(
              child: ref
                  .watch(zoneAvailableTopicsProvider(widget.zone.id))
                  .when(
                    loading: () => ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [SkeletonListTile(), SkeletonListTile()],
                    ),
                    error: (e, _) =>
                        ErrorState(message: friendlyErrorMessage(e)),
                    data: (topics) {
                      if (topics.isEmpty) {
                        return const EmptyState(
                          title: 'Aún no hay actividades aquí',
                          subtitle: 'Vuelve a explorar más tarde.',
                        );
                      }
                      _activeTopic ??= topics.first.$1;
                      return Column(
                        children: [
                          SizedBox(
                            height: 44,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              children: [
                                for (final (id, label) in topics)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(label),
                                      selected: _activeTopic == id,
                                      selectedColor: AppColors.primary
                                          .withValues(alpha: 0.15),
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
                            child: _buildGamesList(
                              scrollController,
                              _activeTopic,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildGamesList(ScrollController scrollController, String? topic) {
    final games = ref.watch(gamesForZoneProvider((widget.zone.id, topic)));
    final gameStars = ref.watch(gameStarsProvider);
    return games.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: const [SkeletonListTile(), SkeletonListTile()],
      ),
      error: (e, _) => ErrorState(
        message: friendlyErrorMessage(e),
        onRetry: () =>
            ref.invalidate(gamesForZoneProvider((widget.zone.id, topic))),
      ),
      data: (list) => list.isEmpty
          ? const EmptyState(
              title: 'Aún no hay actividades aquí',
              subtitle: 'Vuelve a explorar más tarde.',
            )
          : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final game = list[index];
                final info = gameInfoFor(game.gameType);
                final stars = gameStars[game.id] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: KidCard(
                    accentColor: info.color,
                    shadowOffset: 4,
                    padding: const EdgeInsets.all(12),
                    onTap: () => _play(game),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: info.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(info.icon, color: Colors.white, size: 24),
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
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${info.title} · +${game.displayXp} XP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              _MiniStars(stars: stars),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.play_circle_fill,
                          color: info.color,
                          size: 34,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
