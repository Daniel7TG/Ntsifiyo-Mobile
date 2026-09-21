import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../core/api/error_messages.dart';
import '../../core/storage/app_database.dart';
import '../../core/sync/game_cache_service.dart';
import '../../core/sync/resource_update_service.dart';
import '../../core/xp_utils.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/avatar_circle.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/states.dart';
import '../auth/auth_controller.dart';
import '../dashboard/dashboard_providers.dart';
import '../dictionary/dictionary_repository.dart';
import '../games/game_launcher.dart';
import '../games/games_providers.dart';
import '../progress/progress_providers.dart';
import '../settings/theme_controller.dart';
import 'avatar_picker_sheet.dart';
import 'avatar_provider.dart';

/// Perfil: estadísticas, progreso, asignaciones/historial, tabla de
/// líderes y ajustes (mirror móvil de StudentDashboard.jsx /
/// VisitorDashboard.jsx, reubicado desde Inicio — que ahora es el camino
/// de aprendizaje).
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          children: const [
            SkeletonBox(width: 52, height: 52, borderRadius: 26),
            SizedBox(width: 12),
            SkeletonBox(width: 120, height: 16),
          ],
        ),
        const SizedBox(height: 16),
        const SkeletonGrid(
            itemCount: 4, aspectRatio: 1.35, padding: EdgeInsets.zero),
        const SizedBox(height: 16),
        KidCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              SkeletonBox(width: 130, height: 90, borderRadius: 90),
              SizedBox(height: 12),
              SkeletonBox(width: 100, height: 12),
            ],
          ),
        ),
        const SizedBox(height: 16),
        KidCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 140, height: 14),
              SizedBox(height: 14),
              SkeletonListTile(),
              SkeletonListTile(),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
          IconButton(
            tooltip: 'Acerca de',
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.go('/perfil/acerca'),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: dashboard.when(
        loading: () => const _ProfileSkeleton(),
        error: (e, _) => ErrorState(
          message: friendlyErrorMessage(e),
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const _HeaderAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user?.firstname ?? '',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _StatsGrid(data: data, isStudent: user?.isStudent == true),
              const SizedBox(height: 16),
              _ProgressCard(data: data),
              const SizedBox(height: 16),
              if (user?.isStudent == true) ...[
                _PendingActivitiesCard(
                    pending: (data['pending'] ?? []) as List),
                const SizedBox(height: 16),
                _LeaderboardCard(
                  title: 'Mejores de tu clase',
                  users: (data['classmates'] ?? []) as List,
                ),
              ] else ...[
                _RecentActivitiesCard(
                    activities: (data['recentActivities'] ?? []) as List),
                const SizedBox(height: 16),
                _LeaderboardCard(
                  title: 'Tabla de Líderes',
                  users: (data['topUsers'] ?? []) as List,
                ),
              ],
              const SizedBox(height: 16),
              const _ThemeCard(),
              const SizedBox(height: 16),
              const _OfflineDataCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.kidCard)),
        title: const Text('¿Cerrar sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isStudent;

  const _StatsGrid({required this.data, required this.isStudent});

  @override
  Widget build(BuildContext context) {
    final level = data['level'] ?? 1;
    final experience = data['experience'] ?? data['totalExperience'] ?? 0;
    final inrow = data['inrow'] ?? 0;
    final finished =
        data['finished'] ?? data['totalActivitiesCompleted'] ?? 0;

    final cards = [
      StatCard(
        label: 'Nivel Actual',
        value: '$level',
        subText: 'Nivel $level',
        icon: Icons.verified,
        color: AppColors.success,
      ),
      StatCard(
        label: 'Racha de Días',
        value: '$inrow',
        subText: (inrow is num && inrow > 0) ? '¡En racha!' : 'Vuelve mañana',
        icon: Icons.local_fire_department,
        svgAsset: 'assets/svgs/racha.svg',
        color: AppColors.primary,
      ),
      StatCard(
        label: 'Total XP',
        value: '$experience',
        subText: 'Puntos globales',
        icon: Icons.emoji_events,
        svgAsset: 'assets/svgs/xp.svg',
        color: AppColors.warning,
      ),
      StatCard(
        label: 'Actividades',
        value: '$finished',
        subText: 'Completadas',
        icon: Icons.fact_check,
        color: const Color(0xFF7C3AED),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: cards,
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ProgressCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final experience =
        ((data['experience'] ?? data['totalExperience'] ?? 0) as num).toInt();
    final progress = LevelProgress.fromTotalXp(experience);

    return KidCard(
      accentColor: AppColors.warning,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const _CardTitle(
              icon: Icons.trending_up,
              color: AppColors.warning,
              title: 'Progreso Actual'),
          const SizedBox(height: 16),
          ProgressRing(
            value: progress.xpInLevel.toDouble(),
            max: progress.xpForLevel.toDouble(),
            color: AppColors.warning,
            semanticLabel: 'Progreso hacia el siguiente nivel',
            centerLabel: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(progress.progress * 100).round()}%',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    color: context.palette.textMain,
                  ),
                ),
                Text(
                  'NIVEL ${progress.level}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${progress.xpInLevel} / ${progress.xpForLevel} XP',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: context.palette.textMain),
          ),
          Text(
            'Faltan ${progress.xpRemaining} XP para el nivel ${progress.level + 1}',
            style: TextStyle(fontSize: 12, color: context.palette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _PendingActivitiesCard extends StatelessWidget {
  final List pending;
  const _PendingActivitiesCard({required this.pending});

  @override
  Widget build(BuildContext context) {
    return KidCard(
      accentColor: AppColors.success,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
              icon: Icons.assignment,
              color: AppColors.success,
              title: 'Tus Asignaciones'),
          const SizedBox(height: 12),
          if (pending.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '¡Estás al día! No tienes actividades pendientes.',
                style: TextStyle(
                    color: context.palette.textMuted,
                    fontWeight: FontWeight.w500),
              ),
            )
          else
            for (final activity
                in pending.take(3).whereType<Map<String, dynamic>>())
              _PendingTile(activity: activity),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.go('/perfil/asignaciones'),
              icon: const Text('Ver todas',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              label: const Icon(Icons.chevron_right, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> activity;
  const _PendingTile({required this.activity});

  @override
  ConsumerState<_PendingTile> createState() => _PendingTileState();
}

class _PendingTileState extends ConsumerState<_PendingTile> {
  bool _starting = false;

  Map<String, dynamic> get _game =>
      widget.activity['game'] is Map<String, dynamic>
          ? widget.activity['game'] as Map<String, dynamic>
          : widget.activity;

  /// Inicia la asignación directamente (mirror del NextLessonCard clicable).
  Future<void> _play() async {
    final id = widget.activity['id'] ?? _game['id'] ?? _game['activityId'];
    if (id is! int) {
      context.go('/perfil/asignaciones');
      return;
    }
    final info = gameInfoFor(_game['gameType'] as String?);

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
    final game = _game;
    final info = gameInfoFor(game['gameType'] as String?);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.input),
        onTap: _starting ? null : _play,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: info.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(info.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (game['title'] ?? info.title) as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      info.title,
                      style: TextStyle(
                          fontSize: 12, color: context.palette.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '+${game['experience'] ?? 0} XP',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppColors.warning),
              ),
              const SizedBox(width: 6),
              Icon(
                _starting ? Icons.hourglass_empty : Icons.play_circle_fill,
                color: info.color,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivitiesCard extends StatelessWidget {
  final List activities;
  const _RecentActivitiesCard({required this.activities});

  @override
  Widget build(BuildContext context) {
    return KidCard(
      accentColor: AppColors.success,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
              icon: Icons.history,
              color: AppColors.primaryBlue,
              title: 'Actividades Recientes'),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aún no has completado actividades.\n¡Comienza a jugar para ver tu historial aquí!',
                style: TextStyle(
                    color: context.palette.textMuted,
                    fontWeight: FontWeight.w500),
              ),
            )
          else
            for (final activity
                in activities.take(5).whereType<Map<String, dynamic>>())
              _RecentTile(activity: activity),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _RecentTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final info = gameInfoFor(activity['gameType'] as String?);
    final total = (activity['totalQuestions'] ?? 0) as num;
    final correct = (activity['correctAnswers'] ?? 0) as num;
    final passed = activity['passed'] == true;
    final percent = total > 0 ? (correct / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (passed ? AppColors.success : AppColors.error)
            .withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: (passed ? AppColors.success : AppColors.error)
              .withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: info.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(info.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (activity['gameTitle'] ?? info.title) as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 6,
                          backgroundColor: context.palette.borderLight,
                          color:
                              passed ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$correct/$total',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${activity['experienceEarned'] ?? 0} XP',
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: AppColors.warning),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardCard extends ConsumerWidget {
  final String title;
  final List users;

  const _LeaderboardCard({required this.title, required this.users});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KidCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
              icon: Icons.leaderboard, color: AppColors.warning, title: title),
          const SizedBox(height: 12),
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aún no hay usuarios en la tabla.',
                style: TextStyle(
                    color: context.palette.textMuted,
                    fontWeight: FontWeight.w500),
              ),
            )
          else
            for (var i = 0; i < users.length && i < 5; i++)
              _LeaderTile(
                  rank: i + 1,
                  user: users[i] is Map<String, dynamic>
                      ? users[i] as Map<String, dynamic>
                      : {}),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push('/perfil/lideres'),
              icon: const Text('Ver tabla completa',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              label: const Icon(Icons.chevron_right, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends ConsumerWidget {
  const _HeaderAvatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarControllerProvider);
    final avatarId = avatarState.value ?? 0;

    return InkWell(
      onTap: () => showAvatarPickerSheet(context),
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AvatarCircle(
            avatarId: avatarId,
            radius: 26,
            ring: true,
            ringColor: AppColors.primary,
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> user;

  const _LeaderTile({required this.rank, required this.user});

  @override
  Widget build(BuildContext context) {
    final medalAsset = switch (user['rank'] ?? rank) {
      1 => 'assets/svgs/medallas/medalla_oro.svg',
      2 => 'assets/svgs/medallas/medalla_plata.svg',
      3 => 'assets/svgs/medallas/medalla_bronce.svg',
      _ => null,
    };
    final name = [
      user['firstName'] ?? user['firstname'] ?? '',
      user['lastName'] ?? user['lastname'] ?? '',
    ].where((s) => s.toString().isNotEmpty).join(' ');
    final userType = user['userType'] == Roles.student
        ? 'Estudiante'
        : user['userType'] == Roles.visitor
            ? 'Visitante'
            : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: medalAsset != null
                ? SvgPicture.asset(medalAsset, width: 24, height: 24)
                : Text('#${user['rank'] ?? rank}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: context.palette.textLight)),
          ),
          AvatarCircle(
            avatarId: (user['avatarId'] as num?)?.toInt() ?? 0,
            radius: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isNotEmpty ? name : (user['username'] ?? '') as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (userType.isNotEmpty)
                  Text('$userType • Nivel ${user['level'] ?? 1}',
                      style: TextStyle(
                          fontSize: 11, color: context.palette.textMuted)),
              ],
            ),
          ),
          Text(
            '${user['experience'] ?? 0} XP',
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: AppColors.warning),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends ConsumerWidget {
  const _ThemeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return KidCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
              icon: Icons.dark_mode, color: AppColors.primaryBlue, title: 'Tema'),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Claro')),
              ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.smartphone),
                  label: Text('Sistema')),
              ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Oscuro')),
            ],
            selected: {mode},
            onSelectionChanged: (selected) =>
                ref.read(themeModeProvider.notifier).setMode(selected.first),
          ),
        ],
      ),
    );
  }
}

/// Salida de emergencia para un dispositivo cuyas cachés offline quedaron
/// dañadas (diccionario/juegos vacíos o incompletos). Borra solo lo que se
/// repuebla solo (`resetOfflineCaches`): las estrellas del mapa
/// (`CompletedGames`) y la cola de resultados sin sincronizar no se tocan.
class _OfflineDataCard extends ConsumerStatefulWidget {
  const _OfflineDataCard();

  @override
  ConsumerState<_OfflineDataCard> createState() => _OfflineDataCardState();
}

class _OfflineDataCardState extends ConsumerState<_OfflineDataCard> {
  bool _resetting = false;

  Future<void> _confirmAndReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.kidCard)),
        title: const Text('¿Restablecer datos offline?'),
        content: const Text(
          'Borra el diccionario y los juegos guardados en este dispositivo '
          'para volver a descargarlos desde cero. Tu progreso y las '
          'partidas pendientes de sincronizar no se pierden.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _resetting = true);
    try {
      // `resetOfflineCaches()` también vacía `ResourceUpdates`: el próximo
      // `checkAndRefresh()` sale sin cursor guardado, exactamente como una
      // instalación nueva, y cae a la fecha del bundle como línea base.
      await ref.read(appDatabaseProvider).resetOfflineCaches();
      ref.invalidate(dictionaryProvider);
      // `dictionaryProvider` se repuebla solo al leerse (loadLocal() cae al
      // bundle si drift está vacío). `CachedGames` no tiene ese fallback
      // automático — progressSnapshotProvider/gamesForZoneProvider/
      // activitiesByTypeProvider/gamesByTypeProvider leen la tabla directo —
      // así que hay que sembrarla explícitamente antes de invalidar lo que
      // depende de ella.
      final gameCache = ref.read(gameCacheServiceProvider);
      await gameCache.seedFromBundleIfNewer();
      unawaited(ref
          .read(resourceUpdateServiceProvider)
          .checkAndRefresh()
          .then((_) => gameCache.completeMissingGameMedia())
          .catchError((_) {}));
      ref.invalidate(progressSnapshotProvider);
      ref.invalidate(gamesByTypeProvider);
      ref.invalidate(dashboardProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Datos offline restablecidos. Se descargarán de nuevo.'),
      ));
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KidCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
              icon: Icons.cleaning_services,
              color: AppColors.error,
              title: 'Datos offline'),
          const SizedBox(height: 8),
          Text(
            'Si el diccionario o los juegos se ven incompletos, restablece '
            'la copia guardada en este dispositivo.',
            style: TextStyle(fontSize: 12, color: context.palette.textMuted),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _resetting ? null : _confirmAndReset,
            icon: _resetting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.restart_alt),
            label: const Text('Restablecer datos offline'),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _CardTitle(
      {required this.icon, required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
