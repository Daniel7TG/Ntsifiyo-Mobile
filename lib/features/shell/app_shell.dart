import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../core/sync/game_cache_service.dart';
import '../../core/sync/sync_service.dart';
import '../../shared/widgets/states.dart';
import '../dashboard/dashboard_providers.dart';
import '../map/map_screen.dart' show enterMapChrome, exitMapChrome;
import '../sync/sync_summary_sheet.dart';

/// Shell principal con bottom navigation (reemplaza el sidebar de la web).
/// También orquesta el modo offline: dispara la sincronización de resultados
/// pendientes y el precacheo de juegos cuando hay conexión.
class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _mapBranch = 1;
  int _lastChromeIndex = -1;

  bool get _isMapTab => widget.navigationShell.currentIndex == _mapBranch;

  @override
  void initState() {
    super.initState();
    // Al entrar (post-login): sincronizar pendientes y cachear juegos.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncControllerProvider.notifier).trySync();
      ref.read(gameCacheServiceProvider).cacheAllGames();
    });
  }

  /// El mapa se muestra a pantalla completa y en horizontal; el resto de
  /// pestañas siempre en vertical con la barra visible.
  void _applyChromeForTab() {
    final index = widget.navigationShell.currentIndex;
    if (index == _lastChromeIndex) return;
    _lastChromeIndex = index;
    if (index == _mapBranch) {
      enterMapChrome();
    } else {
      exitMapChrome();
    }
  }

  @override
  void dispose() {
    // Al salir del shell (logout), restaurar la orientación vertical.
    exitMapChrome();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    _applyChromeForTab();

    // Mostrar el resumen de sincronización cuando esté listo.
    ref.listen(syncControllerProvider, (previous, summary) async {
      if (summary != null && mounted) {
        ref.read(syncControllerProvider.notifier).dismissSummary();
        // El progreso cambió en el backend: refrescar dashboard.
        ref.invalidate(dashboardProvider);
        await showSyncSummarySheet(context, summary);
      }
    });

    // Al recuperar conexión, reintentar el caché de juegos.
    ref.listen(connectivityStreamProvider, (previous, next) {
      if (next.value == true && previous?.value == false) {
        ref.read(gameCacheServiceProvider).cacheAllGames();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          if (!isOnline && !_isMapTab)
            const SafeArea(bottom: false, child: OfflineBanner()),
          Expanded(child: widget.navigationShell),
        ],
      ),
      // El mapa es pantalla completa: sin barra de navegación.
      bottomNavigationBar: _isMapTab
          ? null
          : NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppColors.primary),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon:
                Icon(Icons.sports_esports, color: AppColors.primary),
            label: 'Juegos',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
            label: 'Diccionario',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle, color: AppColors.primary),
            label: 'Contenido',
          ),
        ],
      ),
    );
  }
}
