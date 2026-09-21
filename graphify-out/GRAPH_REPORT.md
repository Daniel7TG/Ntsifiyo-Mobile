# Graph Report - jnatrjo_mobile  (2026-09-21)

## Corpus Check
- 162 files · ~2,247,558 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3070 nodes · 4330 edges · 165 communities (150 shown, 15 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `c3fc07b2`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- app_database.dart
- models.dart
- game_summary_view.dart
- word_search_generator.dart
- tripas_game_view.dart
- coyote_companion.dart
- memoria_rapida_game_view.dart
- laberinto_game_view.dart
- map_screen.dart
- auth_screen.dart
- theme.dart
- media_player_screen.dart
- activity_config.dart
- sopa_letras_game_view.dart
- game_widgets.dart
- intruso_game_view.dart
- loteria_game_view.dart
- questionnaire_game_view.dart
- memorama_game_view.dart
- media_store.dart
- dictionary_repository.dart
- sync_service.dart
- pares_game_view.dart
- welcome_screen.dart
- game_session.dart
- game_access_screen.dart
- VoidCallback?
- api_client.dart
- router.dart
- profile_screen.dart
- auth_controller.dart
- coyote_controller.dart
- pronunciation_practice_screen.dart
- dictionary_screen.dart
- kid_card.dart
- session_store.dart
- ../../app/activity_config.dart
- main.dart
- game_play_screen.dart
- content_screen.dart
- auth_service.dart
- app_shell.dart
- maze_generator.dart
- preproceso_audio.dart
- activity_service.dart
- misc_services.dart
- google_sign_in_helper.dart
- media_player_controller.dart
- categories
- package:flutter_test/flutter_test.dart
- progress_ring.dart
- inicio-v2/prototype.js
- prototype.js
- stat_card.dart
- palette.dart
- Visitor Dashboard Controller
- package:flutter/material.dart
- Game Controller
- Activity Controller
- DataClass
- game_cache_service.dart
- SingleTickerProviderStateMixin
- ../../app/theme.dart
- export_games.py
- skeleton.dart
- validador_service.dart
- package:flutter_riverpod/flutter_riverpod.dart
- dart:math
- home_carousel.dart
- ConsumerState
- Table
- sendero_nav_bar.dart
- build
- MainActivity.kt
- authControllerProvider
- dictionary_and_pronunciation_test.dart
- @ejemplo
- assignments_screen.dart
- error_messages.dart
- map_screen_test.dart
- pronunciation_hub_screen.dart
- resource_update_service.dart
- leaderboard_screen.dart
- Arquitectura
- Dictionary Controller
- xp_utils.dart
- dart:async
- daily_pronunciation_test.dart
- asset_preloader.dart
- game_launcher.dart
- Diapositiva 3 — Resultados: pronunciación
- CustomPainter
- static const
- fix_animation_transparency.py
- progress_providers.dart
- coyoteProvider
- sync_pronunciation_words.py
- generate_app_icons.py
- avatar_config.dart
- generate_and_upload_numbers.py
- daily-model.test.cjs
- gameSessionProvider
- media_player_view.dart
- Admin User Controller
- compare_ids.py
- inspect_real_game_data.py
- make_walking_coyote_transparent.py
- optimize_walking_size.py
- sync_backend_assets.py
- sync_uuid_assets.py
- verify_walking_eyes.py
- Diapositiva 3 — Resultados: pronunciación
- Group Controller
- resource_update_test.dart
- Student Dashboard Controller
- vtt_parser.dart
- Enumeraciones
- Auth Controller
- Media Controller
- map_geometry.dart
- _ZoneSheetState
- preproceso_audio_test.dart
- home_screen_test.dart
- game_cache_service_test.dart
- List
- Admin Dashboard Controller
- vtt_parser_test.dart
- User Controller
- _HomeScreenState
- theme_controller.dart
- API_Documentation.md
- Teacher Dashboard Controller
- word_image_test.dart
- ../../data/models/models.dart
- routerProvider
- POST /api/pronunciation/validate/{wordId}
- daily_pronunciation_service.dart
- dictionary_word_delta_test.dart
- Guía de estilo — imágenes de números (assets/numbers/)
- AuthController
- media_cache_key.dart
- home_providers.dart
- games/manifest.json
- stars.dart
- MediaPlayerController
- Image
- package:flutter/services.dart
- daily_pronunciation.dart
- home_screen.dart
- GamePlayScreen
- coyote_messages.dart
- AppPalette
- ../../../core/api/api_client.dart
- Inicio y pronunciación diaria
- AppPaletteX

## God Nodes (most connected - your core abstractions)
1. `gameSessionProvider` - 23 edges
2. `authControllerProvider` - 15 edges
3. `_` - 15 edges
4. `AppDatabase` - 14 edges
5. `Visitor Dashboard Controller` - 14 edges
6. `GameSession` - 12 edges
7. `_HomeScreenState` - 12 edges
8. `_AppShellState` - 11 edges
9. `Activity Controller` - 11 edges
10. `Dictionary Controller` - 11 edges

## Surprising Connections (you probably didn't know these)
- `activityId vs gameId (effectiveActivityId)` --rationale_for--> `GameSession`  [EXTRACTED]
  CLAUDE.md → lib/features/games/game_session.dart
- `Backend por defecto en Koyeb (README)` --semantically_similar_to--> `Backend por defecto en DigitalOcean`  [AMBIGUOUS] [semantically similar]
  README.md → CLAUDE.md
- `Backend por defecto en DigitalOcean` --references--> `ApiClient`  [EXTRACTED]
  CLAUDE.md → lib/core/api/api_client.dart
- `schemaVersion 1 sin MigrationStrategy` --rationale_for--> `AppDatabase`  [EXTRACTED]
  CLAUDE.md → lib/core/storage/app_database.dart
- `Tres cachés distintas en drift` --references--> `AppDatabase`  [EXTRACTED]
  CLAUDE.md → lib/core/storage/app_database.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Puntos de cambio acoplados al añadir un juego** — claude_add_new_game_recipe, lib_app_activity_config_activityconfig, lib_features_games_game_play_screen_gameplayscreen, claude_route_based_game_dispatch, claude_game_config_slots [EXTRACTED 1.00]
- **Triada offline-first: caché de juegos, cola de resultados y fallback de dashboard** — claude_cached_games, claude_pending_results, claude_kv_entries, claude_network_then_cache_pattern, claude_asset_url_rewrite [EXTRACTED 1.00]
- **Deuda pendiente antes de publicar en Play Store** — claude_google_signin_audience, claude_debug_keystore_debt, readme_email_deeplink_debt, readme_backend_koyeb [INFERRED 0.85]

## Communities (165 total, 15 thin omitted)

### Community 0 - "app_database.dart"
Cohesion: 0.01
Nodes (202): BoolColumn get, class PendingDailyResult extends, ColumnFilters, ColumnOrderings, DateTimeColumn get, GeneratedColumn, GeneratedDatabase, _ (+194 more)

### Community 1 - "models.dart"
Cohesion: 0.02
Nodes (114): correct,
  incorrect,
  incorrectDifferentWord,, activityId, actualXp, Answer, answerConfig, answerText, _asBool, _asInt (+106 more)

### Community 2 - "game_summary_view.dart"
Cohesion: 0.04
Nodes (47): game_widgets.dart, ResponseLog, audio, build, _buildError, _buildLogsSection, _buildOfflineNote, _buildXpResult (+39 more)

### Community 3 - "word_search_generator.dart"
Cohesion: 0.07
Nodes (28): allDirections, alphabet, c, cells, fillAlphabet, generateWordSearch, grid, GridPos (+20 more)

### Community 4 - "tripas_game_view.dart"
Cohesion: 0.05
Nodes (38): _abortDraft, audioUrl, _buildCard, _cardAt, _cards, _cardWidthPct, createState, dispose (+30 more)

### Community 5 - "coyote_companion.dart"
Cohesion: 0.12
Nodes (16): _Bubble, child, _CoyoteImage, CoyoteOverlay, createState, dispose, emotion, message (+8 more)

### Community 6 - "memoria_rapida_game_view.dart"
Cohesion: 0.05
Nodes (38): _answer, _baseSpeedMs, _bottomWord, _cardTimer, _cfg0, _cfg1, _combo, _correct (+30 more)

### Community 7 - "laberinto_game_view.dart"
Cohesion: 0.06
Nodes (35): audioUrl, _avatarX, _avatarY, _buildSideColumn, _carrying, _carryingSide, _completed, createState (+27 more)

### Community 8 - "map_screen.dart"
Cohesion: 0.07
Nodes (29): _activeTopic, createState, dispose, enterMapChrome, _exitMap, exitMapChrome, _highlightedZone, _hover (+21 more)

### Community 9 - "auth_screen.dart"
Cohesion: 0.06
Nodes (34): ../auth_controller.dart, ../google_sign_in_helper.dart, build, _buildError, _buildGoogleButton, _buildGuestLogin, _buildModeSwitch, _buildRegisterForm (+26 more)

### Community 10 - "theme.dart"
Cohesion: 0.06
Nodes (34): accentPink, AppColors, AppRadius, backgroundEnd, backgroundGradient, backgroundStart, base, bodyFont (+26 more)

### Community 11 - "media_player_screen.dart"
Cohesion: 0.10
Nodes (20): MediaItem, mediaServiceProvider, build, _controller, createState, dispose, _fullscreen, initState (+12 more)

### Community 12 - "activity_config.dart"
Cohesion: 0.06
Nodes (30): ActivityTypes, catLines, color, description, disabledGameTypes, fastMemory, fillBlank, findTheWord (+22 more)

### Community 13 - "sopa_letras_game_view.dart"
Cohesion: 0.07
Nodes (28): _board, _cellAt, cellSize, _cfg, _checkSelection, createState, dispose, _finish (+20 more)

### Community 14 - "game_widgets.dart"
Cohesion: 0.06
Nodes (34): BoxFit, audioPath, _audioPlayer, _broken, build, cardState, color, disabled (+26 more)

### Community 15 - "intruso_game_view.dart"
Cohesion: 0.07
Nodes (29): GameConfig get, build, _buildOption, _combo, _ComboBadge, _config1, _config2, _correctOption (+21 more)

### Community 16 - "loteria_game_view.dart"
Cohesion: 0.07
Nodes (27): audioUrl, _board, _cardIntervalMs, _correctPts, createState, dispose, _finished, imageUrl (+19 more)

### Community 17 - "questionnaire_game_view.dart"
Cohesion: 0.07
Nodes (28): Answer? get, build, _buildFillBlankPrompt, _buildOption, _config1, _config2, _correctOption, createState (+20 more)

### Community 18 - "memorama_game_view.dart"
Cohesion: 0.07
Nodes (27): audioUrl, back, _cards, createState, dispose, _elapsed, _finished, _FlipCard (+19 more)

### Community 19 - "media_store.dart"
Cohesion: 0.11
Nodes (18): app_database.dart, Dio, Future, _db, _dio, _dir, _fnv1a64, hash (+10 more)

### Community 20 - "dictionary_repository.dart"
Cohesion: 0.07
Nodes (32): allWords, _applyBundleMedia, applyWordDelta, _applyWordDeltaByCategory, _assetPath, build, _bundleData, _bundleGeneratedAt (+24 more)

### Community 21 - "sync_service.dart"
Cohesion: 0.08
Nodes (26): ../api/api_client.dart, ../connectivity/connectivity_service.dart, activities, correctAnswers, _daily, _db, dismissSummary, gameType (+18 more)

### Community 22 - "pares_game_view.dart"
Cohesion: 0.08
Nodes (24): audioUrl, _buildColumn, createState, dispose, _elapsed, _finished, _formatTime, imageUrl (+16 more)

### Community 23 - "welcome_screen.dart"
Cohesion: 0.06
Nodes (33): ../../about/about_view.dart, _AboutPage, alpha, body, build, _buildActions, _buildCommunitySlide, _buildDots (+25 more)

### Community 24 - "game_session.dart"
Cohesion: 0.07
Nodes (26): ActivityService get, AppDatabase get, ../../core/sync/asset_preloader.dart, GameData, build, clear, complete, correctAnswers (+18 more)

### Community 25 - "game_access_screen.dart"
Cohesion: 0.09
Nodes (24): game_launcher.dart, GameInfo get, games_providers.dart, GameInfo, GameSummaryDto, _ActivityCard, createState, disabled (+16 more)

### Community 26 - "VoidCallback?"
Cohesion: 0.12
Nodes (15): build, EmptyState, ErrorState, message, OfflineBanner, onRetry, subtitle, svgAsset (+7 more)

### Community 27 - "api_client.dart"
Cohesion: 0.10
Nodes (19): Exception, apiBaseUrl, apiClientProvider, ApiException, _buildErrorMessage, delete, dio, message (+11 more)

### Community 28 - "router.dart"
Cohesion: 0.08
Nodes (25): ../features/about/about_view.dart, ../features/assignments/assignments_screen.dart, ../features/auth/screens/auth_screen.dart, ../features/auth/screens/verify_email_screen.dart, ../features/auth/screens/welcome_screen.dart, ../features/content/content_screen.dart, ../features/content/media_player_screen.dart, ../features/dictionary/dictionary_screen.dart (+17 more)

### Community 29 - "profile_screen.dart"
Cohesion: 0.06
Nodes (36): avatar_picker_sheet.dart, ../../core/xp_utils.dart, ../games/games_providers.dart, _AnswerReviewCard, _Metric, _PairsReview, _ReviewRow, _WordList (+28 more)

### Community 30 - "auth_controller.dart"
Cohesion: 0.15
Nodes (12): AuthService get, ../../../data/services/auth_service.dart, _auth, build, isAuthenticated, loginStudent, loginVisitor, loginWithGoogle (+4 more)

### Community 31 - "coyote_controller.dart"
Cohesion: 0.09
Nodes (23): esperando,
  pensando,
  celebracion,
  triste,, activityServiceProvider, build, clear, copyWith, CoyoteController, CoyoteState, dismiss (+15 more)

### Community 32 - "pronunciation_practice_screen.dart"
Cohesion: 0.06
Nodes (36): Animation, AudioPlayer, ../../core/audio/audio_recorder_helper.dart, validadorServiceProvider, VeredictoPronunciacion, _audioPlayer, build, _buildRecordingControls (+28 more)

### Community 33 - "dictionary_screen.dart"
Cohesion: 0.13
Nodes (14): ../../core/api/error_messages.dart, dictionary_repository.dart, _buildCategoryGrid, _buildSearchResults, _buildWordsGrid, _categoryInfo, _categoryLabel, createState (+6 more)

### Community 34 - "kid_card.dart"
Cohesion: 0.10
Nodes (21): accentColor, backgroundColor, build, child, color, createState, expanded, icon (+13 more)

### Community 35 - "session_store.dart"
Cohesion: 0.13
Nodes (14): AppUser? get, bool get, FlutterSecureStorage, clear, isAuthenticated, load, save, SessionStore (+6 more)

### Community 36 - "../../app/activity_config.dart"
Cohesion: 0.11
Nodes (19): ../../app/activity_config.dart, ../auth/auth_controller.dart, ../../core/storage/app_database.dart, dart:convert, ../../data/services/activity_service.dart, cacheKey, db, fromJson (+11 more)

### Community 37 - "main.dart"
Cohesion: 0.12
Nodes (17): app/router.dart, core/storage/session_store.dart, data/services/misc_services.dart, features/auth/auth_controller.dart, features/settings/theme_controller.dart, _ThemeCard, themeModeProvider, build (+9 more)

### Community 38 - "game_play_screen.dart"
Cohesion: 0.12
Nodes (16): ../coyote/coyote_companion.dart, ../coyote/coyote_controller.dart, ../coyote/coyote_messages.dart, createState, gameTypeId, ../../shared/widgets/states.dart, ../../shared/widgets/under_construction.dart, views/intruso_game_view.dart (+8 more)

### Community 39 - "content_screen.dart"
Cohesion: 0.10
Nodes (21): ../../../core/storage/media_cache_key.dart, build, color, _contentTabs, createState, _exhausted, _extra, _formatDuration (+13 more)

### Community 40 - "auth_service.dart"
Cohesion: 0.13
Nodes (14): _api, AuthService, LoginResult, loginStudent, loginVisitor, loginWithGoogle, raw, refreshToken (+6 more)

### Community 41 - "app_shell.dart"
Cohesion: 0.09
Nodes (28): Excepción de orientación horizontal para el mapa, ../../core/connectivity/connectivity_service.dart, ../../core/storage/media_store.dart, ../../core/sync/game_cache_service.dart, ../../core/sync/resource_update_service.dart, ../home/home_providers.dart, connectivityStreamProvider, mediaStoreProvider (+20 more)

### Community 42 - "maze_generator.dart"
Cohesion: 0.12
Nodes (15): bottom, current, generateMaze, grid, left, MazeCell, mazeDimensions, removeWalls (+7 more)

### Community 43 - "preproceso_audio.dart"
Cohesion: 0.03
Nodes (59): actual, analizarVoz, antes, cresta, cruces, desv, duracionMinimaS, end (+51 more)

### Community 44 - "activity_service.dart"
Cohesion: 0.11
Nodes (18): Backend por defecto en DigitalOcean, ApiClient, _api, completeActivity, getGameDetails, getGamePreview, getStudentActivities, getStudentDashboard (+10 more)

### Community 45 - "misc_services.dart"
Cohesion: 0.12
Nodes (16): _api, endSession, _fullWordsBatchSize, getAllWords, getCategories, getFullWords, getMediaByType, getMediaStream (+8 more)

### Community 46 - "google_sign_in_helper.dart"
Cohesion: 0.15
Nodes (12): displayName, email, _ensureInitialized, GoogleAccountInfo, GoogleSignInHelper, idToken, _initialized, signIn (+4 more)

### Community 47 - "media_player_controller.dart"
Cohesion: 0.05
Nodes (38): Duration get, _cueTimer, _defaultSubtitleFetcher, dispose, duration, _error, _espCue, _espTrack (+30 more)

### Community 48 - "categories"
Cohesion: 0.17
Nodes (11): categories, generatedAt, words, ANIMALS, BODY_PARTS, CLOTHES, COLORS, FIVE_SENSES (+3 more)

### Community 49 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (10): package:flutter_test/flutter_test.dart, package:jnatrjo_mobile/core/stars.dart, package:jnatrjo_mobile/core/storage/media_cache_key.dart, package:jnatrjo_mobile/data/models/models.dart, package:jnatrjo_mobile/data/services/misc_services.dart, package:jnatrjo_mobile/features/content/player/media_playback_source.dart, main, main (+2 more)

### Community 50 - "progress_ring.dart"
Cohesion: 0.13
Nodes (14): build, centerLabel, color, max, paint, progress, ProgressRing, semanticLabel (+6 more)

### Community 51 - "inicio-v2/prototype.js"
Cohesion: 0.18
Nodes (27): animations, announce(), audio, clearSchedule(), closeDialog(), dailyForToday(), day(), dialog (+19 more)

### Community 52 - "prototype.js"
Cohesion: 0.14
Nodes (10): audio, destinations, dialog, gameData, icon(), initial, listen, proposals (+2 more)

### Community 53 - "stat_card.dart"
Cohesion: 0.07
Nodes (27): ../../app/avatar_config.dart, Color, IconData, kid_card.dart, AboutContent, AboutScreen, _AboutSection, build (+19 more)

### Community 54 - "palette.dart"
Cohesion: 0.10
Nodes (19): AppPalette get, Gradient, adaptBrand, backgroundGradient, border, borderLight, copyWith, dark (+11 more)

### Community 55 - "Visitor Dashboard Controller"
Cohesion: 0.06
Nodes (35): Arreglo: Top de Estudiantes, Cambios en archivos:, Endpoints, GET /api/dashboard/visitor, GET /api/dashboard/visitor/{username}, GET /api/dashboard/visitor/{username}/experience, GET /api/dashboard/visitor/{username}/finished, GET /api/dashboard/visitor/{username}/inrow (+27 more)

### Community 56 - "package:flutter/material.dart"
Cohesion: 0.11
Nodes (16): ../../app/palette.dart, avatar_provider.dart, int?, createState, _saving, _selectedId, showAvatarPickerSheet, showModalBottomSheet (+8 more)

### Community 57 - "Game Controller"
Cohesion: 0.06
Nodes (33): DELETE /api/games/{id}, Endpoints, Game Controller, GET /api/games, GET /api/games/activities/{gameId}/students/{studentUsername}/responses, GET /api/games/{gameId}/preview, GET /api/games/{id}, GET /api/games/topic/{topic} (+25 more)

### Community 58 - "Activity Controller"
Cohesion: 0.06
Nodes (32): Activity Controller, Endpoints, GET /api/activities/group/{groupId}, GET /api/activities/student, GET /api/activities/teacher, GET /api/activities/{type}, PATCH /api/activities/instance/{groupId}/{gameId}, Path Parameters (+24 more)

### Community 59 - "DataClass"
Cohesion: 0.19
Nodes (19): CachedGamesCompanion, CachedMediaCompanion, CachedMediaData, CachedWord, CachedWordsCompanion, CompletedGame, CompletedGamesCompanion, DataClass (+11 more)

### Community 60 - "game_cache_service.dart"
Cohesion: 0.08
Nodes (23): asset_preloader.dart, DateTime?, applyGameDelta, _asInt, bundleGameIds, _bundleGames, _bundleGeneratedAt, _bundleSeededAtKey (+15 more)

### Community 61 - "SingleTickerProviderStateMixin"
Cohesion: 0.23
Nodes (14): WelcomeScreen, _WelcomeScreenState, _ProgressiveSubtitle, _ProgressiveSubtitleState, _Confetti, _ConfettiState, HomeCarousel, _HomeCarouselState (+6 more)

### Community 62 - "../../app/theme.dart"
Cohesion: 0.10
Nodes (20): ../../app/theme.dart, ../../core/sync/sync_service.dart, build, _buildResult, createState, initState, _message, _Status (+12 more)

### Community 63 - "export_games.py"
Cohesion: 0.11
Nodes (29): login(), Login compartido por los scripts de pre-poblado de build (export_dictionary.py,…, Inicia sesión con las credenciales de CI y devuelve el JWT. role: "visitor"…, api_get(), download(), main(), Exporta el diccionario del backend a assets/dictionary/ para uso offline.…, save_audio() (+21 more)

### Community 64 - "skeleton.dart"
Cohesion: 0.12
Nodes (15): AnimationController, double?, EdgeInsetsGeometry, aspectRatio, borderRadius, build, _controller, createState (+7 more)

### Community 65 - "validador_service.dart"
Cohesion: 0.09
Nodes (22): accents, _calcularDistanciaCoseno, _centroides, dispose, ensureCentroides, init, _initialized, _initializing (+14 more)

### Community 66 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.29
Nodes (6): connectivity, _hasNetwork, initial, watch, package:connectivity_plus/connectivity_plus.dart, package:flutter_riverpod/flutter_riverpod.dart

### Community 67 - "dart:math"
Cohesion: 0.40
Nodes (4): dart:math, package:jnatrjo_mobile/features/games/logic/maze_generator.dart, package:jnatrjo_mobile/features/games/logic/word_search_generator.dart, main

### Community 68 - "home_carousel.dart"
Cohesion: 0.07
Nodes (28): _actionStyle, _allowed, _badgeStyle, build, color, createState, didChangeAppLifecycleState, didChangeDependencies (+20 more)

### Community 69 - "ConsumerState"
Cohesion: 0.10
Nodes (29): ConsumerState, ConsumerStatefulWidget, VerifyEmailScreen, _VerifyEmailScreenState, DictionaryScreen, _DictionaryScreenState, GameAccessScreen, _GameAccessScreenState (+21 more)

### Community 70 - "Table"
Cohesion: 0.20
Nodes (10): @DataClassName, CachedGames, CachedMedia, CachedWords, CompletedGames, KvEntries, PendingDailyResults, PendingResults (+2 more)

### Community 71 - "sendero_nav_bar.dart"
Cohesion: 0.13
Nodes (14): build, destination, destinations, label, _NavItem, onDestinationSelected, onTap, selected (+6 more)

### Community 72 - "build"
Cohesion: 0.20
Nodes (10): dashboardProvider, build, avatarControllerProvider, build, _HeaderAvatar, _play, ProfileScreen, Route /perfil/acerca (+2 more)

### Community 74 - "authControllerProvider"
Cohesion: 0.22
Nodes (10): userSessionServiceProvider, authControllerProvider, _commit, logout, _showGoogleRegisterDialog, _submitLogin, build, _confirmLogout (+2 more)

### Community 75 - "dictionary_and_pronunciation_test.dart"
Cohesion: 0.09
Nodes (22): DictionaryService, Map, package:jnatrjo_mobile/core/ai/validador_service.dart, package:jnatrjo_mobile/core/storage/media_store.dart, package:jnatrjo_mobile/features/dictionary/dictionary_repository.dart, _categories, centroides, _FakeDictionaryService (+14 more)

### Community 80 - "assignments_screen.dart"
Cohesion: 0.14
Nodes (15): ../dashboard/dashboard_providers.dart, ../games/game_launcher.dart, activity, _AssignmentCard, AssignmentsScreen, _AssignmentsScreenState, build, createState (+7 more)

### Community 82 - "map_screen_test.dart"
Cohesion: 0.22
Nodes (8): AnimatedOpacity, dart:typed_data, dart:ui, package:jnatrjo_mobile/app/map_zones.dart, package:jnatrjo_mobile/features/map/map_geometry.dart, package:jnatrjo_mobile/features/map/map_screen.dart, package:jnatrjo_mobile/features/progress/progress_providers.dart, main

### Community 83 - "pronunciation_hub_screen.dart"
Cohesion: 0.09
Nodes (25): class, ../dictionary/dictionary_repository.dart, ../games/widgets/game_widgets.dart, centroidesProvider, appDatabaseProvider, dictionaryServiceProvider, _openAbout, dictionaryProvider (+17 more)

### Community 84 - "resource_update_service.dart"
Cohesion: 0.08
Nodes (23): CachedGames — contenido jugable por gameId, ../../data/services/catalog_service.dart, ../../features/dictionary/dictionary_repository.dart, game_cache_service.dart, GameCacheService, _advance, _applyDelta, _catalog (+15 more)

### Community 85 - "leaderboard_screen.dart"
Cohesion: 0.12
Nodes (16): _allUsers, createState, _currentPage, data, fromJson, _hasMore, initState, isCurrentUser (+8 more)

### Community 86 - "Arquitectura"
Cohesion: 0.12
Nodes (15): Arquitectura, Base de datos, Camino de aprendizaje (Inicio), Capas, Ciclo de vida de un juego, Comandos, Diccionario, graphify (+7 more)

### Community 87 - "Dictionary Controller"
Cohesion: 0.07
Nodes (28): DELETE /api/dictionary/words/{id}, Dictionary Controller, Endpoints, GET /api/dictionary/game/{gameId}, GET /api/dictionary/words/categories, GET /api/dictionary/words/daily, GET /api/dictionary/words/details/{id}, GET /api/dictionary/words/{topic} (+20 more)

### Community 88 - "xp_utils.dart"
Cohesion: 0.14
Nodes (13): double get, int get, costToNextLevel, cumulativeXpFor, fromTotalXp, level, levelBase, levelFromXp (+5 more)

### Community 89 - "dart:async"
Cohesion: 0.17
Nodes (11): AudioRecorder, dart:async, _audioRecorder, AudioRecorderHelper, dispose, grabarPCM16k, hasPermission, stopRecording (+3 more)

### Community 90 - "daily_pronunciation_test.dart"
Cohesion: 0.12
Nodes (15): package:jnatrjo_mobile/core/sync/sync_service.dart, package:jnatrjo_mobile/data/services/daily_pronunciation_service.dart, Set, account, api, awarded, challenge, completed (+7 more)

### Community 91 - "asset_preloader.dart"
Cohesion: 0.07
Nodes (31): Lints por defecto de flutter_lints, sin reglas propias, activityId vs gameId (effectiveActivityId), Reescritura de URLs a rutas de disco al precargar assets, Diccionario: emisión instantánea con refresh en segundo plano, Tolerancia a alias de campos del backend, gameConfigs[0]=prompt, gameConfigs[1]=opciones, KvEntries — copias JSON de dashboards, Patrón red-primero-luego-caché en providers (+23 more)

### Community 92 - "game_launcher.dart"
Cohesion: 0.20
Nodes (9): ../game_session.dart, launchGameWithLoading, loadingOpen, messenger, rootNavigator, router, setEnabledSystemUIMode, setPreferredOrientations (+1 more)

### Community 93 - "Diapositiva 3 — Resultados: pronunciación"
Cohesion: 0.07
Nodes (26): AM-Softmax (el ingrediente de entrenamiento), Anexo — Respuestas a preguntas probables, Apertura (la idea central), Cierre, Cierre de la diapositiva, Cierre de toda la sección, Cómo lo resuelve el producto, Diapositiva 1 — Cómo está construido el modelo (+18 more)

### Community 94 - "CustomPainter"
Cohesion: 0.22
Nodes (9): CustomPainter, _BubblesPainter, _BubbleTailPainter, SmokeEffectPainter, _MazePainter, _GridPainter, _LinesPainter, _ConfettiPainter (+1 more)

### Community 95 - "static const"
Cohesion: 0.24
Nodes (9): AsyncNotifier, ../../data/services/user_service.dart, userServiceProvider, AvatarController, build, _cacheKey, updateAvatar, _loadPage (+1 more)

### Community 96 - "fix_animation_transparency.py"
Cohesion: 0.32
Nodes (7): main(), process_animated_webp(), Image, Remove black/white backgrounds from animated WebP files and re-save with…, Remove background color from a single RGBA frame., Process an animated WebP: remove bg from all frames, re-save., remove_background()

### Community 97 - "progress_providers.dart"
Cohesion: 0.08
Nodes (25): ../../core/stars.dart, allGames, bundleIds, byZone, completedGames, computeProgressSnapshot, db, earnedStars (+17 more)

### Community 98 - "coyoteProvider"
Cohesion: 0.22
Nodes (9): build, _CoyoteLayer, _CoyoteLayerState, initState, coyoteProvider, build, initState, _speakForTab (+1 more)

### Community 99 - "sync_pronunciation_words.py"
Cohesion: 0.52
Nodes (6): get_token(), load_centroids_words(), main(), normalize_key(), Script para sincronizar el campo pronunciation=true en el backend para todas…, safe_print()

### Community 100 - "generate_app_icons.py"
Cohesion: 0.40
Nodes (5): create_padded_icon(), create_resized_full(), Image, r""" Generate Android and app icons from C:\Users\odtgo\Desktop\3.png with 18%…, Create square canvas of `size` and place `img` inside with `padding_ratio`…

### Community 101 - "avatar_config.dart"
Cohesion: 0.40
Nodes (4): avatarAssetPath, avatarCount, isValidAvatarId, safe

### Community 102 - "generate_and_upload_numbers.py"
Cohesion: 0.70
Nodes (4): generate_sticker(), get_number_words(), main(), upload_word()

### Community 103 - "daily-model.test.cjs"
Cohesion: 0.27
Nodes (9): complete(), forDay(), fresh(), pickPending(), shuffle(), assert, data, {fresh,forDay,complete,pickPending} (+1 more)

### Community 104 - "gameSessionProvider"
Cohesion: 0.18
Nodes (11): gameSessionProvider, _restart, build, build, build, build, build, _restart (+3 more)

### Community 105 - "media_player_view.dart"
Cohesion: 0.08
Nodes (24): _AudioCover, _AudioDisc, build, _buildFullscreen, _buildNormal, controller, _Controls, createState (+16 more)

### Community 106 - "Admin User Controller"
Cohesion: 0.09
Nodes (23): Admin User Controller, DELETE /api/admin/users/{username}, Endpoints, GET /api/admin/students, GET /api/admin/teacher, Path Parameters, Path Parameters, Path Parameters (+15 more)

### Community 121 - "Diapositiva 3 — Resultados: pronunciación"
Cohesion: 0.09
Nodes (22): Arquitectura (tres bloques), Cierre de la sección, Contraste honesto entre las dos tareas, Cómo lo afronta la aplicación, Cómo se llegó ahí — el salto que dio AM-Softmax, Despliegue, Diapositiva 1 — Cómo está construido el modelo, Diapositiva 2 — Resultados: identificación de palabra (+14 more)

### Community 122 - "Group Controller"
Cohesion: 0.09
Nodes (22): DELETE /api/groups/{grade}/students/{student}, Endpoints, GET /api/groups, GET /api/groups/{grade}/students, Group Controller, Path Parameters, Path Parameters, Path Parameters (+14 more)

### Community 123 - "resource_update_test.dart"
Cohesion: 0.11
Nodes (18): CatalogUpdates, package:jnatrjo_mobile/core/sync/resource_update_service.dart, package:jnatrjo_mobile/data/services/catalog_service.dart, applyGameDelta, applyWordDelta, _bundleDate, bundleGeneratedAt, calls (+10 more)

### Community 124 - "Student Dashboard Controller"
Cohesion: 0.11
Nodes (19): Endpoints, GET /api/dashboard/student, GET /api/dashboard/student/{username}, GET /api/dashboard/student/{username}/classmates, GET /api/dashboard/student/{username}/experience, GET /api/dashboard/student/{username}/finished, GET /api/dashboard/student/{username}/inrow, GET /api/dashboard/student/{username}/level (+11 more)

### Community 125 - "vtt_parser.dart"
Cohesion: 0.11
Nodes (18): Duration, contains, cueAt, cues, empty, end, isEmpty, isNotEmpty (+10 more)

### Community 126 - "Enumeraciones"
Cohesion: 0.11
Nodes (18): CatalogChangeType, Códigos de Error, Códigos de Respuesta HTTP, Difficult, Documentación de API - NtsiFiyo, Ejemplo de Error de Credenciales, Ejemplo de Error de Validación, Enumeraciones (+10 more)

### Community 127 - "Auth Controller"
Cohesion: 0.12
Nodes (17): Auth Controller, Endpoints, POST /api/auth/login/admin, POST /api/auth/login/student, POST /api/auth/login/teacher, POST /api/auth/login/visitor, POST /api/auth/visitor, Request Body (+9 more)

### Community 128 - "Media Controller"
Cohesion: 0.12
Nodes (17): DELETE /api/media/{id}, Endpoints, GET /api/media, GET /api/media/{id}/stream, GET /api/media/recommendations, Media Controller, Notas, Path Parameters (+9 more)

### Community 129 - "map_geometry.dart"
Cohesion: 0.13
Nodes (14): ../../app/map_zones.dart, int width,, contains, height, load, MapLabelLayout, performLayout, placed (+6 more)

### Community 130 - "_ZoneSheetState"
Cohesion: 0.29
Nodes (8): build, _buildGamesList, _ZoneLabel, _ZoneSheet, _ZoneSheetState, gamesForZoneProvider, gameStarsProvider, zoneProgressProvider

### Community 131 - "preproceso_audio_test.dart"
Cohesion: 0.12
Nodes (15): package:jnatrjo_mobile/core/ai/preproceso_audio.dart, return, amplitud, _bufferConPalabra, _distanciaCoseno, dot, inicioS, main (+7 more)

### Community 132 - "home_screen_test.dart"
Cohesion: 0.18
Nodes (10): dart:io, package:flutter/rendering.dart, package:jnatrjo_mobile/core/connectivity/connectivity_service.dart, package:jnatrjo_mobile/data/models/daily_pronunciation.dart, package:jnatrjo_mobile/features/auth/auth_controller.dart, package:jnatrjo_mobile/features/home/home_providers.dart, package:jnatrjo_mobile/features/home/home_screen.dart, build (+2 more)

### Community 133 - "game_cache_service_test.dart"
Cohesion: 0.11
Nodes (19): package:flutter_secure_storage/flutter_secure_storage.dart, package:jnatrjo_mobile/core/api/api_client.dart, package:jnatrjo_mobile/core/storage/session_store.dart, package:jnatrjo_mobile/core/sync/game_cache_service.dart, package:jnatrjo_mobile/data/services/activity_service.dart, package:jnatrjo_mobile/features/home/home_carousel.dart, _details, _detailsFailFor (+11 more)

### Community 134 - "List"
Cohesion: 0.14
Nodes (13): activity_config.dart, double x, y, w,, contains, gameTypes, h, id, img, label (+5 more)

### Community 135 - "Admin Dashboard Controller"
Cohesion: 0.14
Nodes (14): Admin Dashboard Controller, Endpoints, GET /api/dashboard/admin, GET /api/dashboard/admin/activities, GET /api/dashboard/admin/games, GET /api/dashboard/admin/groups/students, GET /api/dashboard/admin/students/inrow, GET /api/dashboard/admin/words (+6 more)

### Community 136 - "vtt_parser_test.dart"
Cohesion: 0.22
Nodes (8): package:jnatrjo_mobile/features/content/logic/vtt_parser.dart, Primera, Segunda, 1, línea, main, NOTE, WEBVTT

### Community 137 - "User Controller"
Cohesion: 0.15
Nodes (13): Endpoints, GET /api/user/available, GET /api/user/avatar, POST /api/user/session/start, PUT /api/user/avatar, PUT /api/user/session/end, Request Body, Response Body (200 OK) (+5 more)

### Community 138 - "_HomeScreenState"
Cohesion: 0.14
Nodes (21): ConsumerWidget, isOnlineProvider, ContentScreen, build, ExploreHubScreen, _ActivityCard, build, GamesHubScreen (+13 more)

### Community 139 - "theme_controller.dart"
Cohesion: 0.25
Nodes (7): build, _load, _prefsKey, setMode, ThemeModeController, package:shared_preferences/shared_preferences.dart, ThemeMode

### Community 140 - "API_Documentation.md"
Cohesion: 0.18
Nodes (10): Catalog Controller, Endpoints, Endpoints, GET /api/catalog/updates, GET /api/leaderboard, Leaderboard Controller, Request, Response Body (200 OK) (+2 more)

### Community 141 - "Teacher Dashboard Controller"
Cohesion: 0.18
Nodes (11): Endpoints, GET /api/dashboard/teacher/{group}, GET /api/dashboard/teacher/{group}/activities/assigned, GET /api/dashboard/teacher/{group}/students/alert, GET /api/dashboard/teacher/{group}/students/total, Path Parameters, Response Body (200 OK), Response Body (200 OK) (+3 more)

### Community 142 - "word_image_test.dart"
Cohesion: 0.29
Nodes (6): AssetImage, FileImage, package:jnatrjo_mobile/app/theme.dart, package:jnatrjo_mobile/features/games/widgets/game_widgets.dart, main, _wrap

### Community 143 - "../../data/models/models.dart"
Cohesion: 0.12
Nodes (14): ../../core/ai/validador_service.dart, ../../data/models/models.dart, espSubtitlesUrl, fromStream, mazSubtitlesUrl, MediaPlaybackSource, posterUrl, title (+6 more)

### Community 144 - "routerProvider"
Cohesion: 0.29
Nodes (7): Release firmado con keystore de debug, Google Sign-In usa el client ID web como serverClientId, sessionStoreProvider sobreescrito en main(), routerProvider, sessionStoreProvider, Verificación de email abre el navegador, Dos modos de login: estudiante y visitante

### Community 145 - "POST /api/pronunciation/validate/{wordId}"
Cohesion: 0.25
Nodes (8): Ejemplo: palabra distinta reconocida, Ejemplo: silencio, Endpoints, Path Parameters, POST /api/pronunciation/validate/{wordId}, Pronunciation Controller, Request (multipart/form-data), Response Body (200 OK)

### Community 146 - "daily_pronunciation_service.dart"
Cohesion: 0.11
Nodes (17): api, cached, _check, complete, DailyPronunciationService, dailyPronunciationServiceProvider, db, _historyKey (+9 more)

### Community 147 - "dictionary_word_delta_test.dart"
Cohesion: 0.09
Nodes (22): _, @DriftDatabase, schemaVersion 1 sin MigrationStrategy, AppDatabase, MediaStore, package:drift/drift.dart, package:drift/native.dart, package:jnatrjo_mobile/core/storage/app_database.dart (+14 more)

### Community 148 - "Guía de estilo — imágenes de números (assets/numbers/)"
Cohesion: 0.33
Nodes (5): Especificación visual (idéntica para los 20), Guía de estilo — imágenes de números (assets/numbers/), Nombres de archivo, Paleta por número (usar estos colores, es lo que da uniformidad al set), Regla dura

### Community 149 - "AuthController"
Cohesion: 0.22
Nodes (9): AppUser, authServiceProvider, AuthController, AuthScreen, _AuthScreenState, _submitRegister, _verify, VisitorAuth (+1 more)

### Community 150 - "media_cache_key.dart"
Cohesion: 0.40
Nodes (4): match, mediaCacheKey, _ociParSegment, replaceRange

### Community 151 - "home_providers.dart"
Cohesion: 0.10
Nodes (21): account, all, bundle, cached, db, dict, games, homeAccountProvider (+13 more)

### Community 156 - "package:flutter/services.dart"
Cohesion: 0.33
Nodes (5): enterImmersiveLandscape, exitImmersiveLandscape, setEnabledSystemUIMode, setPreferredOrientations, package:flutter/services.dart

### Community 157 - "daily_pronunciation.dart"
Cohesion: 0.11
Nodes (17): bool completed,, DateTime startsAt,, DailyChallenge, error, expiresAt, fromJson, id, localOnly (+9 more)

### Community 158 - "home_screen.dart"
Cohesion: 0.11
Nodes (18): ../../data/models/daily_pronunciation.dart, ../../data/services/daily_pronunciation_service.dart, ../games/games_hub_screen.dart, home_carousel.dart, home_providers.dart, dailyChallengeProvider, _carouselVisible, _checkDay (+10 more)

### Community 159 - "GamePlayScreen"
Cohesion: 0.50
Nodes (5): Receta para añadir un juego nuevo, Despacho de juego por id de ruta, no por gameType, activityConfig, GamePlayScreen, _GamePlayScreenState

### Community 160 - "coyote_messages.dart"
Cohesion: 0.40
Nodes (4): coyote_controller.dart, coyoteGameInstruction, coyoteSectionMessages, _gameInstructions

### Community 161 - "AppPalette"
Cohesion: 1.00
Nodes (3): @immutable, AppPalette, ThemeExtension

### Community 162 - "../../../core/api/api_client.dart"
Cohesion: 0.29
Nodes (6): ../../../core/api/api_client.dart, _api, getAvatar, getLeaderboard, updateAvatar, UserService

### Community 163 - "Inicio y pronunciación diaria"
Cohesion: 0.33
Nodes (5): Contrato del reto, Despliegue, Inicio y pronunciación diaria, Sin conexión, Validación reproducible

## Ambiguous Edges - Review These
- `Backend por defecto en DigitalOcean` → `Backend por defecto en Koyeb (README)`  [AMBIGUOUS]
  README.md · relation: semantically_similar_to

## Knowledge Gaps
- **2022 isolated node(s):** `generatedAt`, `ANIMALS`, `PRONOUNS`, `CLOTHES`, `FOOD` (+2017 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Backend por defecto en DigitalOcean` and `Backend por defecto en Koyeb (README)`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._
- **Why does `AppDatabase` connect `dictionary_word_delta_test.dart` to `app_database.dart`, `daily_pronunciation_service.dart`, `media_store.dart`, `resource_update_service.dart`, `sync_service.dart`, `dictionary_repository.dart`, `daily_pronunciation_test.dart`, `asset_preloader.dart`, `game_cache_service.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **What connects `generatedAt`, `ANIMALS`, `PRONOUNS` to the rest of the system?**
  _2022 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.009852216748768473 - nodes in this community are weakly interconnected._
- **Should `models.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.017391304347826087 - nodes in this community are weakly interconnected._
- **Should `game_summary_view.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.041666666666666664 - nodes in this community are weakly interconnected._
- **Should `word_search_generator.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06896551724137931 - nodes in this community are weakly interconnected._