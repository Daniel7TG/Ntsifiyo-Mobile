import 'package:google_sign_in/google_sign_in.dart';

/// Client ID web del proyecto de Google Cloud (mismo que usa la web en
/// GoogleAuthService.js). Se usa como serverClientId para que el idToken
/// tenga el audience que el backend ya valida.
const _webClientId =
    '622374183056-384df8mr97gsn1f0mla31g1m297d6ugk.apps.googleusercontent.com';

class GoogleAccountInfo {
  final String idToken;
  final String email;
  final String displayName;

  const GoogleAccountInfo({
    required this.idToken,
    required this.email,
    required this.displayName,
  });
}

/// Envuelve google_sign_in v7 para obtener el idToken que espera el backend.
class GoogleSignInHelper {
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
    _initialized = true;
  }

  /// Abre el flujo de Google y devuelve el idToken + datos básicos.
  /// Devuelve null si el usuario cancela.
  static Future<GoogleAccountInfo?> signIn() async {
    await _ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return null;
      return GoogleAccountInfo(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName ?? '',
      );
    } on GoogleSignInException {
      // Usuario canceló o falló el flujo nativo.
      return null;
    }
  }

  /// Evita que Google reseleccione la cuenta tras cerrar sesión
  /// (equivalente a disableAutoSelect de la web).
  static Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}
