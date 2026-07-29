# Graph Report - jnatrjo_mobile  (2026-07-28)

## Corpus Check
- 71 files · ~172,383 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1519 nodes · 2154 edges · 77 communities (74 shown, 3 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 20 edges (avg confidence: 0.83)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ad3fc742`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Esquema drift generado
- DTOs y parsers del backend
- Resumen de partida
- Generador de laberinto
- Vista Tripas del Gato
- Mascota coyote y burbujas
- Vista Memoria Rápida
- Vista Laberinto
- Mapa de aventuras
- Pantalla de login y registro
- Tema y paleta kid 3D
- Reproductor multimedia
- Catálogo de actividades
- Vista Sopa de Letras
- Tarjetas de juego con audio
- Vista Quiz
- Vista Lotería
- Vista Completar Oración
- Vista Memorama
- Asignaciones y en construcción
- Repositorio del diccionario
- Servicio de sincronización
- Vista Pares
- Pantalla de bienvenida
- Sesión de juego
- Estados de las vistas de juego
- Dashboard
- Cliente HTTP y errores
- Archivos raíz de features
- Tarjetas privadas de UI
- Controlador de autenticación
- Estado del coyote
- Catálogo de juegos y providers
- Pantalla del diccionario
- Componentes kid
- Sesión en secure storage
- Providers con fallback a caché
- Router y arranque de la app
- Archivos de juegos y coyote
- Pantalla de contenido
- Servicio de autenticación
- Shell de navegación
- Precarga de assets
- Vista El Intruso
- Servicio de actividades
- Servicios de diccionario y media
- Google Sign-In
- Bienvenida y componentes animados
- Manifiesto del diccionario
- Conectividad y chrome del shell
- Estados vacío, error y offline
- Despacho de juegos
- Tests de la cola de sincronización
- Pantalla Acerca de
- Providers de dashboard y sesión
- Verificación de email
- Convenciones y contratos con el backend
- Tarjetas de estadísticas
- Principios offline-first y estilo
- Clases de datos de las cachés
- Caché de juegos
- Deuda de release y login
- Servicio de conectividad
- Script de exportación del diccionario
- Estrategia de media offline
- Base de datos drift
- Identidad de actividad y sesión
- Tests de generadores
- Registro y verificación
- Configuración del backend
- Definición de tablas drift
- Pantalla del reproductor
- Host Android
- Anotación suelta

## God Nodes (most connected - your core abstractions)
1. `gameSessionProvider` - 31 edges
2. `GameSession` - 12 edges
3. `categories` - 9 edges
4. `coyoteProvider` - 8 edges
5. `_AppShellState` - 8 edges
6. `AppDatabase` - 8 edges
7. `userSessionServiceProvider` - 7 edges
8. `authControllerProvider` - 7 edges
9. `_JnatrjoAppState` - 7 edges
10. `authServiceProvider` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Backend por defecto en Koyeb (README)` --semantically_similar_to--> `Backend por defecto en DigitalOcean`  [AMBIGUOUS] [semantically similar]
  README.md → CLAUDE.md
- `sessionStoreProvider sobreescrito en main()` --references--> `routerProvider`  [EXTRACTED]
  CLAUDE.md → lib/app/router.dart
- `Despacho de juego por id de ruta, no por gameType` --rationale_for--> `GamePlayScreen`  [EXTRACTED]
  CLAUDE.md → lib/features/games/game_play_screen.dart
- `activityId vs gameId (effectiveActivityId)` --rationale_for--> `GameSession`  [EXTRACTED]
  CLAUDE.md → lib/features/games/game_session.dart
- `Patrón red-primero-luego-caché en providers` --rationale_for--> `GameSessionController`  [EXTRACTED]
  CLAUDE.md → lib/features/games/game_session.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Triada offline-first: caché de juegos, cola de resultados y fallback de dashboard** — claude_cached_games, claude_pending_results, claude_kv_entries, claude_network_then_cache_pattern, claude_asset_url_rewrite [EXTRACTED 1.00]
- **Puntos de cambio acoplados al añadir un juego** — claude_add_new_game_recipe, lib_app_activity_config_activityconfig, lib_features_games_game_play_screen_gameplayscreen, claude_route_based_game_dispatch, claude_game_config_slots [EXTRACTED 1.00]
- **Deuda pendiente antes de publicar en Play Store** — claude_google_signin_audience, claude_debug_keystore_debt, readme_email_deeplink_debt, readme_backend_koyeb [INFERRED 0.85]

## Communities (77 total, 3 thin omitted)

### Community 0 - "Esquema drift generado"
Cohesion: 0.02
Nodes (95): _, actualTableName, _alias, aliasedName, allSchemaEntities, allTables, attachedDatabase, _completedAtMeta (+87 more)

### Community 1 - "DTOs y parsers del backend"
Cohesion: 0.02
Nodes (88): activityId, actualXp, Answer, answerConfig, answerText, _asBool, _asInt, audioUrl (+80 more)

### Community 2 - "Resumen de partida"
Cohesion: 0.04
Nodes (47): game_widgets.dart, ResponseLog, audio, build, _buildError, _buildLogsSection, _buildOfflineNote, _buildXpResult (+39 more)

### Community 3 - "Generador de laberinto"
Cohesion: 0.07
Nodes (28): allDirections, alphabet, c, cells, fillAlphabet, generateWordSearch, grid, GridPos (+20 more)

### Community 4 - "Vista Tripas del Gato"
Cohesion: 0.05
Nodes (41): _abortDraft, audioUrl, _buildCard, _cardAt, _cards, _cardWidthPct, createState, dispose (+33 more)

### Community 5 - "Mascota coyote y burbujas"
Cohesion: 0.12
Nodes (15): coyote_controller.dart, _Bubble, child, _CoyoteImage, CoyoteOverlay, emotion, message, onLeft (+7 more)

### Community 6 - "Vista Memoria Rápida"
Cohesion: 0.05
Nodes (38): _answer, _baseSpeedMs, _bottomWord, _cardTimer, _cfg0, _cfg1, _combo, _correct (+30 more)

### Community 7 - "Vista Laberinto"
Cohesion: 0.05
Nodes (37): audioUrl, _avatarX, _avatarY, _buildSideColumn, _carrying, _carryingSide, _completed, createState (+29 more)

### Community 8 - "Mapa de aventuras"
Cohesion: 0.07
Nodes (29): double x, y, w,, _activeTopic, build, contains, createState, db, enterMapChrome, _exitMap (+21 more)

### Community 9 - "Pantalla de login y registro"
Cohesion: 0.06
Nodes (36): ../auth_controller.dart, ../google_sign_in_helper.dart, AuthScreen, _AuthScreenState, build, _buildError, _buildGoogleButton, _buildGuestLogin (+28 more)

### Community 10 - "Tema y paleta kid 3D"
Cohesion: 0.06
Nodes (31): accentPink, AppColors, AppRadius, backgroundEnd, backgroundGradient, backgroundStart, base, bodyFont (+23 more)

### Community 11 - "Reproductor multimedia"
Cohesion: 0.06
Nodes (31): MediaItem, build, _buildPlayer, _controller, createState, _cueKey, dispose, _error (+23 more)

### Community 12 - "Catálogo de actividades"
Cohesion: 0.07
Nodes (28): ActivityTypes, catLines, color, description, fastMemory, fillBlank, findTheWord, gameInfoFor (+20 more)

### Community 13 - "Vista Sopa de Letras"
Cohesion: 0.06
Nodes (31): _board, _cellAt, cellSize, _cfg, _checkSelection, createState, dispose, _finish (+23 more)

### Community 14 - "Tarjetas de juego con audio"
Cohesion: 0.07
Nodes (28): BoxFit, double?, audioPath, _audioPlayer, _broken, build, cardState, color (+20 more)

### Community 15 - "Vista Quiz"
Cohesion: 0.07
Nodes (28): GameConfig get, build, _buildOption, _combo, _config1, _config2, _correctOption, createState (+20 more)

### Community 16 - "Vista Lotería"
Cohesion: 0.07
Nodes (29): audioUrl, _board, _cardIntervalMs, _correctPts, createState, dispose, _finished, imageUrl (+21 more)

### Community 17 - "Vista Completar Oración"
Cohesion: 0.07
Nodes (29): Answer? get, class, build, _buildFillBlankPrompt, _buildOption, _config1, _config2, _correctOption (+21 more)

### Community 18 - "Vista Memorama"
Cohesion: 0.07
Nodes (28): audioUrl, back, _cards, createState, dispose, _elapsed, _finished, _flipped (+20 more)

### Community 19 - "Asignaciones y en construcción"
Cohesion: 0.14
Nodes (13): dart:io, cache, dio, dir, localize, localizeWord, mediaDir, preloadGameAssets (+5 more)

### Community 20 - "Repositorio del diccionario"
Cohesion: 0.09
Nodes (22): allWords, _applyBundleMedia, _assetPath, build, _bundleData, _cacheFile, categories, DictionaryRepository (+14 more)

### Community 21 - "Servicio de sincronización"
Cohesion: 0.08
Nodes (28): ../connectivity/connectivity_service.dart, int get, connectivityStreamProvider, activities, build, correctAnswers, _db, dismissSummary (+20 more)

### Community 22 - "Vista Pares"
Cohesion: 0.07
Nodes (27): audioUrl, _buildColumn, createState, dispose, _elapsed, _finished, _formatTime, imageUrl (+19 more)

### Community 23 - "Pantalla de bienvenida"
Cohesion: 0.08
Nodes (24): ../../about/about_view.dart, AnimationController, _AboutPage, build, _buildAboutTeaser, _buildFinalCta, _buildGamesShowcase, _buildHero (+16 more)

### Community 24 - "Sesión de juego"
Cohesion: 0.08
Nodes (24): ActivityService get, AppDatabase get, ../../core/sync/asset_preloader.dart, DateTime, GameData, build, clear, complete (+16 more)

### Community 25 - "Estados de las vistas de juego"
Cohesion: 0.21
Nodes (13): Receta para añadir un juego nuevo, Despacho de juego por id de ruta, no por gameType, ConsumerState, ConsumerStatefulWidget, activityConfig, _PendingTile, _PendingTileState, GameAccessScreen (+5 more)

### Community 26 - "Dashboard"
Cohesion: 0.07
Nodes (30): authControllerProvider, dashboard_providers.dart, dashboardProvider, activities, activity, build, color, _confirmLogout (+22 more)

### Community 27 - "Cliente HTTP y errores"
Cohesion: 0.10
Nodes (20): Dio, Exception, int?, apiBaseUrl, apiClientProvider, ApiException, _buildErrorMessage, delete (+12 more)

### Community 28 - "Archivos raíz de features"
Cohesion: 0.11
Nodes (18): ../features/about/about_view.dart, ../features/assignments/assignments_screen.dart, ../features/auth/screens/auth_screen.dart, ../features/auth/screens/verify_email_screen.dart, ../features/auth/screens/welcome_screen.dart, ../features/content/content_screen.dart, ../features/content/media_player_screen.dart, ../features/dashboard/dashboard_screen.dart (+10 more)

### Community 29 - "Tarjetas privadas de UI"
Cohesion: 0.07
Nodes (29): _AudioCover, _AudioDisc, _CardTitle, _LeaderTile, _PendingActivitiesCard, _ComboBadge, _FlipCard, _AnswerReviewCard (+21 more)

### Community 30 - "Controlador de autenticación"
Cohesion: 0.11
Nodes (20): AuthService get, bool get, core/storage/session_store.dart, userSessionServiceProvider, _auth, authControllerProvider, build, _commit (+12 more)

### Community 31 - "Estado del coyote"
Cohesion: 0.11
Nodes (18): dart:async, esperando,
  pensando,
  celebracion,
  triste,, asset, build, clear, copyWith, CoyoteController, CoyoteState (+10 more)

### Community 32 - "Catálogo de juegos y providers"
Cohesion: 0.08
Nodes (28): ../../../app/activity_config.dart, ../../app/theme.dart, ../../core/sync/sync_service.dart, GameInfo get, games_providers.dart, GameInfo, GameSummaryDto, _ActivityCard (+20 more)

### Community 33 - "Pantalla del diccionario"
Cohesion: 0.12
Nodes (17): dictionary_repository.dart, ../games/widgets/game_widgets.dart, Word, dictionaryProvider, build, _buildCategoryGrid, _buildWordsGrid, _categoryInfo (+9 more)

### Community 34 - "Componentes kid"
Cohesion: 0.11
Nodes (17): EdgeInsetsGeometry, accentColor, backgroundColor, build, child, color, createState, expanded (+9 more)

### Community 35 - "Sesión en secure storage"
Cohesion: 0.13
Nodes (14): AppUser? get, FlutterSecureStorage, clear, isAuthenticated, load, save, SessionStore, _storage (+6 more)

### Community 36 - "Providers con fallback a caché"
Cohesion: 0.11
Nodes (18): ../auth/auth_controller.dart, ../../core/storage/app_database.dart, ../../../data/models/models.dart, ../../data/services/activity_service.dart, cacheKey, dashboardProvider, db, fromJson (+10 more)

### Community 37 - "Router y arranque de la app"
Cohesion: 0.13
Nodes (16): app/router.dart, ../../data/services/misc_services.dart, ../features/auth/auth_controller.dart, routerProvider, build, createState, dispose, JnatrjoApp (+8 more)

### Community 38 - "Archivos de juegos y coyote"
Cohesion: 0.12
Nodes (15): ../coyote/coyote_companion.dart, ../coyote/coyote_controller.dart, ../game_session.dart, createState, gameTypeId, ../../shared/widgets/under_construction.dart, views/intruso_game_view.dart, views/laberinto_game_view.dart (+7 more)

### Community 39 - "Pantalla de contenido"
Cohesion: 0.15
Nodes (14): ../../core/connectivity/connectivity_service.dart, build, color, _contentTabs, _formatDuration, icon, mediaByTypeProvider, _MediaList (+6 more)

### Community 40 - "Servicio de autenticación"
Cohesion: 0.12
Nodes (15): ApiClient, _api, AuthService, LoginResult, loginStudent, loginVisitor, loginWithGoogle, raw (+7 more)

### Community 41 - "Shell de navegación"
Cohesion: 0.14
Nodes (13): ../../core/sync/game_cache_service.dart, ../coyote/coyote_messages.dart, _applyChromeForTab, _branchPaths, createState, dispose, _isMapTab, _lastChromeIndex (+5 more)

### Community 42 - "Precarga de assets"
Cohesion: 0.12
Nodes (16): bottom, current, generateMaze, grid, left, MazeCell, mazeDimensions, removeWalls (+8 more)

### Community 43 - "Vista El Intruso"
Cohesion: 0.17
Nodes (12): gameSessionProvider, _restart, build, build, build, build, build, _restart (+4 more)

### Community 44 - "Servicio de actividades"
Cohesion: 0.14
Nodes (13): ../../../core/api/api_client.dart, activityServiceProvider, _api, completeActivity, getActivitiesByType, getAllGames, getGamesByTopic, getStudentActivities (+5 more)

### Community 45 - "Servicios de diccionario y media"
Cohesion: 0.14
Nodes (13): _api, DictionaryService, dictionaryServiceProvider, endSession, getAllWords, getCategories, getMediaByType, getMediaStream (+5 more)

### Community 46 - "Google Sign-In"
Cohesion: 0.15
Nodes (12): displayName, email, _ensureInitialized, GoogleAccountInfo, GoogleSignInHelper, idToken, _initialized, signIn (+4 more)

### Community 47 - "Bienvenida y componentes animados"
Cohesion: 0.23
Nodes (13): WelcomeScreen, _WelcomeScreenState, _ProgressiveSubtitle, _ProgressiveSubtitleState, _Confetti, _ConfettiState, KidButton, _KidButtonState (+5 more)

### Community 48 - "Manifiesto del diccionario"
Cohesion: 0.17
Nodes (11): categories, generatedAt, words, ANIMALS, BODY_PARTS, CLOTHES, COLORS, FIVE_SENSES (+3 more)

### Community 49 - "Conectividad y chrome del shell"
Cohesion: 0.29
Nodes (10): Excepción de orientación horizontal para el mapa, connectivityStreamProvider, gameCacheServiceProvider, isOnlineProvider, AppShell, _AppShellState, build, initState (+2 more)

### Community 50 - "Estados vacío, error y offline"
Cohesion: 0.15
Nodes (12): build, centerLabel, color, max, paint, progress, ProgressRing, shouldRepaint (+4 more)

### Community 51 - "Despacho de juegos"
Cohesion: 0.20
Nodes (10): ConsumerWidget, ContentScreen, build, _CoyoteLayer, coyoteProvider, _LeaderboardCard, build, initState (+2 more)

### Community 52 - "Tests de la cola de sincronización"
Cohesion: 0.20
Nodes (9): dart:convert, package:drift/drift.dart, package:drift/native.dart, package:flutter_test/flutter_test.dart, package:jnatrjo_mobile/core/storage/app_database.dart, package:jnatrjo_mobile/data/models/models.dart, db, main (+1 more)

### Community 53 - "Pantalla Acerca de"
Cohesion: 0.10
Nodes (19): Color, IconData, kid_card.dart, AboutContent, AboutScreen, _AboutSection, build, color (+11 more)

### Community 54 - "Providers de dashboard y sesión"
Cohesion: 0.25
Nodes (8): AsyncNotifier, Reescritura de URLs a rutas de disco al precargar assets, CachedGames — contenido jugable por gameId, Diccionario: emisión instantánea con refresh en segundo plano, GameCacheService, DictionaryController, DictionaryData, Diccionario mazahua-español 100% offline

### Community 55 - "Verificación de email"
Cohesion: 0.15
Nodes (14): ../../../data/services/auth_service.dart, authServiceProvider, _submitRegister, build, _buildResult, createState, initState, _message (+6 more)

### Community 56 - "Convenciones y contratos con el backend"
Cohesion: 0.22
Nodes (9): Lints por defecto de flutter_lints, sin reglas propias, Tolerancia a alias de campos del backend, gameConfigs[0]=prompt, gameConfigs[1]=opciones, ResponseLog.toJson() vs toApiJson(), Convención: todo el código en español, Paridad intencional con la plataforma web React, Ícono adaptativo Android (coyote sobre #A8E6CF), Sistema de estilo 'kid' 3D heredado de la web (+1 more)

### Community 57 - "Tarjetas de estadísticas"
Cohesion: 0.25
Nodes (8): CustomPainter, _BubblesPainter, _BubbleTailPainter, _MazePainter, _GridPainter, _LinesPainter, _ConfettiPainter, _RingPainter

### Community 58 - "Principios offline-first y estilo"
Cohesion: 0.28
Nodes (9): KvEntries — copias JSON de dashboards, Patrón red-primero-luego-caché en providers, Offline-first (punto central del proyecto), PendingResults — cola de partidas sin red, Tres cachés distintas en drift, Protocolo de sincronización de 2 pasos, SyncService, Contenido multimedia solo online (+1 more)

### Community 59 - "Clases de datos de las cachés"
Cohesion: 0.33
Nodes (9): CachedGamesCompanion, KvEntriesCompanion, KvEntry, PendingResult, PendingResultsCompanion, DataClass, Insertable, CachedGame (+1 more)

### Community 60 - "Caché de juegos"
Cohesion: 0.15
Nodes (12): _, @DriftDatabase, asset_preloader.dart, schemaVersion 1 sin MigrationStrategy, AppDatabase, cacheAllGames, _db, gameCacheServiceProvider (+4 more)

### Community 61 - "Deuda de release y login"
Cohesion: 0.25
Nodes (8): Release firmado con keystore de debug, Google Sign-In usa el client ID web como serverClientId, sessionStoreProvider sobreescrito en main(), sessionStoreProvider, AppUser, AuthController, Verificación de email abre el navegador, Dos modos de login: estudiante y visitante

### Community 62 - "Servicio de conectividad"
Cohesion: 0.25
Nodes (7): connectivity, _hasNetwork, initial, isOnlineProvider, watch, package:connectivity_plus/connectivity_plus.dart, package:flutter_riverpod/flutter_riverpod.dart

### Community 63 - "Script de exportación del diccionario"
Cohesion: 0.48
Nodes (6): api_get(), download(), main(), Exporta el diccionario del backend a assets/dictionary/ para uso offline.  Desca, save_audio(), save_image()

### Community 64 - "Estrategia de media offline"
Cohesion: 0.50
Nodes (4): _load, MediaPlayerScreen, _MediaPlayerScreenState, mediaServiceProvider

### Community 65 - "Base de datos drift"
Cohesion: 0.50
Nodes (4): _buildGamesList, gamesByTopicProvider, _ZoneSheet, _ZoneSheetState

### Community 66 - "Identidad de actividad y sesión"
Cohesion: 0.40
Nodes (5): activityServiceProvider, appDatabaseProvider, activityId vs gameId (effectiveActivityId), GameSession, GameSessionController

### Community 67 - "Tests de generadores"
Cohesion: 0.40
Nodes (4): dart:math, package:jnatrjo_mobile/features/games/logic/maze_generator.dart, package:jnatrjo_mobile/features/games/logic/word_search_generator.dart, main

### Community 68 - "Registro y verificación"
Cohesion: 0.15
Nodes (14): ../dashboard/dashboard_providers.dart, ../games/game_session.dart, activity, _AssignmentCard, AssignmentsScreen, _AssignmentsScreenState, build, createState (+6 more)

### Community 69 - "Configuración del backend"
Cohesion: 0.67
Nodes (3): Backend por defecto en DigitalOcean, ApiClient, Backend por defecto en Koyeb (README)

### Community 70 - "Definición de tablas drift"
Cohesion: 0.50
Nodes (4): CachedGames, KvEntries, PendingResults, Table

## Ambiguous Edges - Review These
- `Backend por defecto en DigitalOcean` → `Backend por defecto en Koyeb (README)`  [AMBIGUOUS]
  README.md · relation: semantically_similar_to

## Knowledge Gaps
- **1026 isolated node(s):** `_rootNavigatorKey`, `isAuthenticated`, `Roles`, `Difficulty`, `GameConfig` (+1021 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Backend por defecto en DigitalOcean` and `Backend por defecto en Koyeb (README)`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._
- **Why does `SyncService` connect `Principios offline-first y estilo` to `Servicio de sincronización`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `XP y niveles sincronizados con el backend web` connect `Principios offline-first y estilo` to `Convenciones y contratos con el backend`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **Why does `Paridad intencional con la plataforma web React` connect `Convenciones y contratos con el backend` to `Principios offline-first y estilo`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **What connects `_rootNavigatorKey`, `isAuthenticated`, `Roles` to the rest of the system?**
  _1026 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Esquema drift generado` be split into smaller, more focused modules?**
  _Cohesion score 0.020833333333333332 - nodes in this community are weakly interconnected._
- **Should `DTOs y parsers del backend` be split into smaller, more focused modules?**
  _Cohesion score 0.02247191011235955 - nodes in this community are weakly interconnected._