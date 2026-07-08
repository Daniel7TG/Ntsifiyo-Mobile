import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/models.dart';

class LoginResult {
  final AppUser user;
  final String token;
  final Map<String, dynamic> raw;

  const LoginResult({required this.user, required this.token, required this.raw});
}

/// Mirror de client/src/services/AuthService.js + GoogleAuthService.js
/// (solo estudiante y visitante).
class AuthService {
  final ApiClient _api;
  AuthService(this._api);

  /// POST /api/auth/login/student — {listNumber, password, grade}
  Future<LoginResult> loginStudent({
    required int listNumber,
    required String password,
    required int grade,
  }) async {
    final response = await _api.post('/api/auth/login/student', {
      'listNumber': listNumber,
      'password': password,
      'grade': grade,
    });
    return _toLoginResult(response, Roles.student);
  }

  /// POST /api/auth/login/visitor — {username, password}
  Future<LoginResult> loginVisitor({
    required String username,
    required String password,
  }) async {
    final response = await _api.post('/api/auth/login/visitor', {
      'username': username,
      'password': password,
      'grade': null,
    });
    return _toLoginResult(response, Roles.visitor);
  }

  /// POST /api/auth/visitor — registro de visitante (requiere verificación email).
  Future<void> registerVisitor({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String username,
  }) async {
    await _api.post('/api/auth/visitor', {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'username': username,
    });
  }

  /// POST /api/auth/oauth2/google — intercambia idToken de Google por JWT.
  /// Lanza ApiException con status 404/409 si el usuario aún no está registrado
  /// (el flujo web abre entonces el modal de registro).
  Future<LoginResult> loginWithGoogle(String idToken) async {
    final response =
        await _api.post('/api/auth/oauth2/google', {'idToken': idToken});
    return _toLoginResult(response, Roles.visitor);
  }

  /// POST /api/auth/oauth2/google/register — completa registro con Google.
  Future<LoginResult> registerWithGoogle({
    required String idToken,
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _api.post('/api/auth/oauth2/google/register', {
      'idToken': idToken,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'username': username,
    });
    return _toLoginResult(response, Roles.visitor);
  }

  LoginResult _toLoginResult(dynamic response, String role) {
    final map = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final token = (map['jwtToken'] ?? '') as String;
    if (token.isEmpty) {
      throw ApiException('El servidor no devolvió un token de sesión.');
    }
    // La web arma appUser con firstname/lastname/userType (AuthPage.onSuccess);
    // algunos logins anidan los datos en `user`.
    final userMap = map['user'] is Map<String, dynamic>
        ? map['user'] as Map<String, dynamic>
        : map;
    final user = AppUser(
      firstname:
          (userMap['firstname'] ?? userMap['firstName'] ?? '') as String,
      lastname: (userMap['lastname'] ?? userMap['lastName'] ?? '') as String,
      userType: role,
    );
    return LoginResult(user: user, token: token, raw: map);
  }
}

final authServiceProvider = Provider<AuthService>(
    (ref) => AuthService(ref.watch(apiClientProvider)));
