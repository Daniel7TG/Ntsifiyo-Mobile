import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/theme.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/states.dart';
import '../auth/auth_controller.dart';
import 'dashboard_providers.dart';

/// Dashboard de estudiante y visitante (mirror móvil de
/// StudentDashboard.jsx / VisitorDashboard.jsx).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('¡Hola, ${user?.firstname ?? ''}!'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: dashboard.when(
        loading: () =>
            const LoadingState(message: 'Cargando tu progreso...'),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
              const _QuickActions(),
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
        color: AppColors.primary,
      ),
      StatCard(
        label: 'Total XP',
        value: '$experience',
        subText: 'Puntos globales',
        icon: Icons.emoji_events,
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
    const xpPerLevel = 100;
    final level = (data['level'] ?? 1) as num;
    final experience =
        (data['experience'] ?? data['totalExperience'] ?? 0) as num;
    final currentLevelXp = experience % xpPerLevel;
    final xpToNext = xpPerLevel - currentLevelXp;

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
            value: currentLevelXp.toDouble(),
            max: xpPerLevel.toDouble(),
            color: AppColors.warning,
            centerLabel: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(currentLevelXp / xpPerLevel * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  'NIVEL $level',
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
            '$currentLevelXp / $xpPerLevel XP',
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.textMain),
          ),
          Text(
            'Faltan $xpToNext XP para el nivel ${level + 1}',
            style:
                const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '¡Estás al día! No tienes actividades pendientes.',
                style: TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
            )
          else
            for (final activity
                in pending.take(3).whereType<Map<String, dynamic>>())
              _PendingTile(activity: activity),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.go('/dashboard/asignaciones'),
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

class _PendingTile extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _PendingTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final game = activity['game'] is Map<String, dynamic>
        ? activity['game'] as Map<String, dynamic>
        : activity;
    final info = gameInfoFor(game['gameType'] as String?);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
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
        ],
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aún no has completado actividades.\n¡Comienza a jugar para ver tu historial aquí!',
                style: TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w500),
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
                          backgroundColor: AppColors.borderLight,
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aún no hay usuarios en la tabla.',
                style: TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
            )
          else
            for (var i = 0;
                i < users.length && i < 5;
                i++)
              _LeaderTile(
                  rank: i + 1,
                  user: users[i] is Map<String, dynamic>
                      ? users[i] as Map<String, dynamic>
                      : {}),
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
    final medal = switch (user['rank'] ?? rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
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
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 18))
                : Text('#${user['rank'] ?? rank}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textLight)),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
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
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
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

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.map, 'Explorar Mapa', 'Recorre los temas del idioma', '/mapa',
          AppColors.primaryBlue),
      (Icons.sports_esports, 'Jugar Ahora', 'Practica con juegos', '/juegos',
          AppColors.success),
      (Icons.menu_book, 'Diccionario', 'Consulta palabras en mazahua',
          '/diccionario', const Color(0xFF7C3AED)),
    ];

    return KidCard(
      accentColor: const Color(0xFF8353EC),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
              icon: Icons.rocket_launch,
              color: Color(0xFF8353EC),
              title: 'Acciones Rápidas'),
          const SizedBox(height: 12),
          for (final (icon, title, subtitle, path, color) in actions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: KidCard(
                accentColor: color,
                shadowOffset: 4,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onTap: () => context.go(path),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                          Text(subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textLight),
                  ],
                ),
              ),
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
