import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jnatrjo_mobile/app/theme.dart';
import 'package:jnatrjo_mobile/core/connectivity/connectivity_service.dart';
import 'package:jnatrjo_mobile/data/models/daily_pronunciation.dart';
import 'package:jnatrjo_mobile/data/models/models.dart';
import 'package:jnatrjo_mobile/features/auth/auth_controller.dart';
import 'package:jnatrjo_mobile/features/home/home_screen.dart';
import 'package:jnatrjo_mobile/features/home/home_providers.dart';
import 'package:jnatrjo_mobile/features/progress/progress_providers.dart';

class TestAuth extends AuthController {
  final bool student;
  TestAuth(this.student);
  @override
  AppUser? build() => AppUser(
    firstname: 'Ana',
    lastname: '',
    userType: student ? 'STUDENT' : 'VISITOR',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('CAPTURE_HOME')) {
      for (final entry in {
        'Poppins': [
          'Poppins-Regular.ttf',
          'Poppins-SemiBold.ttf',
          'Poppins-Bold.ttf',
          'Poppins-ExtraBold.ttf',
          'Poppins-Black.ttf',
        ],
        'PublicSans': ['PublicSans-VariableFont.ttf'],
      }.entries) {
        final loader = FontLoader(entry.key);
        for (final file in entry.value) {
          loader.addFont(rootBundle.load('assets/fonts/$file'));
        }
        await loader.load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });
  for (final width in [320.0, 390.0, 800.0]) {
    for (final scale in [1.0, 1.8]) {
      testWidgets('Inicio sin recortes a $width px, texto $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final boundaryKey = GlobalKey();
        final router = GoRouter(
          initialLocation: '/inicio',
          routes: [
            GoRoute(
              path: '/inicio',
              builder: (_, _) => RepaintBoundary(
                key: boundaryKey,
                child: const GradientBackground(child: HomeScreen()),
              ),
            ),
            GoRoute(
              path: '/inicio/juegos',
              builder: (_, _) =>
                  const Scaffold(body: Text('Catálogo conservado')),
            ),
          ],
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authControllerProvider.overrideWith(() => TestAuth(true)),
              homeGameProvider.overrideWith(
                (ref) async => const GameSummaryDto(
                  id: 1,
                  title: 'Sopa de letras de frutas silvestres',
                  gameType: 'WORD_SEARCH',
                ),
              ),
              homeAssignmentProvider.overrideWith(
                (ref) async => {
                  'id': 2,
                  'title': 'Colores',
                  'gameType': 'MEMORY_GAME',
                },
              ),
              homeMediaProvider.overrideWith((ref) async => null),
              isOnlineProvider.overrideWithValue(false),
              totalProgressProvider.overrideWithValue(
                const ZoneProgress(earnedStars: 24, possibleStars: 80),
              ),
              practiceWordsProvider.overrideWith((ref) async => []),
              dailyChallengeProvider.overrideWith(
                (ref) => Stream.value(
                  DailyChallenge(
                    id: 1,
                    word: const Word(
                      id: 5,
                      spanishWord: 'abeja',
                      mazahuaWord: 'ngïnï',
                    ),
                    startsAt: DateTime.now().subtract(const Duration(hours: 1)),
                    expiresAt: DateTime.now().add(const Duration(hours: 1)),
                    pending: true,
                  ),
                ),
              ),
            ],
            child: MaterialApp.router(
              theme: buildAppTheme(Brightness.dark),
              routerConfig: router,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('¿Qué hacemos hoy?'), findsOneWidget);
        if (const bool.fromEnvironment('CAPTURE_HOME') &&
            width == 390 &&
            scale == 1) {
          await tester.tap(find.byTooltip('Pausar recorrido'));
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final boundary =
                boundaryKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await File(
              '/tmp/jnatrjo-flutter-home.png',
            ).writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Siguiente tarjeta'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1250));
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('TU AVENTURA'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.textContaining('Sin conexión: tu resultado'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Todos los juegos'));
        await tester.pumpAndSettle();
        expect(find.text('Catálogo conservado'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
      });
    }
  }
}
