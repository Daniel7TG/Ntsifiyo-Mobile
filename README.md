# Jñatrjo Móvil

App Android en Flutter para aprender mazahua jugando. Versión móvil de la
plataforma web (repo `J-atrjo`), solo para **estudiantes y visitantes**.

## Características

- **10 juegos**: Quiz, El Intruso, Completar Oración, Memorama, Memoria
  Rápida, Pares, Lotería, Laberinto, Tripas del Gato y Sopa de Letras.
- **Mapa de aventuras** por zonas (escuela, cocina, granja, mercado…).
- **Diccionario mazahua-español** con imágenes y audio, 100% offline
  (snapshot empaquetado en la app).
- **Contenido multimedia**: canciones, leyendas, anécdotas y poemas con
  subtítulos bilingües (solo online).
- **XP y niveles** sincronizados con el mismo backend de la web.
- **Modo offline**: los juegos se cachean en la primera conexión y son
  jugables sin internet; los resultados se encolan y se sincronizan al
  reconectar (con resumen de XP y nivel ganados).

## Requisitos

- Flutter 3.44+ (canal stable)
- Android SDK (minSdk 23)

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # codegen drift
flutter analyze
flutter test
flutter run                        # dispositivo/emulador Android
flutter build apk --release
```

Backend configurable con `--dart-define=API_URL=https://...`
(default: producción en Koyeb, el mismo que usa la web).

## Diccionario offline

El snapshot del diccionario vive en `assets/dictionary/`. Para regenerarlo:

```bash
pip install requests pillow
python scripts/export_dictionary.py --token <JWT>
```

(El JWT se obtiene iniciando sesión en la web y copiando
`localStorage.authToken`.)

## Arquitectura

- **Estado**: Riverpod. **Navegación**: go_router. **HTTP**: dio con
  interceptor JWT (mirror de `apiConfig.js` de la web).
- **Persistencia**: drift (caché de juegos + cola de sincronización),
  flutter_secure_storage (sesión), snapshot de diccionario en assets.
- **Sincronización offline** (`lib/core/sync/`): por cada actividad jugada
  sin conexión → `POST /api/activities/start/game/{gameId}` (activityId
  fresco) → `POST /api/activities/complete` con los resultados guardados;
  al terminar muestra un resumen con XP por actividad, XP total y cambio
  de nivel.
- **Estilo**: sistema "kid" 3D de la web (tarjetas blancas con sombra dura
  y borde grueso), paleta naranja `#E65100` / azul `#1E3A8A` / degradado
  menta→crema, tipografías Poppins + Public Sans empaquetadas.

## Login

- **Estudiante**: grado (1º–6º) + número de lista + contraseña.
- **Visitante**: usuario + contraseña, registro con verificación por email,
  o Google Sign-In.

## Pendientes / notas

- Google Sign-In usa el client ID web como `serverClientId`; si el backend
  rechaza el audience, registrar un client ID Android en el mismo proyecto
  de Google Cloud.
- Firma de release: actualmente usa el keystore de debug; generar keystore
  propio antes de publicar en Play Store.
- La verificación de email abre el enlace en el navegador (deep links v2).
