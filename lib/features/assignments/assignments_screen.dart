import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/activity_config.dart';
import '../../app/theme.dart';
import '../../core/api/error_messages.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/states.dart';
import '../dashboard/dashboard_providers.dart';
import '../games/game_launcher.dart';

/// Asignaciones del estudiante (mirror de StudentAssignments.jsx).
class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  int _page = 0;
  bool _starting = false;

  Future<void> _play(Map<String, dynamic> activity) async {
    final id = activity['id'];
    if (id is! int) return;
    final gameType = activity['gameType'] as String?;
    final info = gameInfoFor(gameType);

    setState(() => _starting = true);
    try {
      await launchGameWithLoading(
        context,
        ref,
        assignmentId: id,
        gameTypeId: info.id,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar la actividad: $e')),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignments = ref.watch(studentActivitiesProvider(_page));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tus Asignaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(studentActivitiesProvider(_page)),
          ),
        ],
      ),
      body: assignments.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            SkeletonListTile(),
            SkeletonListTile(),
            SkeletonListTile(),
            SkeletonListTile(),
            SkeletonListTile(),
          ],
        ),
        error: (e, _) => ErrorState(
          message: friendlyErrorMessage(e),
          onRetry: () => ref.invalidate(studentActivitiesProvider(_page)),
        ),
        data: (paged) => paged.content.isEmpty
            ? const EmptyState(
                title: '¡Estás al día!',
                subtitle: 'No tienes actividades asignadas pendientes.',
                svgAsset: 'assets/svgs/success_assignment.svg',
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Completa las actividades asignadas por tu maestro para ganar experiencia.',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  for (final activity in paged.content)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AssignmentCard(
                        activity: activity,
                        disabled: _starting,
                        onPlay: () => _play(activity),
                      ),
                    ),
                  if (paged.totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed:
                              paged.first ? null : () => setState(() => _page--),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          'Página ${paged.number + 1} de ${paged.totalPages}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted),
                        ),
                        IconButton(
                          onPressed:
                              paged.last ? null : () => setState(() => _page++),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final bool disabled;
  final VoidCallback onPlay;

  const _AssignmentCard({
    required this.activity,
    required this.disabled,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final info = gameInfoFor(activity['gameType'] as String?);
    final difficult = activity['difficult'] as String?;
    final difficultyColor = switch (difficult) {
      Difficulty.easy => AppColors.success,
      Difficulty.medium => AppColors.warning,
      Difficulty.hard => AppColors.error,
      _ => AppColors.textLight,
    };

    return KidCard(
      accentColor: info.color,
      padding: const EdgeInsets.all(16),
      onTap: disabled ? null : onPlay,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: info.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(info.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (activity['title'] ?? info.title) as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      info.title,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: difficultyColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        Difficulty.label(difficult),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: difficultyColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${activity['experience'] ?? 0} XP',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            disabled ? Icons.hourglass_empty : Icons.play_circle_fill,
            color: info.color,
            size: 36,
          ),
        ],
      ),
    );
  }
}
