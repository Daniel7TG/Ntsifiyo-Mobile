import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/models.dart';
import '../features/about/about_view.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/auth_screen.dart';
import '../features/auth/screens/verify_email_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/explore/explore_hub_screen.dart';
import '../features/pronunciation/pronunciation_hub_screen.dart';
import '../features/map/map_screen.dart';
import '../features/games/games_hub_screen.dart';
import '../features/home/home_screen.dart';
import '../features/games/game_access_screen.dart';
import '../features/games/game_play_screen.dart';
import '../features/dictionary/dictionary_screen.dart';
import '../features/content/content_screen.dart';
import '../features/content/media_player_screen.dart';
import '../features/assignments/assignments_screen.dart';
import '../features/profile/leaderboard_screen.dart';
import '../features/profile/profile_screen.dart';

import 'theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Transición transparente a pantalla completa con degradado continuo.
CustomTransitionPage<void> _coverPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: false,
    barrierColor: Colors.transparent,
    child: GradientBackground(child: child),
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.of(context).disableAnimations) return child;
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Transición de página estándar transparente con degradado continuo sin parpadeo blanco.
CustomTransitionPage<void> _appPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: false,
    barrierColor: Colors.transparent,
    child: GradientBackground(child: child),
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.of(context).disableAnimations) return child;
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  // Redirige en cuanto cambia el estado de auth.
  final isAuthenticated =
      ref.watch(authControllerProvider.select((u) => u != null));

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isAuthenticated ? '/inicio' : '/welcome',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // /verify-email es pública: se abre desde el correo sin sesión.
      if (loc == '/verify-email') return null;
      final inAuthFlow = loc == '/welcome' || loc == '/auth';
      if (!isAuthenticated && !inAuthFlow) return '/welcome';
      if (isAuthenticated && inAuthFlow) return '/inicio';
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) =>
            _appPage(const WelcomeScreen(), state),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => _appPage(
          AuthScreen(
            initialMode: state.uri.queryParameters['mode'] ?? 'login',
          ),
          state,
        ),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) => _appPage(
          VerifyEmailScreen(
            token: state.uri.queryParameters['token'],
          ),
          state,
        ),
      ),

      // Juego a pantalla completa (fuera del shell con bottom nav)
      GoRoute(
        path: '/games/:gameId/jugar',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _coverPage(
          GamePlayScreen(gameTypeId: state.pathParameters['gameId']!),
          state,
        ),
      ),
      GoRoute(
        path: '/reproductor/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _coverPage(
          MediaPlayerScreen(
            mediaId: int.tryParse(state.pathParameters['id'] ?? ''),
            item: state.extra is MediaItem ? state.extra as MediaItem : null,
          ),
          state,
        ),
      ),

      // Shell con bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Inicio: recomendaciones, pronunciación diaria y acceso al mapa.
          // El catálogo de juegos conserva su ruta dentro de esta rama.
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/inicio',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(path: 'juegos', builder: (context, state) => const GamesHubScreen()),
                GoRoute(
                  path: 'juegos/:gameId',
                  pageBuilder: (context, state) => _appPage(
                    GameAccessScreen(
                      gameTypeId: state.pathParameters['gameId']!,
                    ),
                    state,
                  ),
                ),
              ],
            ),
          ]),
          // Explorar: mapa de aventuras (pantalla completa, navigator raíz)
          // y contenido multimedia.
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/explorar',
              builder: (context, state) => const ExploreHubScreen(),
              routes: [
                GoRoute(
                  path: 'pronunciacion',
                  pageBuilder: (context, state) =>
                      _appPage(const PronunciationHubScreen(), state),
                ),
                GoRoute(
                  path: 'contenido',
                  pageBuilder: (context, state) =>
                      _appPage(const ContentScreen(), state),
                ),
                GoRoute(
                  path: 'mapa',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) =>
                      _coverPage(const MapScreen(), state),
                ),
              ],
            ),
          ]),
          // Palabras: diccionario.
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/palabras',
              builder: (context, state) => const DictionaryScreen(),
            ),
          ]),
          // Perfil: estadísticas, asignaciones, acerca de, ajustes.
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/perfil',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'asignaciones',
                  pageBuilder: (context, state) =>
                      _appPage(const AssignmentsScreen(), state),
                ),
                GoRoute(
                  path: 'acerca',
                  pageBuilder: (context, state) =>
                      _appPage(const AboutScreen(), state),
                ),
                GoRoute(
                  path: 'lideres',
                  pageBuilder: (context, state) =>
                      _appPage(const LeaderboardScreen(), state),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
