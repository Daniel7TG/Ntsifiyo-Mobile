import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jnatrjo_mobile/app/theme.dart';
import 'package:jnatrjo_mobile/core/api/api_client.dart';
import 'package:jnatrjo_mobile/core/storage/session_store.dart';
import 'package:jnatrjo_mobile/data/services/activity_service.dart';
import 'package:jnatrjo_mobile/features/home/home_carousel.dart';
import 'package:jnatrjo_mobile/features/home/home_providers.dart';
import 'package:jnatrjo_mobile/features/auth/auth_controller.dart';
import 'package:jnatrjo_mobile/data/models/models.dart';

class VisitorAuth extends AuthController {
  @override
  AppUser? build() =>
      const AppUser(firstname: 'V', lastname: '', userType: 'VISITOR');
}

class AssignmentApi extends ApiClient {
  AssignmentApi() : super(SessionStore(const FlutterSecureStorage()));
  @override
  Future<dynamic> get(String endpoint) async => [
    {
      'id': 123,
      'title': 'Colores',
      'gameType': 'MEMORY_GAME',
      'experience': 100,
    },
  ];
}

void main() {
  test('visitante no solicita tareas ni abre la base local', () async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(VisitorAuth.new),
        homeAccountProvider.overrideWithValue('v'),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(homeAssignmentProvider.future), null);
  });
  test(
    'lista de asignaciones mantiene el id de actividad y normaliza paginación',
    () async {
      final data = await ActivityService(
        AssignmentApi(),
      ).getStudentActivities();
      expect((data['content'] as List).single['id'], 123);
      expect(data['totalPages'], 1);
      expect(data['last'], true);
    },
  );
  testWidgets('recorrido automático, pausa y movimiento reducido', (
    tester,
  ) async {
    var reduce = false;
    final router = GoRouter(
      initialLocation: '/inicio',
      routes: [
        GoRoute(
          path: '/inicio',
          builder: (_, _) => Scaffold(
            body: HomeCarousel(
              items: [
                for (var i = 0; i < 2; i++)
                  HomeSuggestion(
                    id: '$i',
                    badge: 'APRENDE',
                    title: 'Tarjeta $i',
                    subtitle: 'Una aventura',
                    action: 'Comenzar',
                    image: 'assets/home/mapa-juego.webp',
                    color: Colors.green,
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    Future<void> mount() => tester.pumpWidget(
      MaterialApp.router(
        theme: buildAppTheme(Brightness.light),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
          child: child!,
        ),
      ),
    );
    await mount();
    await tester.pump();
    expect(find.text('Tarjeta 0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 4800));
    await tester.pump(const Duration(milliseconds: 1250));
    expect(find.text('Tarjeta 1'), findsOneWidget);
    await tester.tap(find.byTooltip('Pausar recorrido'));
    await tester.pump(const Duration(seconds: 8));
    expect(find.text('Tarjeta 1'), findsOneWidget);
    reduce = true;
    await mount();
    await tester.pump();
    await tester.tap(find.byTooltip('Siguiente tarjeta'));
    await tester.pump();
    expect(find.text('Tarjeta 0'), findsOneWidget);
    await tester.pump(const Duration(seconds: 8));
    expect(find.text('Tarjeta 0'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
