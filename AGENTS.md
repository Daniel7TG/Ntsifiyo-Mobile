# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

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

- `lib/core/` — infraestructura: `api/` (dio + interceptor JWT + `ApiException` con mensajes en español, `error_messages.dart` los traduce a texto legible para la UI), `storage/` (drift + `SessionStore` sobre secure storage + `MediaStore` para binarios descargados), `sync/` (offline), `connectivity/`.
- `lib/data/` — `models/models.dart` (todos los DTOs en un archivo) y `services/` (una clase por servicio de la web).
- `lib/app/` — `router.dart`, `theme.dart` + `palette.dart` (tema claro/oscuro), `activity_config.dart`, `learning_path.dart` (unidades del camino de aprendizaje).
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

### Camino de aprendizaje (Inicio)

`PathScreen` muestra las unidades de `lib/app/learning_path.dart` (mismos `topic` que ya consume `ActivityService.getGamesByTopic`) en un orden fijo, con estado completada/actual/bloqueada.

**El backend no expone progreso por tema** (`completed`/`locked`/`order` no existen en ningún DTO), así que ese estado es una **inferencia 100% local**: la tabla `CompletedGames` de drift registra cada partida terminada con su `topic` (leído de `CachedGames.topic`, que ya se guarda al iniciar el juego). No viaja entre dispositivos ni sobrevive a una reinstalación — si el backend algún día expone un endpoint de progreso, solo hay que cambiar la fuente de `lib/features/path/path_providers.dart`, la UI no se entera.

### Diccionario

`DictionaryController` emite **al instante** la copia local y refresca en segundo plano. Fuentes, en orden: disco (`dictionary_cache.json`) → snapshot empaquetado en `assets/dictionary/manifest.json` → red. Además, `_applyBundleMedia` sustituye `imageUrl`/`audioUrl` por assets del bundle siempre que la palabra exista en él (match por `id`), aunque los datos vengan de la red: carga inmediata y sin tráfico. Solo las palabras nuevas usan URL remota.

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

`schemaVersion` es 3 y sí hay `MigrationStrategy` (`onUpgrade` con un `if (from < N)` por versión). Si cambias una tabla de `app_database.dart`: corre `build_runner`, sube `schemaVersion` y añade tu propio bloque `if (from < N+1)` — **no reescribas los bloques anteriores**, o los usuarios que actualicen desde una versión vieja pierden su caché. Los tests usan `AppDatabase.forTesting(NativeDatabase.memory())`.

Tablas: `CachedGames` (contenido jugable offline, con `topic` y `mediaComplete`), `PendingResults` (cola de sincronización, con `attempts`), `KvEntries` (dashboards cacheados), `CachedMedia` (binarios descargados, resueltos por `MediaStore`), `CachedWords` (diccionario offline) y `CompletedGames` (progreso local del camino de aprendizaje, ver arriba).

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
     OJO: `graphify Codex install` la sobrescribe con el bloque estándar en
     inglés. Si actualizas graphify y reinstalas, vuelve a traducirla. -->

Este proyecto tiene un grafo de conocimiento en `graphify-out/` (código + docs) con god nodes, comunidades y relaciones entre archivos.

Reglas:

- **Antes de responder preguntas sobre el código**, corre `graphify query "<pregunta>"` si existe `graphify-out/graph.json`. Devuelve un subgrafo acotado, mucho más barato que `GRAPH_REPORT.md` o que rastrear con grep.
- **Antes de cualquier refactor**, corre `graphify affected "<X>"`. Hace traversal inverso y dice qué se rompe de verdad, no coincidencias de texto. Especialmente útil con los puntos de cambio acoplados: añadir un juego toca `activityConfig`, el `switch` de `GamePlayScreen`, la vista en `features/games/views/` y `playableGameTypes` a la vez.
- `graphify path "<A>" "<B>"` para trazar un flujo entre dos conceptos; `graphify explain "<X>"` para entender un nodo puntual.
- Lee `graphify-out/GRAPH_REPORT.md` solo para revisión arquitectónica amplia, o cuando query/path/explain no den suficiente contexto.
- **Tras modificar código**: `graphify update .` (solo AST, sin coste de LLM). El hook de post-commit ya lo hace automáticamente en cada commit.
- **Tras modificar documentación** (`AGENTS.md`, `README.md`, `pubspec.yaml`): `/graphify . --update`. Esto sí re-extrae con LLM.

Alcance del grafo (importante para no sacar conclusiones falsas):

- Cubre los 68 archivos de código y los 5 docs. Los ~370 assets del diccionario (imágenes `.webp` y audio `.mp3`) se excluyeron a propósito: son carga de datos, no arquitectura.
- Los ~1019 nodos aislados que reporta son en su mayoría claves del `manifest.json` del diccionario y campos sueltos de DTOs. Es ruido esperado, **no** deuda arquitectónica.
- El matcher de `query` es substring sobre etiquetas de nodo, sin stemming ni sinónimos. Usa nombres reales (`gameSessionProvider`, `SyncService`, `AppDatabase`, `DictionaryController`) en vez de descripciones vagas.
