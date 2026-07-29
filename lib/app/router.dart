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
import '../features/dashboard/dashboard_screen.dart';
import '../features/map/map_screen.dart';
import '../features/games/games_hub_screen.dart';
import '../features/games/game_access_screen.dart';
import '../features/games/game_play_screen.dart';
import '../features/dictionary/dictionary_screen.dart';
import '../features/content/content_screen.dart';
import '../features/content/media_player_screen.dart';
import '../features/assignments/assignments_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Redirige en cuanto cambia el estado de auth.
  final isAuthenticated =
      ref.watch(authControllerProvider.select((u) => u != null));

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isAuthenticated ? '/dashboard' : '/welcome',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // /verify-email es pública: se abre desde el correo sin sesión.
      if (loc == '/verify-email') return null;
      final inAuthFlow = loc == '/welcome' || loc == '/auth';
      if (!isAuthenticated && !inAuthFlow) return '/welcome';
      if (isAuthenticated && inAuthFlow) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => AuthScreen(
          initialMode: state.uri.queryParameters['mode'] ?? 'login',
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => VerifyEmailScreen(
          token: state.uri.queryParameters['token'],
        ),
      ),

      // Juego a pantalla completa (fuera del shell con bottom nav)
      GoRoute(
        path: '/games/:gameId/jugar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => GamePlayScreen(
          gameTypeId: state.pathParameters['gameId']!,
        ),
      ),
      GoRoute(
        path: '/reproductor/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => MediaPlayerScreen(
          mediaId: int.parse(state.pathParameters['id']!),
          item: state.extra is MediaItem ? state.extra as MediaItem : null,
        ),
      ),

      // Shell con bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
              routes: [
                GoRoute(
                  path: 'asignaciones',
                  builder: (context, state) => const AssignmentsScreen(),
                ),
                GoRoute(
                  path: 'acerca',
                  builder: (context, state) => const AboutScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/mapa',
              builder: (context, state) => const MapScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/juegos',
              builder: (context, state) => const GamesHubScreen(),
              routes: [
                GoRoute(
                  path: ':gameId',
                  builder: (context, state) => GameAccessScreen(
                    gameTypeId: state.pathParameters['gameId']!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/diccionario',
              builder: (context, state) => const DictionaryScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/contenido',
              builder: (context, state) => const ContentScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});
