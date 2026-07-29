import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../data/models/models.dart';
import '../../data/services/misc_services.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/states.dart';

/// Tipos de contenido y orden de pestañas (mirror de TABS en ContentSection.jsx).
const _contentTabs = [
  ('POEM', 'Poemas', Icons.history_edu, Color(0xFFF59E0B)),
  ('LEGEND', 'Leyendas', Icons.auto_stories, Color(0xFF7C3AED)),
  ('ANECDOTE', 'Cuentos', Icons.menu_book, Color(0xFF059669)),
  ('SONG', 'Canciones', Icons.music_note, Color(0xFFDB2777)),
];

final mediaByTypeProvider = FutureProvider.autoDispose
    .family<List<MediaItem>, String>((ref, type) async {
  return ref.read(mediaServiceProvider).getMediaByType(type);
});

/// Sección Contenido (mirror de ContentSection.jsx). Solo online.
class ContentScreen extends ConsumerWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return DefaultTabController(
      length: _contentTabs.length,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Contenido'),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700),
            tabs: [
              for (final (_, label, icon, _) in _contentTabs)
                Tab(text: label, icon: Icon(icon, size: 20)),
            ],
          ),
        ),
        body: !isOnline
            ? const EmptyState(
                title: 'Necesitas conexión',
                subtitle:
                    'Las canciones, leyendas, anécdotas y poemas se reproducen en línea. Conéctate a internet para verlas.',
                emoji: '📡',
              )
            : TabBarView(
                children: [
                  for (final (type, _, icon, color) in _contentTabs)
                    _MediaList(type: type, icon: icon, color: color),
                ],
              ),
      ),
    );
  }
}

class _MediaList extends ConsumerWidget {
  final String type;
  final IconData icon;
  final Color color;

  const _MediaList(
      {required this.type, required this.icon, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(mediaByTypeProvider(type));

    return media.when(
      loading: () => const LoadingState(message: 'Cargando contenido...'),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(mediaByTypeProvider(type)),
      ),
      data: (items) => items.isEmpty
          ? const EmptyState(
              title: 'Sin contenido por ahora',
              subtitle: 'Pronto habrá más material aquí.',
              emoji: '🎬',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: KidCard(
                    accentColor: color,
                    padding: const EdgeInsets.all(12),
                    onTap: item.id == null
                        ? null
                        : () => _showDetail(context, item, color, icon),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 84,
                            height: 64,
                            child: (item.overviewImage ?? '').isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.overviewImage!,
                                    fit: BoxFit.cover,
                                    errorWidget:
                                        (context, url, error) =>
                                            _placeholder(),
                                  )
                                : _placeholder(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (item.duration != null) ...[
                                    const Icon(Icons.schedule,
                                        size: 14,
                                        color: AppColors.textMuted),
                                    const SizedBox(width: 3),
                                    Text(
                                      _formatDuration(item.duration!),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  Text(
                                    Difficulty.label(item.difficult),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: color),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.play_circle_fill, color: color, size: 36),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _placeholder() => Container(
        color: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color, size: 28),
      );
}

String _formatDuration(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Modal de detalle con imagen, descripción y botón "Comenzar"
/// (mirror del media-modal de ContentSection.jsx).
void _showDetail(
    BuildContext context, MediaItem item, Color color, IconData icon) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Portada
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: SizedBox(
                  width: double.infinity,
                  height: 170,
                  child: (item.overviewImage ?? '').isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.overviewImage!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: color.withValues(alpha: 0.12),
                            child: Icon(icon, color: color, size: 48),
                          ),
                        )
                      : Container(
                          color: color.withValues(alpha: 0.12),
                          child: Icon(icon, color: color, size: 48),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (item.duration != null) ...[
                        const Icon(Icons.schedule,
                            size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(item.duration!),
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 14),
                      ],
                      const Icon(Icons.signal_cellular_alt,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        Difficulty.label(item.difficult),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (item.description ?? '').isNotEmpty
                        ? item.description!
                        : 'Sin descripción disponible.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  KidButton(
                    label: 'Comenzar',
                    icon: Icons.play_circle_fill,
                    color: color,
                    expanded: true,
                    onPressed: item.id == null
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            context.push('/reproductor/${item.id}',
                                extra: item);
                          },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
