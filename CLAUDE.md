# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es este proyecto

App Android en Flutter (`jnatrjo_mobile`) para aprender mazahua jugando. Es el **port móvil de la plataforma web React** (repo `J-atrjo`), restringido a los roles **estudiante** y **visitante** (no hay panel docente/admin). Habla con el mismo backend Spring que la web.

El código está escrito en español: comentarios, textos de UI y mensajes de error. Mantén esa convención.

Casi cada archivo de `lib/data/`, `lib/app/` y `lib/features/` es un *mirror* de un archivo concreto de la web (`client/src/services/ActivityApiService.js`, `client/src/config/activityConfig.jsx`, `GameSummary.jsx`, `GameAccessPanel.jsx`, `AuthContext`, `tailwind.config.js`…). Los doc comments dicen cuál. **Antes de cambiar lógica de negocio, comprueba qué hace la web**: la paridad con la web es intencional, no accidental.

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenera app_database.g.dart
flutter analyze
flutter test
flutter test test/sync_queue_test.dart                     # un archivo
flutter test --plain-name "cola de resultados pendientes"  # un test
flutter run                                                # dispositivo/emulador Android
flutter build apk --release
dart run flutter_launcher_icons                            # regenera íconos desde assets/icon*.png
```

Backend configurable: `flutter run --dart-define=API_URL=https://...`. Default = producción en DigitalOcean (`lib/core/api/api_client.dart`).

Regenerar el snapshot offline del diccionario (requiere `pip install requests pillow` y un JWT sacado de `localStorage.authToken` en la web):

```bash
python scripts/export_dictionary.py --token <JWT>
```

## Arquitectura

Riverpod (estado) + go_router (navegación) + dio (HTTP) + drift (SQLite). Sin generadores de código salvo drift (`app_database.g.dart`) — los modelos son `fromJson`/`toJson` a mano.

### Capas

- `lib/core/` — infraestructura: `api/` (dio + interceptor JWT + `ApiException` con mensajes en español), `storage/` (drift + `SessionStore` sobre secure storage), `sync/` (offline), `connectivity/`.
- `lib/data/` — `models/models.dart` (todos los DTOs en un archivo) y `services/` (una clase por servicio de la web).
- `lib/app/` — `router.dart`, `theme.dart`, `activity_config.dart`.
- `lib/features/<feature>/` — pantallas + providers. Los juegos viven en `features/games/`: `views/` (una vista por juego), `logic/` (generadores puros de laberinto y sopa de letras, testeados), `widgets/`.

`sessionStoreProvider` lanza `UnimplementedError` por diseño: `main()` lo sobreescribe con la instancia ya cargada desde secure storage, para que el router sepa la pantalla inicial sin parpadeo.

### Offline-first (el punto central del proyecto)

Tres cachés distintas en drift (`lib/core/storage/app_database.dart`):

1. **`CachedGames`** — contenido jugable completo por `gameId`. `AppShell.initState` y cada reconexión disparan `GameCacheService.cacheAllGames()`, que hace `GET /api/games` y un `POST /api/activities/start/game/{id}` por juego no cacheado. `preloadGameAssets` (`core/sync/asset_preloader.dart`) descarga imágenes/audio a `getApplicationSupportDirectory()/game_media/` y **reescribe las URLs del `GameData` a rutas de disco antes de serializarlo**. Es decir: el `contentJson` guardado contiene rutas locales, no URLs. Los widgets deben aceptar ambas.
2. **`PendingResults`** — cola de partidas terminadas sin red. Se encolan en `GameSessionController.complete()` cuando el POST falla.
3. **`KvEntries`** — copias JSON de dashboards (`dashboard_student` / `dashboard_visitor`), usadas como fallback offline y para calcular el nivel/XP «antes» del resumen de sincronización.

**Protocolo de sincronización de 2 pasos** (`SyncService.syncPending`), obligatorio porque el backend invalida el `activityId` original: por cada pendiente → `POST /api/activities/start/game/{gameId}` para obtener un `activityId` fresco → `POST /api/activities/complete` con los resultados guardados. Un fallo corta el bucle (no se sigue golpeando el backend) y deja el resto pendiente. Al terminar, `SyncController` publica un `SyncSummary` y `AppShell` lo muestra en un bottom sheet e invalida `dashboardProvider`.

Patrón general de los providers de datos: intenta la red, y en el `catch` cae al caché (`dashboardProvider`, `activitiesByTypeProvider`, `GameSessionController.startFromGame`). No introduzcas providers que fallen duro por falta de red.

### Ciclo de vida de un juego

`GameAccessScreen._play` → `gameSessionProvider.startFromGame(game)` (POST start, o caché si no hay red) → `context.push('/games/{id}/jugar')` → `GamePlayScreen` despacha a la vista.

**`GamePlayScreen` decide el juego por el `id` de la ruta** (`quiz`, `memorama`, …), no por `session.data.gameType`, porque el backend no siempre incluye `gameType` en la respuesta del start; el `gameType` es solo fallback. Si el despacho falla cae a `UnderConstructionScreen`.

`activityId` vs `gameId`: si el start devolvió `activityId`, el juego viene de una asignación; si no, el `gameId` hace de ambos. Usa `GameSession.effectiveActivityId` para el `POST /complete`.

Añadir un juego nuevo = entrada en `activityConfig` (`lib/app/activity_config.dart`, con `id` corto para la ruta) + `case` en el `switch` de `GamePlayScreen` + vista en `features/games/views/` + añadir el tipo a `playableGameTypes`.

Los `gameConfigs` controlan cómo se presenta el contenido: `gameConfigs[0]` = prompt, `gameConfigs[1]` = opciones (`GameData.promptConfig` / `answerConfig`). `isMazahua` decide el idioma del texto (`Word.textFor`).

### Diccionario

`DictionaryController` emite **al instante** la copia local y refresca en segundo plano. Fuentes, en orden: disco (`dictionary_cache.json`) → snapshot empaquetado en `assets/dictionary/manifest.json` → red. Además, `_applyBundleMedia` sustituye `imageUrl`/`audioUrl` por assets del bundle siempre que la palabra exista en él (match por `id`), aunque los datos vengan de la red: carga inmediata y sin tráfico. Solo las palabras nuevas usan URL remota.

### Navegación y mapa

`StatefulShellRoute.indexedStack` con 5 ramas (Inicio, Mapa, Juegos, Diccionario, Contenido). `/games/:gameId/jugar` y `/reproductor/:id` cuelgan del navigator raíz → pantalla completa sin bottom nav.

La app está bloqueada en vertical desde `main()`. La rama del mapa (índice 1) es la excepción: `AppShell` llama a `enterMapChrome()`/`exitMapChrome()` (`features/map/map_screen.dart`) para pasar a horizontal inmersivo y ocultar el bottom nav. Cambiar el orden de las ramas rompe la constante `_mapBranch`.

### Modelos

El backend varía nombres de campo entre endpoints (`gameConfigDTO` vs `gameConfigs` vs `gameconfigs`, `id` vs `gameId`, `firstname` vs `firstName`). Todos los `fromJson` aceptan alias y usan los helpers `_asInt`/`_asBool` para tolerar strings. **Mantén esa tolerancia** al tocar los parsers; los tests de `widget_test.dart` la cubren.

`ResponseLog.toJson()` (persistencia local) incluye `wordText`; `toApiJson()` (payload del backend) no. No los mezcles.

## Base de datos

`schemaVersion` es 1 y no hay `MigrationStrategy`. Si cambias una tabla de `app_database.dart`, corre `build_runner`, sube `schemaVersion` y añade la migración. Los tests usan `AppDatabase.forTesting(NativeDatabase.memory())`.

## Notas de release

- Google Sign-In usa el client ID **web** como `serverClientId`. Si el backend rechaza el audience, hay que registrar un client ID Android en el mismo proyecto de Google Cloud.
- `android/app/build.gradle.kts` firma release con el keystore de **debug**. Generar uno propio antes de publicar.
- `minSdk` 23, `applicationId` `com.jnatrjo.jnatrjo_mobile`.

## graphify

<!-- Sección traducida a mano al español para respetar la convención del repo.
     OJO: `graphify claude install` la sobrescribe con el bloque estándar en
     inglés. Si actualizas graphify y reinstalas, vuelve a traducirla. -->

Este proyecto tiene un grafo de conocimiento en `graphify-out/` (código + docs) con god nodes, comunidades y relaciones entre archivos.

Reglas:

- **Antes de responder preguntas sobre el código**, corre `graphify query "<pregunta>"` si existe `graphify-out/graph.json`. Devuelve un subgrafo acotado, mucho más barato que `GRAPH_REPORT.md` o que rastrear con grep.
- **Antes de cualquier refactor**, corre `graphify affected "<X>"`. Hace traversal inverso y dice qué se rompe de verdad, no coincidencias de texto. Especialmente útil con los puntos de cambio acoplados: añadir un juego toca `activityConfig`, el `switch` de `GamePlayScreen`, la vista en `features/games/views/` y `playableGameTypes` a la vez.
- `graphify path "<A>" "<B>"` para trazar un flujo entre dos conceptos; `graphify explain "<X>"` para entender un nodo puntual.
- Lee `graphify-out/GRAPH_REPORT.md` solo para revisión arquitectónica amplia, o cuando query/path/explain no den suficiente contexto.
- **Tras modificar código**: `graphify update .` (solo AST, sin coste de LLM). El hook de post-commit ya lo hace automáticamente en cada commit.
- **Tras modificar documentación** (`CLAUDE.md`, `README.md`, `pubspec.yaml`): `/graphify . --update`. Esto sí re-extrae con LLM.

Alcance del grafo (importante para no sacar conclusiones falsas):

- Cubre los 68 archivos de código y los 5 docs. Los ~370 assets del diccionario (imágenes `.webp` y audio `.mp3`) se excluyeron a propósito: son carga de datos, no arquitectura.
- Los ~1019 nodos aislados que reporta son en su mayoría claves del `manifest.json` del diccionario y campos sueltos de DTOs. Es ruido esperado, **no** deuda arquitectónica.
- El matcher de `query` es substring sobre etiquetas de nodo, sin stemming ni sinónimos. Usa nombres reales (`gameSessionProvider`, `SyncService`, `AppDatabase`, `DictionaryController`) en vez de descripciones vagas.
