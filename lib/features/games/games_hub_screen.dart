import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/theme.dart';
import '../../core/api/error_messages.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/states.dart';
import '../progress/progress_providers.dart';
import 'game_launcher.dart';
import 'games_providers.dart';

/// Panel de acceso libre a los juegos, por secciones de tipo (mirror de las
/// tarjetas de la web, ahora agrupadas). **Sin ningún indicador de
/// progreso**: es acceso libre, crece con cada juego que llegue por
/// `GET /api/catalog/updates` (`gamesByTypeProvider`) y no es el mismo
/// universo que el mapa (`progress_providers.dart`). El único progreso que
/// aparece en esta pantalla es el resumen del mapa, arriba y claramente
/// rotulado como tal — un recordatorio de que la progresión real vive ahí.
class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesByTypeProvider);
    final totalProgress = ref.watch(totalProgressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Juegos')),
      body: gamesAsync.when(
        loading: () => const _HubSkeleton(),
        error: (e, _) => ErrorState(
          message: friendlyErrorMessage(e),
          onRetry: () => ref.invalidate(gamesByTypeProvider),
        ),
        data: (byType) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            MapSummaryCard(progress: totalProgress),
            const SizedBox(height: 20),
            for (final type in playableGameTypes)
              if ((byType[type] ?? const []).isNotEmpty)
                _GameTypeSection(
                  info: activityConfig[type]!,
                  games: byType[type]!,
                ),
          ],
        ),
      ),
    );
  }
}

class _HubSkeleton extends StatelessWidget {
  const _HubSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        KidCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const SkeletonBox(width: 64, height: 64, borderRadius: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 120, height: 12),
                    SizedBox(height: 8),
                    SkeletonBox(width: 90, height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < 3; i++) ...[
          const SkeletonBox(width: 140, height: 16),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                SkeletonBox(width: 150, height: 132, borderRadius: 18),
                SizedBox(width: 12),
                SkeletonBox(width: 150, height: 132, borderRadius: 18),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

/// Único progreso de esta pantalla: el resumen del mapa. Lleva directo a
/// `/explorar/mapa`, que es donde vive la progresión real.
class MapSummaryCard extends StatelessWidget {
  final ZoneProgress progress;
  const MapSummaryCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = (progress.percent * 100).round();
    return KidCard(
      accentColor: AppColors.success,
      padding: const EdgeInsets.all(18),
      semanticLabel: 'Tu aventura en el mapa: $percent% completado',
      onTap: () => context.push('/explorar/mapa'),
      child: Row(
        children: [
          ProgressRing(
            value: progress.percent,
            max: 1,
            size: 64,
            strokeWidth: 8,
            color: AppColors.success,
            centerLabel: Text(
              '$percent%',
              style: const TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TU AVENTURA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  '${progress.earnedStars} de ${progress.possibleStars} estrellas',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                ),
                const Text(
                  'Sigue en el mapa',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.success, size: 28),
        ],
      ),
    );
  }
}

class _GameTypeSection extends StatelessWidget {
  final GameInfo info;
  final List<GameSummaryDto> games;
  const _GameTypeSection({required this.info, required this.games});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'game-icon-${info.id}',
                child: Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: info.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: SvgPicture.asset(info.svgAsset, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.title,
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/inicio/juegos/${info.id}'),
                child: const Text('Ver todos'),
              ),
            ],
          ),
          SizedBox(
            height: 132,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _ActivityCard(info: info, game: game),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  final GameInfo info;
  final GameSummaryDto game;
  const _ActivityCard({required this.info, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 150,
      child: KidCard(
        accentColor: info.color,
        shadowOffset: 4,
        padding: const EdgeInsets.all(12),
        onTap: () => launchGameWithLoading(context, ref,
            game: game, gameTypeId: info.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              game.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 13),
            ),
            Row(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 14, color: info.color),
                const SizedBox(width: 4),
                Text(
                  '${game.totalQuestions ?? '-'} retos',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.play_circle_fill, color: info.color, size: 22),
                const SizedBox(width: 6),
                Text(
                  '+${game.displayXp} XP',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: info.color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
