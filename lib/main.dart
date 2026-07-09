import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/storage/session_store.dart';
import 'data/services/misc_services.dart';
import 'features/auth/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // La app vive en vertical; solo el mapa cambia a horizontal.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Cargar la sesión guardada antes de decidir la pantalla inicial.
  final sessionStore = SessionStore(const FlutterSecureStorage());
  await sessionStore.load();

  runApp(
    ProviderScope(
      overrides: [
        sessionStoreProvider.overrideWithValue(sessionStore),
      ],
      child: const JnatrjoApp(),
    ),
  );
}

class JnatrjoApp extends ConsumerStatefulWidget {
  const JnatrjoApp({super.key});

  @override
  ConsumerState<JnatrjoApp> createState() => _JnatrjoAppState();
}

class _JnatrjoAppState extends ConsumerState<JnatrjoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Registrar inicio de sesión de uso si ya había sesión guardada.
    if (ref.read(authControllerProvider) != null) {
      ref.read(userSessionServiceProvider).startSession();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Mirror del beforeunload de la web: cerrar/reabrir sesión de uso
  /// cuando la app pasa a segundo plano o regresa.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (ref.read(authControllerProvider) == null) return;
    final sessions = ref.read(userSessionServiceProvider);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        sessions.endSession();
      case AppLifecycleState.resumed:
        sessions.startSession();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Jñatrjo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
      builder: (context, child) => GradientBackground(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
