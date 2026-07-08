import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

final authControllerProvider =
    NotifierProvider<AuthController, AppUser?>(AuthController.new);
