import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/theme.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/states.dart';
import 'game_session.dart';
import 'games_providers.dart';

/// Panel de actividades de un tipo de juego (mirror de GameAccessPanel.jsx).
class GameAccessScreen extends ConsumerStatefulWidget {
  final String gameTypeId; // id corto: 'quiz', 'memorama', etc.

  const GameAccessScreen({super.key, required this.gameTypeId});

  @override
  ConsumerState<GameAccessScreen> createState() => _GameAccessScreenState();
}

class _GameAccessScreenState extends ConsumerState<GameAccessScreen> {
  int _page = 0;
  bool _starting = false;

  GameInfo get _info => activityConfig.values.firstWhere(
        (g) => g.id == widget.gameTypeId,
        orElse: () => gameInfoFor(null),
      );

  Future<void> _play(GameSummaryDto game) async {
    setState(() => _starting = true);
    try {
      await ref.read(gameSessionProvider.notifier).startFromGame(game);
      if (!mounted) return;
      context.push('/games/${_info.id}/jugar');
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
    final info = _info;
    final activities =
        ref.watch(activitiesByTypeProvider((info.type, _page)));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(info.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(activitiesByTypeProvider((info.type, _page))),
          ),
        ],
      ),
      body: activities.when(
        loading: () => const LoadingState(message: 'Cargando actividades...'),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(activitiesByTypeProvider((info.type, _page))),
        ),
        data: (paged) => paged.content.isEmpty
            ? const EmptyState(
                title: 'No hay actividades disponibles',
                subtitle: 'Pide a tu maestro que cree una actividad para ti.',
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Encabezado con ícono y descripción
                  Row(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: info.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: info.color.withValues(alpha: 0.3),
                              width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(info.svgAsset,
                            fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.subtitle,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: info.color,
                              ),
                            ),
                            Text(
                              info.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  for (final game in paged.content)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ActivityCard(
                        game: game,
                        info: info,
                        disabled: _starting,
                        onPlay: () => _play(game),
                      ),
                    ),
                  if (paged.totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: paged.first
                                ? null
                                : () => setState(() => _page--),
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text(
                            'Página ${paged.number + 1} de ${paged.totalPages}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted),
                          ),
                          IconButton(
                            onPressed: paged.last
                                ? null
                                : () => setState(() => _page++),
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final GameSummaryDto game;
  final GameInfo info;
  final bool disabled;
  final VoidCallback onPlay;

  const _ActivityCard({
    required this.game,
    required this.info,
    required this.disabled,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyColor = switch (game.difficult) {
      Difficulty.easy => AppColors.success,
      Difficulty.medium => AppColors.warning,
      Difficulty.hard => AppColors.error,
      _ => AppColors.textLight,
    };

    return KidCard(
      accentColor: info.color,
      padding: const EdgeInsets.all(16),
      onTap: disabled ? null : onPlay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  Difficulty.label(game.difficult),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: difficultyColor,
                  ),
                ),
              ),
            ],
          ),
          if ((game.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              game.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.help_outline,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${game.totalQuestions ?? '-'} retos',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.bolt, size: 16, color: AppColors.warning),
              const SizedBox(width: 2),
              Text(
                '+${game.experience ?? 0} XP',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning),
              ),
              const Spacer(),
              KidButton(
                label: 'Jugar',
                icon: Icons.play_arrow,
                color: info.color,
                loading: disabled,
                onPressed: disabled ? null : onPlay,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
