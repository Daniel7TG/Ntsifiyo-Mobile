import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../core/api/error_messages.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../core/storage/media_cache_key.dart';
import '../../data/models/models.dart';
import '../../data/services/misc_services.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/states.dart';

/// Tipos de contenido y orden de pestañas (mirror de TABS en ContentSection.jsx).
/// Los SVG son los mismos que usa el diccionario para estas categorías
/// (`_categoryInfo` en `dictionary_screen.dart`) — el backend los agrupa
/// bajo `MediaType`, la web y esta app bajo la misma iconografía.
const _contentTabs = [
  ('POEM', 'Poemas', 'assets/svgs/diccionario/topic_poemas.svg',
      Color(0xFFF59E0B)),
  ('LEGEND', 'Leyendas', 'assets/svgs/diccionario/topic_leyendas.svg',
      Color(0xFF7C3AED)),
  ('ANECDOTE', 'Cuentos', 'assets/svgs/diccionario/topic_anecdotas.svg',
      Color(0xFF059669)),
  ('SONG', 'Canciones', 'assets/svgs/diccionario/topic_canciones.svg',
      Color(0xFFDB2777)),
];

/// Primera página de cada pestaña. El backend fija `PAGE_SIZE = 10`
/// (`mediaPageSize`) e ignora `size`; `_MediaList` pide las siguientes
/// páginas por su cuenta y las acumula en estado local.
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
              for (final (_, label, svgAsset, color) in _contentTabs)
                Tab(
                  text: label,
                  icon: SvgPicture.asset(
                    svgAsset,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                        adaptBrand(context, color), BlendMode.srcIn),
                  ),
                ),
            ],
          ),
        ),
        body: !isOnline
            ? const EmptyState(
                title: 'Necesitas conexión',
                subtitle:
                    'Las canciones, leyendas, anécdotas y poemas se reproducen en línea. Conéctate a internet para verlas.',
                svgAsset: 'assets/svgs/warning.svg',
              )
            : TabBarView(
                children: [
                  for (final (type, _, svgAsset, color) in _contentTabs)
                    _MediaList(type: type, svgAsset: svgAsset, color: color),
                ],
              ),
      ),
    );
  }
}

class _MediaList extends ConsumerStatefulWidget {
  final String type;
  final String svgAsset;
  final Color color;

  const _MediaList(
      {required this.type, required this.svgAsset, required this.color});

  @override
  ConsumerState<_MediaList> createState() => _MediaListState();
}

class _MediaListState extends ConsumerState<_MediaList> {
  final List<MediaItem> _extra = [];
  int _page = 0;
  bool _loadingMore = false;
  // true en cuanto una página (la primera o una siguiente) vuelve con menos
  // de mediaPageSize elementos: el backend no informa totalPages, así que
  // esa es la única señal de "ya no hay más" (ver CLAUDE.md/plan).
  bool _exhausted = false;

  Future<void> _loadMore() async {
    if (_loadingMore || _exhausted) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;
    try {
      final page = await ref
          .read(mediaServiceProvider)
          .getMediaByType(widget.type, page: nextPage);
      if (!mounted) return;
      setState(() {
        _extra.addAll(page);
        _page = nextPage;
        if (page.length < mediaPageSize) _exhausted = true;
      });
    } catch (_) {
      // Silencioso: "Ver más" se puede volver a tocar sin perder lo ya cargado.
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _refresh() {
    setState(() {
      _extra.clear();
      _page = 0;
      _exhausted = false;
    });
    ref.invalidate(mediaByTypeProvider(widget.type));
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(mediaByTypeProvider(widget.type));

    return media.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          SkeletonListTile(),
          SkeletonListTile(),
          SkeletonListTile(),
          SkeletonListTile(),
        ],
      ),
      error: (e, _) => ErrorState(
        message: friendlyErrorMessage(e),
        onRetry: _refresh,
      ),
      data: (firstPage) {
        final items = [...firstPage, ..._extra];
        final canLoadMore = !_exhausted && firstPage.length >= mediaPageSize;
        final showFooter = canLoadMore || _loadingMore;

        if (items.isEmpty) {
          return const EmptyState(
            title: 'Sin contenido por ahora',
            subtitle: 'Pronto habrá más material aquí.',
            svgAsset: 'assets/svgs/inactive.svg',
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => _refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length + (showFooter ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _loadingMore
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : TextButton(
                            onPressed: _loadMore,
                            child: Text('Ver más',
                                style: TextStyle(
                                    color: widget.color,
                                    fontWeight: FontWeight.w700)),
                          ),
                  ),
                );
              }

              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: KidCard(
                  accentColor: widget.color,
                  padding: const EdgeInsets.all(12),
                  onTap: item.id == null
                      ? null
                      : () => _showDetail(
                          context, item, widget.color, widget.svgAsset),
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
                                  cacheKey: mediaCacheKey(item.overviewImage!),
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      _placeholder(widget.svgAsset, widget.color),
                                )
                              : _placeholder(widget.svgAsset, widget.color),
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
                                      size: 14, color: AppColors.textMuted),
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
                                      color: widget.color),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.play_circle_fill,
                          color: widget.color, size: 36),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

Widget _placeholder(String svgAsset, Color color) => Container(
      color: color.withValues(alpha: 0.12),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );

String _formatDuration(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Modal de detalle con imagen, descripción y botón "Comenzar"
/// (mirror del media-modal de ContentSection.jsx).
void _showDetail(
    BuildContext context, MediaItem item, Color color, String svgAsset) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.palette.surface,
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
                          cacheKey: mediaCacheKey(item.overviewImage!),
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              _placeholder(svgAsset, color),
                        )
                      : _placeholder(svgAsset, color),
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
