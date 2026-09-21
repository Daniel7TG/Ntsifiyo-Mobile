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

Backend configurable: `flutter run --dart-define=API_URL=https://...`. Default = túnel ngrok (`lib/core/api/api_client.dart`); DigitalOcean quedó archivado. El túnel rota de URL — antes de depender de él, confirma con `curl <url>/actuator/health`.

Regenerar los snapshots offline (diccionario + juegos) antes de un release — requiere `pip install requests pillow`. Corren solos con `JNATRJO_CI_USERNAME`/`JNATRJO_CI_PASSWORD` (login automático, sin copiar ningún JWT a mano); el orden importa, `export_games.py` reutiliza el manifest del diccionario recién regenerado para no descargar media duplicada, y ambos deben correr justo antes del build para que `generatedAt` sea fiel a ese release:

```bash
export JNATRJO_CI_USERNAME=...
export JNATRJO_CI_PASSWORD=...
python scripts/export_dictionary.py     # 1. words — acepta rol visitante
python scripts/export_games.py          # 2. games — necesita rol admin/estudiante (ver más abajo)
flutter build apk --release             # 3. build, inmediatamente después
```

`export_games.py` pide credenciales con más permisos que `export_dictionary.py` porque `GET /api/games` (el listado paginado con `gameTopic` por juego, único lugar con esos metadatos de catálogo) es `hasAnyRole("TEACHER", "ADMIN")` en el backend (`SecurityConfig.java`) — no da 403 "a veces" para visitante, lo da siempre, para cualquier rol de esta app. El contenido de cada juego se baja con `GET /api/games/{id}/preview` (no `POST start`: eso crearía una actividad fantasma en el servidor por cada juego, en cada release).

Con `--token <JWT>` ya obtenido a mano (`localStorage.authToken` en la web) también funciona, sin necesidad de las variables de entorno — solo para `export_dictionary.py`.

## Arquitectura

Riverpod (estado) + go_router (navegación) + dio (HTTP) + drift (SQLite). Sin generadores de código salvo drift (`app_database.g.dart`) — los modelos son `fromJson`/`toJson` a mano.

### Capas

- `lib/core/` — infraestructura: `api/` (dio + interceptor JWT + `ApiException` con mensajes en español, `error_messages.dart` los traduce a texto legible para la UI), `storage/` (drift + `SessionStore` sobre secure storage + `MediaStore` para binarios descargados), `sync/` (offline), `connectivity/`.
- `lib/data/` — `models/models.dart` (todos los DTOs en un archivo) y `services/` (una clase por servicio de la web).
- `lib/app/` — `router.dart`, `theme.dart` + `palette.dart` (tema claro/oscuro), `activity_config.dart`, `learning_path.dart` (unidades del camino de aprendizaje).
- `lib/features/<feature>/` — pantallas + providers. Los juegos viven en `features/games/`: `views/` (una vista por juego), `logic/` (generadores puros de laberinto y sopa de letras, testeados), `widgets/`.

`sessionStoreProvider` lanza `UnimplementedError` por diseño: `main()` lo sobreescribe con la instancia ya cargada desde secure storage, para que el router sepa la pantalla inicial sin parpadeo.

### Offline-first (el punto central del proyecto)

**Principio duro: el refresco automático nunca vacía una caché.** El bundle
(diccionario y juegos — `assets/dictionary/manifest.json` y
`assets/games/manifest.json`, generados por `scripts/export_dictionary.py` y
`scripts/export_games.py` antes de cada build) es el piso; una respuesta del
backend vacía, corta o con ids reasignados es indistinguible en el momento de
un fallo real (backend intermitente, sesión caída, paginación distinta), así
que se trata siempre como sospechosa, nunca como "el backend borró esto de
verdad". El único camino de red automático que toca `CachedGames`
(`GameCacheService.applyGameDelta`, disparado por `ResourceUpdateService` en
cada arranque) solo aplica altas/bajas por id explícito, nunca una lista
completa; `DictionaryRepository` nunca persiste una lista vacía ni con
`force: true`, y el refresco automático del diccionario tampoco usa `force`.
Solo una acción explícita del usuario (botón "actualizar" del diccionario, o
"Restablecer datos offline" en Perfil) puede reducir o vaciar una caché. Si
tocas `GameCacheService`, `DictionaryRepository._saveToDb` o
`ResourceUpdateService`, no reintroduzcas un camino automático que pueda
vaciar `CachedGames`/`CachedWords` por una lista incompleta.

Tres cachés distintas en drift (`lib/core/storage/app_database.dart`):

1. **`CachedGames`** — contenido jugable completo por `gameId`. Se puebla por solo dos caminos, ninguno de los cuales lista el catálogo completo:
   - **Bundle** (`GameCacheService.seedFromBundleIfNewer`): siembra desde `assets/games/manifest.json` (`scripts/export_games.py`) sin red, en instalación nueva o cuando el APK trae un `generatedAt` más nuevo que el ya sembrado (KV `games_bundle_seeded_at`).
   - **Delta** (`GameCacheService.applyGameDelta`, ver más abajo): por cada id CREATED/UPDATED, `GET /api/games/{id}` (metadatos: título, tema, dificultad) + `GET /api/games/{id}/preview` (contenido jugable). **Nunca `GET /api/games`**: ese listado es `hasAnyRole("TEACHER", "ADMIN")` en el backend, no alcanzable por esta app ni por accidente. **Nunca `GET /api/games/topic/{topic}`**: no devuelve el tema por juego (ver «Camino de aprendizaje» abajo). **Nunca `POST /api/activities/start/game/{id}`** para cachear: eso crea una actividad real en el servidor; se reserva para cuando el usuario juega de verdad (`GameSessionController.startFromGame`).

   `preloadGameAssets` (`core/sync/asset_preloader.dart`) descarga imágenes/audio a `getApplicationSupportDirectory()/game_media/` vía `MediaStore` y **reescribe las URLs del `GameData` a rutas de disco antes de serializarlo**. El `contentJson` guardado contiene rutas locales, no URLs. `GameCacheService.completeMissingGameMedia()` reintenta, en cada arranque, la media de los juegos que quedaron con `mediaComplete: false` (sin volver a tocar el catálogo).
2. **`PendingResults`** — cola de partidas terminadas sin red. Se encolan en `GameSessionController.complete()` cuando el POST falla.
3. **`KvEntries`** — copias JSON de dashboards (`dashboard_student` / `dashboard_visitor`), usadas como fallback offline y para calcular el nivel/XP «antes» del resumen de sincronización.

**Sincronización incremental en cada arranque** (`ResourceUpdateService`, `lib/core/sync/resource_update_service.dart`): `AppShell._bootstrapCaches` llama primero a `GameCacheService.seedFromBundleIfNewer()`, luego a `checkAndRefresh()` (comparten el flag `_running` de `GameCacheService`, por eso van encadenados y no en paralelo) y por último a `completeMissingGameMedia()`. `checkAndRefresh()` consulta **`GET /api/catalog/updates?since=<cursor>`** (`CatalogService`, `lib/data/services/catalog_service.dart`). El backend devuelve los **ids** de lo que cambió con su `changeType` (`CREATED`/`UPDATED`/`DELETED`), no el contenido; con esos ids se baja solo lo que falta. Los juegos, como arriba. Las palabras con **una sola llamada** a `GET /api/dictionary/words/full?ids=...` (`applyWordDelta`, `DictionaryRepository`): a diferencia de `GET /api/dictionary/words/details/{id}` (que solo trae media, `WordMediaResponseDTO`), `words/full` sí devuelve la palabra completa por id (`WordFullDTO` = texto en ambos idiomas, categoría, media), así que ya no hace falta deducir la categoría del propio caché ni bajarla entera para editar una palabra. Si `words/full` no está desplegado (403/404), `applyWordDelta` cae a un camino de respaldo por categoría — ver el doc comment del método. Sustituye a los antiguos `/api/games/updatedGames` y `/api/dictionary/updatedWords`, que solo daban una fecha y obligaban a redescargar el catálogo entero; ya no existen en el cliente.

Cuatro invariantes de este flujo, todas con su porqué:

- **El cursor es el `serverTime` de la respuesta, guardado como texto y reenviado verbatim** (`ResourceUpdates.syncCursor`). Se compara contra el reloj del servidor, así que mandar la hora del dispositivo perdería cambios por desfase; y el backend lo emite como `LocalDateTime` (sin zona), así que pasarlo por `DateTime` lo reinterpretaría en la zona local del móvil. No lo conviertas a `DateTime` ni le añadas offset.
- **Un cursor por recurso** (`GAME`/`DICTIONARY`), aunque la llamada sea una sola. Si los juegos se aplican pero el diccionario falla, solo avanza el de `GAME`. Se manda como `since` el **más atrasado** de los dos, así que el recurso adelantado puede recibir cambios que ya aplicó: re-descargar es idempotente y volver a borrar un id ya borrado no hace nada.
- **`DELETED` sí se obedece automáticamente**, y no contradice el principio de arriba. Ese principio existe porque una *lista completa* vacía o corta es indistinguible de un backend caído; un id marcado `DELETED` es la afirmación positiva que faltaba. Sigue sin haber ningún camino automático que borre en bloque: un vaciado real solo pasa por "Restablecer datos offline" en Perfil (`AppDatabase.resetOfflineCaches()`) o por el botón de actualizar del diccionario (`DictionaryController.refresh()`). Por eso `AppDatabase.applyCachedWordDelta` y `GameCacheService.applyGameDelta` sí borran por id mientras `DictionaryRepository._saveToDb` mantiene intacta su salvaguarda anti-menguante.
- **El cursor solo avanza si el delta se aplicó entero.** `applyGameDelta`/`applyWordDelta` devuelven false si algún id falló, y entonces `ResourceUpdates` se deja como estaba para reintentar el mismo rango en el próximo arranque.

Primera sincronización (sin cursor guardado): se usa como línea base la fecha del snapshot empaquetado (`GameCacheService.bundleGeneratedAt()` / `DictionaryRepository.bundleGeneratedAt()`, el `generatedAt` que escribe cada script de export). Si alguna falta, se pide el catálogo completo, pero entonces **solo se guarda el cursor sin aplicar el delta id a id**: la app ya viene sembrada por el bundle (`seedFromBundleIfNewer`, `DictionaryController`), así que bajar cientos de ids sueltos para reconstruir lo que ya está sería peor que el camino de lista completa. A partir del segundo arranque los deltas ya son exactos.

Un fallo de red no bloquea el arranque ni toca la tabla. Un dispositivo cuyas cachés ya quedaron dañadas se repara con "Restablecer datos offline" en Perfil (`AppDatabase.resetOfflineCaches()`, que también re-siembra `CachedGames` desde el bundle antes de devolver el control a la UI).

**Media con token rotativo (por qué antes se re-descargaba todo en cada arranque):** el backend genera cada URL de imagen/audio con un PAR de OCI Object Storage **nuevo en cada respuesta** (`OciService.generarUrlPrivadaParaBucket()`, expira en 1h) — mismo objeto, URL distinta cada vez. `MediaStore` (y `CachedMedia`) cachean por `mediaCacheKey(url)` (`core/storage/media_cache_key.dart`), que quita el segmento de token y deja namespace/bucket/objeto — la parte que sí es estable — como clave; `CachedMedia.sourceUrl` guarda la última URL absoluta vista, para poder re-descargar si el archivo local desaparece. Cachear por la URL completa (como se hacía antes) convertía cada respuesta del backend en un miss garantizado. Si tocas `MediaStore.localize`/`resolve`, sigue pasando por `mediaCacheKey` en vez de la URL cruda.

**Protocolo de sincronización de 2 pasos** (`SyncService.syncPending`), obligatorio porque el backend invalida el `activityId` original: por cada pendiente → `POST /api/activities/start/game/{gameId}` para obtener un `activityId` fresco → `POST /api/activities/complete` con los resultados guardados. Un fallo corta el bucle (no se sigue golpeando el backend) y deja el resto pendiente. Al terminar, `SyncController` publica un `SyncSummary` y `AppShell` lo muestra en un bottom sheet e invalida `dashboardProvider`.

Patrón general de los providers de datos: intenta la red y en el `catch` cae al caché (`dashboardProvider`, `GameSessionController.startFromGame`); los que solo listan juegos ya cacheados (`activitiesByTypeProvider`, `gamesByTopicProvider`, `learningPathProvider`) ni siquiera intentan red — leen `CachedGames` directo, porque el catálogo completo del backend no es alcanzable para esta app (ver «Camino de aprendizaje» y «Offline-first» arriba). No introduzcas providers que fallen duro por falta de red.

### Ciclo de vida de un juego

`GameAccessScreen._play` → `gameSessionProvider.startFromGame(game)` (POST start, o caché si no hay red) → `context.push('/games/{id}/jugar')` → `GamePlayScreen` despacha a la vista.

**`GamePlayScreen` decide el juego por el `id` de la ruta** (`quiz`, `memorama`, …), no por `session.data.gameType`, porque el backend no siempre incluye `gameType` en la respuesta del start; el `gameType` es solo fallback. Si el despacho falla cae a `UnderConstructionScreen`.

`activityId` vs `gameId`: si el start devolvió `activityId`, el juego viene de una asignación; si no, el `gameId` hace de ambos. Usa `GameSession.effectiveActivityId` para el `POST /complete`.

Añadir un juego nuevo = entrada en `activityConfig` (`lib/app/activity_config.dart`, con `id` corto para la ruta) + `case` en el `switch` de `GamePlayScreen` + vista en `features/games/views/` + añadir el tipo a `playableGameTypes`.

Los `gameConfigs` controlan cómo se presenta el contenido: `gameConfigs[0]` = prompt, `gameConfigs[1]` = opciones (`GameData.promptConfig` / `answerConfig`). `isMazahua` decide el idioma del texto (`Word.textFor`).

### Camino de aprendizaje (Inicio)

`PathScreen` muestra las unidades de `lib/app/learning_path.dart` en un orden fijo, con estado completada/actual/bloqueada. `learningPathProvider` (`lib/features/path/path_providers.dart`) lee `CachedGames` **por entero** y agrupa en memoria por `topic` — **nunca** llama a `GET /api/games/topic/{topic}` ni a ningún otro endpoint. Lo mismo hacen `gamesByTopicProvider` (`map_screen.dart`) y `activitiesByTypeProvider` (`games_providers.dart`, agrupa por `gameType`): los tres son lectura local pura sobre la misma tabla que ya puebla `GameCacheService`.

**El backend no expone progreso por tema** (`completed`/`locked`/`order` no existen en ningún DTO), así que ese estado es una **inferencia 100% local**: la tabla `CompletedGames` de drift registra cada partida terminada con su `topic` (leído de `CachedGames.topic`, que ya se guarda al iniciar el juego). No viaja entre dispositivos ni sobrevive a una reinstalación — si el backend algún día expone un endpoint de progreso, solo hay que cambiar la fuente de `lib/features/path/path_providers.dart`, la UI no se entera.

**`GET /api/games/topic/{topic}` no devuelve `topic`/`gameTopic` por juego** (confirmado en vivo) — el tema es implícito en qué endpoint se llamó, no viaja en el payload. Por eso ya no se usa para poblar `CachedGames`: persistir su resultado a ciegas (guardando `g.topic`, que llega `null`) era el bug real detrás de "la app vuelve a descargar todo en cada arranque" — la fila quedaba con `topic: null`, el filtro `cachedGames.where(cg.topic == unit.topic)` nunca volvía a encontrarla, y el barrido por los 8 temas se repetía para siempre. `GameCacheService.applyGameDelta`/`_seedFromBundle` y `GameSessionController.startFromGame` son ahora los únicos que escriben `topic` en `CachedGames`, siempre con `Value.absent()` en vez de `null` cuando no lo conocen — para no pisar un valor bueno ya cacheado. Si tocas cualquiera de esos tres, no reintroduzcas ese bug.

### Diccionario

`DictionaryController` emite **al instante** la copia local (disco → snapshot empaquetado en `assets/dictionary/manifest.json`) y ya no dispara un refresco de fondo propio: el refresco lo cubre `ResourceUpdateService.checkAndRefresh()` → `DictionaryRepository.applyWordDelta`, llamado una vez desde `AppShell` para juegos y diccionario a la vez. Además, `_applyBundleMedia` sustituye `imageUrl`/`audioUrl` por assets del bundle siempre que la palabra exista en él (match por `id`), aunque los datos vengan de la red: carga inmediata y sin tráfico. Solo las palabras nuevas usan URL remota.

`applyWordDelta` baja las palabras `CREATED`/`UPDATED` con una sola llamada a `GET /api/dictionary/words/full?ids=...` — ver «Sincronización incremental» arriba. `_fetchCategory` (`GET /api/dictionary/words/{topic}`) sigue existiendo solo como camino de respaldo (`_applyWordDeltaByCategory`, para un backend sin `words/full` desplegado) y para `fetchRemote()` (descarga completa, botón "actualizar" o primera instalación sin bundle). **`GET /api/dictionary/words/{topic}` no devuelve el tema por palabra** (`DictionaryWordPreviewDTO` = `id`/`spanishWord`/`mazahuaWord`/`imageUrl`/`audioUrl`/`pronunciation`): el tema es implícito en qué endpoint se llamó. `_fetchCategory` lo asigna explícitamente a cada palabra que llega sin él, porque `_saveToDb` persiste `w.category` y **no** la clave del mapa `wordsByCategory` — sin esa asignación, todo lo que venía de la red se guardaba con `category: ''` y el diccionario perdía sus categorías en el primer refresco de fondo. Si tocas `_fetchCategory` o `_saveToDb`, no lo reintroduzcas.

### Contenido multimedia

Sección `/explorar/contenido` (`ContentScreen`) + `/reproductor/:id`
(`MediaPlayerScreen`), mirror de `ContentSection.jsx`/`MediaPlayerView.jsx`.
**Solo online** (`README.md` lo documenta así, a diferencia del resto de la
app): sin conexión, `ContentScreen` muestra directamente un `EmptyState` de
"Necesitas conexión" — no hay caché de listado ni de media.

**`API_Documentation.md` está desactualizada en toda la sección `Media
Controller`** — no la uses como referencia para este endpoint sin
contrastarla contra `NtsiFiyo/.../dtos/playMedia/*.java`. El contrato real:

- `GET /api/media?type=&page=` responde `{"mediaList": [...]}`
  (`PlayMediaListMediaDTO`), **no** `{"content": [...]}` ni `{"media": [...]}`
  como documenta el markdown. `MediaService.PAGE_SIZE` está fijo en **10** en
  el backend y `size` en la query se ignora; el backend tampoco informa
  `totalPages`, así que la única señal de "última página" es que vuelva con
  menos de `mediaPageSize` elementos. `parseMediaList`
  (`lib/data/services/misc_services.dart`) lee `mediaList` como camino
  principal — leer `content` ahí fue el bug real que dejaba el panel
  siempre vacío, sin importar cuánta media hubiera en el backend.
- `GET /api/media/{id}/stream` responde `{"url", "espSubtitlesUrl",
  "mazSubtitlesUrl"}` (`PlayMediaStreamResourcesDTO`), nunca el `videoUrl` +
  `subtitles: [{language, url}]` que documenta el markdown, y el backend
  **no** envía subtítulos embebidos: los dos VTT siempre son URLs.

**Mazahua se muestra siempre; español es un interruptor explícito del
usuario** (`MediaPlayerController.toggleSpanish`), nunca al revés — nunca
inviertas ese default.

**La lógica del reproductor vive separada de la pantalla**, a propósito,
para poder incrustarla en una futura actividad `GameType.MEDIA` sin pasar
por `MediaService` ni por esta ruta:

- `lib/features/content/logic/vtt_parser.dart` — parser WebVTT puro, sin
  Flutter (`parseWebVtt`, `SubtitleTrack`, `SubtitleCue`), testeado en
  `test/vtt_parser_test.dart` igual que los generadores de
  `lib/features/games/logic/`. Trabaja en milisegundos completos, no en
  segundos truncados: un cue de menos de un segundo debe sobrevivir.
- `lib/features/content/player/media_playback_source.dart` —
  `MediaPlaybackSource`: qué reproducir (URL + subtítulos + poster + título),
  sin saber de dónde salió. Una actividad `MEDIA` construiría el suyo desde
  `GameData` en vez de pasar por `MediaService.getMediaStream`.
- `lib/features/content/player/media_player_controller.dart` —
  `MediaPlayerController extends ChangeNotifier`: reproduce, baja y
  sincroniza los VTT, sin Riverpod ni `BuildContext`. Es lo que se podría
  reutilizar tal cual dentro de una actividad.
- `lib/features/content/player/media_player_view.dart` — `MediaPlayerView`:
  widget de presentación puro (sin `Scaffold`/`AppBar`), consume un
  `MediaPlayerController`.
- `lib/features/content/media_player_screen.dart` es hoy el único
  envoltorio: resuelve `mediaId` → `MediaPlaybackSource` y gestiona la
  pantalla completa en horizontal para video, reutilizando
  `lib/shared/immersive_chrome.dart` (los mismos helpers que `MapScreen`,
  antes duplicados como `enterMapChrome`/`exitMapChrome`).

Las portadas de contenido (`CachedNetworkImage`) llevan `cacheKey:
mediaCacheKey(url)` por la misma razón que el resto de media de OCI — ver
«Media con token rotativo» en Offline-first arriba.

### Pronunciación (modelo ONNX en el dispositivo)

`assets/modelo/` trae los **dos únicos archivos** que hacen falta para inferir:
`validador_int8.onnx` (183 MB) y `centroides_y_config.json`. Se copian tal cual
de `App Mazahua/Mazahua/Audios Niños/modelo/` — el modelo desplegado. No metas
ahí `.pt`, `refs_dtw.npz` ni carpetas `respaldo_*`: no se usan y engordan el APK.

El contrato de entrada del modelo está escrito en
`App Mazahua/Mazahua/Audios Niños/ENTRADA_DE_AUDIO.md`. **Léelo antes de tocar
`lib/core/ai/preproceso_audio.dart`**, que es el port a Dart de `mazahua/comun.py`
y `mazahua/gate_voz.py`. Cuatro trampas, todas con su porqué:

- **La normalización media-cero/varianza-uno del backbone no es opcional, y
  quién la aplica lo decide el modelo**, no el cliente:
  `_meta.normalizacion_entrada` del JSON vale `"grafo"` (ya va dentro del ONNX,
  el cliente no debe aplicarla) o `"cliente"` (el ONNX no la trae). Ausente =
  grafo anterior al 2026-08-20, se asume `"cliente"`. Omitirla alimenta el
  backbone con RMS 0.1 en vez del `std=1` en que se calibró el umbral: medido
  sobre 240 clips, rechazaba al 49.2 % de las pronunciaciones **buenas** (frente
  al 95.8 % que acepta con ella) y duplicaba el EER. Aplicarla dos veces es
  igual de incorrecto.
- **El gate de voz va antes de normalizar el RMS.** Es la única comprobación de
  todo el sistema que depende del volumen absoluto (`rmsPicoMin = 0.02`), y es
  deliberado: sirve para distinguir «no hay nadie hablando» de «hay alguien
  hablando bajito». Normalizar primero amplifica el ruido de sala a nivel de voz
  y el gate deja pasar todo — fue la causa de 23 falsos positivos sobre 24
  buffers de ruido puro. Por eso el viejo `if (rms < 0.005)` sobre los 4 s
  completos no basta y ya no existe.
- **El recorte por energía usa un umbral relativo al pico (10 %), no absoluto.**
  Así un susurro y un grito se recortan en el mismo sitio fonético. Un umbral
  absoluto se come el principio de las palabras dichas bajito.
- **El umbral y las referencias no se mezclan.** El 0.2406 del JSON se calibró
  contra los *prototipos* de la cabeza AM-Softmax; el 0.3559 de `umbral.json` se
  calibró contra los *centroides* de la cabeza de tripletes. Intercambiarlos
  desplaza el punto de decisión sin que nada falle de forma visible.

Consecuencia de §5 del documento, útil para la UI: **el volumen no afecta al
veredicto** (la invariancia es exacta, no aproximada) mientras la señal no
sature. El niño que grita no falla por gritar, falla por recortar el micrófono.

`test/preproceso_audio_test.dart` cubre las cuatro trampas.

### Navegación

`StatefulShellRoute.indexedStack` con **4 ramas**: `/inicio` (camino de aprendizaje, `PathScreen`, con hijas `juegos` → `GamesHubScreen` y `juegos/:gameId` → `GameAccessScreen`), `/explorar` (`ExploreHubScreen`: elige entre mapa y contenido), `/palabras` (diccionario) y `/perfil` (antes "Inicio/Dashboard"; stats, asignaciones, acerca de, ajuste de tema — `ProfileScreen`, con hijas `asignaciones` y `acerca`).

`/games/:gameId/jugar` y `/reproductor/:id` cuelgan del navigator raíz (pantalla completa, sin bottom nav), igual que **`/explorar/mapa`**: aunque su ruta cuelga de `/explorar`, usa `parentNavigatorKey` para renderizarse en el navigator raíz.

La app está bloqueada en vertical desde `main()`. `MapScreen` es la excepción y **se administra a sí misma**: `initState`/`dispose` llaman a `enterMapChrome()`/`exitMapChrome()` (mismo archivo) para pasar a horizontal inmersivo, sin depender de en qué rama del shell viva — el `AppShell` ya no sabe nada del mapa.

### Modelos

El backend varía nombres de campo entre endpoints (`gameConfigDTO` vs `gameConfigs` vs `gameconfigs`, `id` vs `gameId`, `firstname` vs `firstName`). Todos los `fromJson` aceptan alias y usan los helpers `_asInt`/`_asBool` para tolerar strings. **Mantén esa tolerancia** al tocar los parsers; los tests de `widget_test.dart` la cubren.

`ResponseLog.toJson()` (persistencia local) incluye `wordText`; `toApiJson()` (payload del backend) no. No los mezcles.

## Base de datos

`schemaVersion` es 9 y sí hay `MigrationStrategy` (`onUpgrade` con un `if (from < N)` por versión). Si cambias una tabla de `app_database.dart`: corre `build_runner`, sube `schemaVersion` y añade tu propio bloque `if (from < N+1)` — **no reescribas los bloques anteriores**, o los usuarios que actualicen desde una versión vieja pierden su caché. Los tests usan `AppDatabase.forTesting(NativeDatabase.memory())`.

Tablas: `CachedGames` (contenido jugable offline, con `topic` y `mediaComplete`), `PendingResults` (cola de sincronización, con `attempts`), `KvEntries` (dashboards cacheados, y `games_bundle_seeded_at`), `CachedMedia` (binarios descargados, resueltos por `MediaStore`; `url` es la clave estable de `mediaCacheKey()`, `sourceUrl` la última URL absoluta con token PAR vigente — ver «Media con token rotativo» arriba), `CachedWords` (diccionario offline), `CompletedGames` (progreso local del camino de aprendizaje, ver arriba) y `ResourceUpdates` (punto de sincronización por recurso — `GAME`/`DICTIONARY` —: `syncCursor` es el `serverTime` que se reenvía como `since`, y las columnas `last*` son informativas; ver «Sincronización incremental en cada arranque» arriba).

## Tema (claro/oscuro)

`lib/app/palette.dart` define `AppPalette` (`ThemeExtension`) con los tokens de texto/superficie que sí cambian entre claro y oscuro (`context.palette.textMuted`, `.border`, `.surface`…). Los colores de **marca** (`AppColors.primary`, `.warning`, `.success`…) siguen siendo constantes — para que sigan siendo legibles en oscuro sin duplicar la paleta, los widgets que los reciben como parámetro (`KidCard.accentColor`, `KidButton.color`, `StatCard.color`…) los pasan por `adaptBrand(context, color)`, que sube la luminosidad conservando el tono. Si añades un widget nuevo con un color de acento, pásalo por `adaptBrand` en vez de usarlo tal cual.

`ThemeMode` sigue al sistema por defecto; el interruptor manual (Perfil) vive en `lib/features/settings/theme_controller.dart`, persistido en `shared_preferences`.

**Presupuesto de profundidad**: la sombra dura y el borde de 4px de `KidCard` (estilo kid-3D) solo se dibujan cuando `onTap != null`; sin `onTap` baja a borde de 1.5px y sombra difusa mínima. Antes de añadir sombra dura a un widget nuevo, pregúntate si es pulsable — si no lo es, no la lleva.

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
