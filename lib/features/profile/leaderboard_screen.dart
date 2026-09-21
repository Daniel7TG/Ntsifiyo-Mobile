import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../data/models/models.dart';
import '../../data/services/user_service.dart';
import '../../shared/widgets/avatar_circle.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/states.dart';
import '../auth/auth_controller.dart';

/// Provider para la tabla de líderes paginada.
final leaderboardProvider = FutureProvider.autoDispose
    .family<Paged<Map<String, dynamic>>, int>((ref, page) async {
  final service = ref.read(userServiceProvider);
  final data = await service.getLeaderboard(page: page, size: 20);
  return Paged.fromJson(data, (json) => json);
});

/// Pantalla completa de la Tabla de Líderes.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _currentPage = 0;
  final List<Map<String, dynamic>> _allUsers = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPage(0);
  }

  Future<void> _loadPage(int page) async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final service = ref.read(userServiceProvider);
      final raw = await service.getLeaderboard(page: page, size: 20);
      final paged = Paged.fromJson(raw, (json) => json);

      setState(() {
        if (page == 0) _allUsers.clear();
        _allUsers.addAll(paged.content);
        _currentPage = page;
        _hasMore = !paged.last;
      });
    } catch (_) {
      // Ignorar errores en carga paginada secundaria
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);
    final currentUserName = user?.displayName.trim().toLowerCase() ?? '';

    final filteredUsers = _searchQuery.isEmpty
        ? _allUsers
        : _allUsers.where((u) {
            final name = [
              u['firstName'] ?? u['firstname'] ?? '',
              u['lastName'] ?? u['lastname'] ?? '',
              u['username'] ?? '',
            ].join(' ').toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tabla de Líderes'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentPage = 0;
                _allUsers.clear();
              });
              _loadPage(0);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Buscar en la tabla de líderes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: context.palette.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide(color: context.palette.border),
                ),
              ),
            ),
          ),

          // Lista principal
          Expanded(
            child: _allUsers.isEmpty && _isLoadingMore
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 8,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: SkeletonListTile(),
                    ),
                  )
                : _allUsers.isEmpty
                    ? ErrorState(
                        message: 'No se pudo cargar la tabla de líderes',
                        onRetry: () => _loadPage(0),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (!_isLoadingMore &&
                              _hasMore &&
                              scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
                            _loadPage(_currentPage + 1);
                          }
                          return false;
                        },
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            await _loadPage(0);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredUsers.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == filteredUsers.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final item = filteredUsers[index];
                              final rank = item['rank'] ?? (index + 1);
                              final firstName =
                                  item['firstName'] ?? item['firstname'] ?? '';
                              final lastName =
                                  item['lastName'] ?? item['lastname'] ?? '';
                              final fullName = [firstName, lastName]
                                  .where((s) => s.toString().isNotEmpty)
                                  .join(' ');
                              final displayName = fullName.isNotEmpty
                                  ? fullName
                                  : (item['username'] ?? 'Usuario') as String;

                              final isMe = currentUserName.isNotEmpty &&
                                  displayName.trim().toLowerCase() ==
                                      currentUserName;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _LeaderboardRow(
                                  rank: rank is num ? rank.toInt() : index + 1,
                                  userMap: item,
                                  isCurrentUser: isMe,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> userMap;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.rank,
    required this.userMap,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final medalAsset = switch (rank) {
      1 => 'assets/svgs/medallas/medalla_oro.svg',
      2 => 'assets/svgs/medallas/medalla_plata.svg',
      3 => 'assets/svgs/medallas/medalla_bronce.svg',
      _ => null,
    };

    final firstName = userMap['firstName'] ?? userMap['firstname'] ?? '';
    final lastName = userMap['lastName'] ?? userMap['lastname'] ?? '';
    final fullName = [firstName, lastName]
        .where((s) => s.toString().isNotEmpty)
        .join(' ');
    final displayName =
        fullName.isNotEmpty ? fullName : (userMap['username'] ?? '') as String;

    final avatarId = (userMap['avatarId'] as num?)?.toInt() ?? 0;
    final level = (userMap['level'] as num?)?.toInt() ?? 1;
    final experience =
        ((userMap['experience'] ?? userMap['totalExperience'] ?? 0) as num)
            .toInt();
    final userType = userMap['userType'] == Roles.student
        ? 'Estudiante'
        : userMap['userType'] == Roles.visitor
            ? 'Visitante'
            : '';

    return KidCard(
      padding: const EdgeInsets.all(12),
      accentColor: isCurrentUser ? AppColors.warning : null,
      backgroundColor: isCurrentUser
          ? AppColors.warning.withValues(alpha: 0.12)
          : context.palette.surface,
      child: Row(
        children: [
          // Rango / Medalla
          SizedBox(
            width: 36,
            child: medalAsset != null
                ? SvgPicture.asset(medalAsset, width: 28, height: 28)
                : Text(
                    '#$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: context.palette.textLight,
                    ),
                  ),
          ),
          const SizedBox(width: 8),

          // Avatar
          AvatarCircle(
            avatarId: avatarId,
            radius: 20,
            ring: isCurrentUser,
            ringColor: AppColors.warning,
          ),
          const SizedBox(width: 12),

          // Nombre y Nivel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              isCurrentUser ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 15,
                          color: context.palette.textMain,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tú',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$userType • Nivel $level',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Experiencia
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$experience XP',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
