import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/storage/session_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class JnatrjoApp extends ConsumerWidget {
  const JnatrjoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
