import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/storage/session_store.dart';
import '../../data/models/models.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/misc_services.dart';

/// Estado de autenticación de la app (equivalente a AuthContext de la web).
class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() => ref.read(sessionStoreProvider).user;

  SessionStore get _session => ref.read(sessionStoreProvider);
  AuthService get _auth => ref.read(authServiceProvider);

  bool get isAuthenticated => state != null;

  Future<void> loginStudent({
    required int listNumber,
    required String password,
    required int grade,
  }) async {
    final result = await _auth.loginStudent(
        listNumber: listNumber, password: password, grade: grade);
    await _commit(result);
  }

  Future<void> loginVisitor({
    required String username,
    required String password,
  }) async {
    final result =
        await _auth.loginVisitor(username: username, password: password);
    await _commit(result);
  }

  Future<void> loginWithGoogle(String idToken) async {
    final result = await _auth.loginWithGoogle(idToken);
    await _commit(result);
  }

  Future<void> registerWithGoogle({
    required String idToken,
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String username,
  }) async {
    final result = await _auth.registerWithGoogle(
      idToken: idToken,
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
      username: username,
    );
    await _commit(result);
  }

  Future<void> _commit(LoginResult result) async {
    await _session.save(result.user, result.token);
    state = result.user;
    // Registrar inicio de sesión de uso (como la web tras login).
    await ref.read(userSessionServiceProvider).startSession();
  }

  Future<void> logout() async {
    await ref.read(userSessionServiceProvider).endSession();
    await _session.clear();
    state = null;
  }

  /// Renueva la sesión al arrancar y al recuperar conexión
  /// (`POST /api/auth/refresh`). Solo un rechazo explícito del servidor la
  /// cierra — la app es offline-first, y expulsar a quien está jugando sin
  /// internet sería peor que dejarle el token vencido hasta que vuelva a
  /// haber red:
  ///   200      → guardar el token nuevo, la sesión sigue igual.
  ///   401/403  → logout. El backend devuelve 403 sin body para un JWT
  ///              expirado (`SecurityConfig` no declara
  ///              `AuthenticationEntryPoint`), así que 403 cuenta igual que
  ///              401 aquí.
  ///   404/405  → el endpoint aún no está desplegado: conservar la sesión.
  ///   sin red / otro fallo → conservar y reintentar en el próximo arranque
  ///              o al recuperar conexión (`AppShell`, listener de
  ///              `connectivityStreamProvider`).
  Future<void> renewSession() async {
    final user = state;
    if (user == null) return;
    try {
      final newToken = await _auth.refreshToken();
      await _session.save(user, newToken);
    } on ApiException catch (e) {
      if (e.status == 401 || e.status == 403) {
        await logout();
      }
      // 404/405 u otro status: el servidor no rechazó la sesión, se
      // conserva tal cual.
    } catch (_) {
      // Sin red u otro fallo de transporte: se conserva y se reintenta más
      // tarde, nunca se cierra sesión por esto.
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AppUser?>(AuthController.new);
