import '../home/home_providers.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/connectivity/connectivity_service.dart';
import '../../core/storage/media_store.dart';
import '../../core/sync/game_cache_service.dart';
import '../../core/sync/resource_update_service.dart';
import '../../core/sync/sync_service.dart';
import '../../shared/widgets/states.dart';
import '../coyote/coyote_companion.dart';
import '../coyote/coyote_controller.dart';
import '../coyote/coyote_messages.dart';
import '../auth/auth_controller.dart';
import '../dashboard/dashboard_providers.dart';
import '../dictionary/dictionary_repository.dart';
import '../progress/progress_providers.dart';
import '../sync/sync_summary_sheet.dart';
import 'widgets/sendero_nav_bar.dart';

/// Shell principal con la barra inferior de 4 destinos (Inicio, Explorar,
/// Palabras, Perfil). También orquesta el modo offline: dispara la
/// sincronización de resultados pendientes y el precacheo de juegos cuando
/// hay conexión.
///
/// El mapa ya NO es una rama propia: vive como ruta hija de Explorar y
/// cuelga del navigator raíz (pantalla completa e inmersiva, se administra
/// a sí mismo en `MapScreen.initState/dispose`), así que este shell no
/// necesita saber nada sobre él.
class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  /// Rutas de cada rama, en el mismo orden que el StatefulShellRoute.
  static const _branchPaths = ['/inicio', '/explorar', '/palabras', '/perfil'];

  int _lastIndex = -1;

  static const _destinations = [
    SenderoDestination(
      svgAsset: 'assets/svgs/nav/nav_inicio.svg',
      svgAssetSelected: 'assets/svgs/nav/nav_inicio_fill.svg',
      label: 'Inicio',
    ),
    SenderoDestination(
      svgAsset: 'assets/svgs/nav/nav_explorar.svg',
      svgAssetSelected: 'assets/svgs/nav/nav_explorar_fill.svg',
      label: 'Explorar',
    ),
    SenderoDestination(
      svgAsset: 'assets/svgs/nav/nav_palabras.svg',
      svgAssetSelected: 'assets/svgs/nav/nav_palabras_fill.svg',
      label: 'Palabras',
    ),
    SenderoDestination(
      svgAsset: 'assets/svgs/nav/nav_perfil.svg',
      svgAssetSelected: 'assets/svgs/nav/nav_perfil_fill.svg',
      label: 'Perfil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Al entrar (post-login): sincronizar pendientes, cachear juegos y
    // renovar el JWT. Los tres en paralelo — `renewSession` no debe
    // bloquear el arranque hasta el `connectTimeout` de 20s cuando no hay
    // red (la app es offline-first).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(syncControllerProvider.notifier).trySync());
      unawaited(_bootstrapCaches());
      unawaited(ref.read(authControllerProvider.notifier).renewSession());
    });
  }

  /// Encadenado, en este orden — `GameCacheService` comparte `_running`
  /// entre sus métodos, así que lanzarlos en paralelo haría que uno se
  /// descarte en silencio:
  /// 1. [GameCacheService.seedFromBundleIfNewer]: si el APK trae un
  ///    manifest más nuevo que el ya sembrado (instalación nueva o
  ///    actualización), puebla `CachedGames` sin red antes de tocar la API.
  /// 2. `GET /api/catalog/updates` (`ResourceUpdateService.checkAndRefresh`):
  ///    baja solo el delta de juegos y palabras desde la última
  ///    sincronización — nunca el catálogo completo.
  /// 3. [GameCacheService.completeMissingGameMedia]: reintenta la media que
  ///    quedó a medias (juego sembrado por el bundle sin match en build-time,
  ///    o que falló por red la vez anterior) sin volver a tocar el catálogo.
  ///
  /// `MediaStore.sweep()` va suelto al final sin bloquear lo anterior: solo
  /// libera disco de la re-clave de `CachedMedia` (migración de esquema
  /// 8→9), es mantenimiento, no algo de lo que la UI dependa.
  Future<void> _bootstrapCaches() async {
    final gameCache = ref.read(gameCacheServiceProvider);
    await gameCache.seedFromBundleIfNewer().catchError((_) {});
    await _syncCatalogDelta();
    await gameCache.completeMissingGameMedia().catchError((_) {});
    unawaited(ref.read(mediaStoreProvider).sweep().catchError((_) {}));
    // El bundle recién sembrado (o el delta recién aplicado) cambia el
    // universo de `CachedGames`: sin esto, una instalación nueva se queda
    // con el progreso en "0 / 0" hasta el siguiente arranque, porque
    // `PathScreen` (ahora `GamesHubScreen`) nunca se desmonta en el
    // `indexedStack` y el `autoDispose` de antes no llegaba a dispararse.
    if (mounted) ref.invalidate(progressSnapshotProvider);
  }

  Future<void> _syncCatalogDelta() async {
    try {
      final refreshed =
          await ref.read(resourceUpdateServiceProvider).checkAndRefresh();
      if (refreshed.contains(TrackedResource.dictionary) && mounted) {
        ref.invalidate(dictionaryProvider);
      }
    } catch (_) {
      // Sin red u otro fallo: no bloquea el resto del arranque.
    }
  }

  /// El coyote saluda al entrar a cada sección (mirror de ROUTE_MESSAGES).
  void _speakForTab(int index) {
    if (index == _lastIndex) return;
    _lastIndex = index;
    final message = coyoteSectionMessages[_branchPaths[index]];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(coyoteProvider.notifier).resetForNewScreen(
            message?.$1,
            message?.$2 ?? CoyoteEmotion.esperando,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    _speakForTab(widget.navigationShell.currentIndex);

    // Mostrar el resumen de sincronización cuando esté listo.
    ref.listen(syncControllerProvider, (previous, summary) async {
      if (summary != null && mounted) {
        ref.read(syncControllerProvider.notifier).dismissSummary();
        // El progreso cambió en el backend: refrescar dashboard. La cola
        // offline también pudo registrar `CompletedGames` nuevos
        // (`SyncService.syncPending`), así que el anillo del mapa igual.
        ref.invalidate(dashboardProvider);
        ref.invalidate(dailyChallengeProvider);
        ref.invalidate(progressSnapshotProvider);
        await showSyncSummarySheet(context, summary);
      }
    });

    // Al recuperar conexión: mismo delta que en el arranque, sin re-sembrar
    // el bundle (eso solo tiene sentido una vez por `generatedAt`). También
    // se reintenta la renovación del JWT: es el único momento en que un
    // token ya caducado se cierra de verdad (ver `renewSession`), porque un
    // fallo de red antes de esto se conservó a propósito.
    ref.listen(connectivityStreamProvider, (previous, next) {
      if (next.value == true && previous?.value == false) {
        unawaited(_syncCatalogDelta().then((_) => ref
            .read(gameCacheServiceProvider)
            .completeMissingGameMedia()
            .catchError((_) {})));
        unawaited(ref.read(authControllerProvider.notifier).renewSession());
      }
    });

    final content = Column(
      children: [
        if (!isOnline) const SafeArea(bottom: false, child: OfflineBanner()),
        Expanded(child: widget.navigationShell),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CoyoteOverlay(child: content),
      bottomNavigationBar: SenderoNavBar(
        selectedIndex: widget.navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}
