# Inicio y pronunciación diaria

La ruta `/inicio` muestra el carrusel «¿Qué hacemos hoy?», el reto de
pronunciación y el progreso «Tu aventura», en ese orden. El catálogo sigue
disponible desde el botón de cuadrícula «Todos los juegos» (`/inicio/juegos`).

El carrusel usa los cinco dibujos aprobados del prototipo, copiados a
`assets/home/`. Recomienda un juego disponible y pendiente del mapa, una
asignación pendiente si la cuenta es estudiante, contenido de audio real,
pronunciación libre y diccionario. Omite recomendaciones sin datos. Conserva
las fuentes, colores adaptados al tema y componentes de la aplicación.
Avanza tras 4,8 segundos con retroceso e impulso; admite gestos, indicadores,
flechas y pausa. Detiene el recorrido fuera del inicio, en segundo plano,
al salir del área visible y cuando el sistema pide reducir animaciones.

## Contrato del reto

El backend hermano `../NtsiFiyo` incorpora estos endpoints autenticados
(versión API `1.0.0`):

| Método y ruta | Cuerpo | Resultado |
| --- | --- | --- |
| `POST /api/pronunciation/daily/start` | `{"supportedWordIds":[5,6]}` | Reto de hoy; una asignación estable por cuenta y fecha |
| `POST /api/pronunciation/daily/{id}/complete` | `{"accepted":true,"completedAt":"2026-09-21T18:30:00Z"}` | Reto completado y recompensa confirmada |

El reto devuelve `id`, `type: daily_pronunciation`, `date`, `startsAt`,
`expiresAt`, `word: {id, spanishWord, mazahuaWord}`, `completed`,
`experience: 100` y `reward` (nulo salvo al completar).
`reward` conserva el contrato existente: `xpGained`, `actualXp`,
`currentLevel`, `isLevelUp`.

La fecha cambia a medianoche en `America/Mexico_City`. Solo abrir el reto
asigna una palabra: los días sin abrirlo no consumen palabras. La selección
aleatoria excluye las ya asignadas en la vuelta actual; una vuelta nueva
comienza al agotar las palabras compatibles disponibles. La elegibilidad
cruza los identificadores soportados por la app con el diccionario y los
centroides del backend. Con más de una palabra se evita repetir la última
al cambiar de vuelta.

La aplicación envía la finalización únicamente tras un veredicto local
`PronunciationStatus.correct`. El contrato confía en ese veredicto del
cliente; no envía ni guarda audio en el backend. No cambia el modelo ONNX
ni el preprocesamiento. Los intentos no aceptados pueden repetirse.

El servidor valida cuenta, rol, pertenencia del reto y fecha del intento.
Concede 100 XP una sola vez, dentro de una transacción que bloquea la fila
de la cuenta. Repetir la petición devuelve `xpGained: 0` y el total actual.
La finalización de juegos usa el mismo bloqueo para no perder XP por
actualizaciones simultáneas de juegos y retos diarios.

## Sin conexión

Un reto descargado y aún vigente puede completarse sin conexión. Si todavía
no existe una asignación guardada, el APK crea una asignación local a partir
del diccionario y los centroides incluidos. La palabra queda disponible para
practicar y su identificador negativo indica que aún no fue emitida por el
servidor. El resultado aceptado se persiste antes de enviarlo, separado por
cuenta y por reto. No se incrementa XP localmente. Se muestra:

> Sin conexión: tu resultado quedó guardado. La XP se agregará cuando recuperes la conexión y se sincronice.

El resumen de partidas sin conexión usa el mismo aviso. Al reconectar,
la cola enlaza una asignación local con el reto diario del servidor y muestra
la recompensa confirmada. Las respuestas perdidas pueden reenviarse sin
duplicar XP. Los retos emitidos originalmente por el servidor conservan su
fecha de finalización; una asignación creada completamente offline se
confirma al momento de enlazarla, porque el servidor no conocía su `issuedAt`.
Los rechazos explícitos muestran el error, y los permanentes dejan de
reintentarse automáticamente. Una cuenta nunca envía pendientes de otra.

Drift pasa de esquema 10 a 11 y añade `PendingDailyResults`, conservando
las migraciones y tablas anteriores. El caché del reto vive en `KvEntries`
con clave `daily_pronunciation:<cuenta>`.

## Despliegue

1. Aplicar al PostgreSQL del backend
   `src/main/resources/db/migration/V5__daily_pronunciation.sql`.
   El repositorio administra estos scripts manualmente: no hay un ejecutor
   Flyway y `ddl-auto` no crea la tabla. El script es repetible.
2. Desplegar el backend con `DailyPronunciationController`, servicio,
   entidad/repositorio y bloqueo de recompensas en `ActivityService`.
3. Distribuir el APK. Si el backend aún no tiene el endpoint, la app muestra
   el estado de reto no disponible y permite practicar libremente.

No se ha ejecutado esta migración ni desplegado el servicio en producción.

## Validación reproducible

```bash
flutter analyze --no-pub
flutter test test/daily_pronunciation_test.dart test/home_screen_test.dart test/home_behavior_test.dart test/sync_queue_test.dart test/progress_test.dart
flutter test test/home_screen_test.dart --dart-define=CAPTURE_HOME=true
flutter build apk --debug
```

La captura opcional carga las fuentes reales y escribe
`/tmp/jnatrjo-flutter-home.png`. Las pruebas cubren anchos de 320, 390 y
800 píxeles, texto ampliado, navegación, pausa, movimiento reducido,
persistencia, migración y reintentos sin duplicación.

En el backend:

```bash
./gradlew test --tests '*DailyPronunciationServiceTest' --tests '*ActivityServiceXpTest'
# Solo con una base PostgreSQL LOCAL y DESECHABLE:
DAILY_TEST_JDBC_URL=jdbc:postgresql://127.0.0.1:55439/postgres ./gradlew test --tests '*DailyPronunciationConcurrencyTest'
```

La prueba opcional crea y elimina tablas de prueba. Comprueba con PostgreSQL
real la migración, las restricciones y dos confirmaciones concurrentes que
solo acreditan 100 XP en total. No debe apuntar a una base con datos.
