import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/models.dart';

/// Sesión persistente (equivalente a authToken/appUser en localStorage web),
/// guardada en almacenamiento seguro de Android.
class SessionStore {
  static const _tokenKey = 'authToken';
  static const _userKey = 'appUser';

  final FlutterSecureStorage _storage;

  String? _token;
  AppUser? _user;

  SessionStore(this._storage);

  String? get token => _token;
  AppUser? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;

  /// Carga la sesión guardada antes de arrancar la UI.
  Future<void> load() async {
    _token = await _storage.read(key: _tokenKey);
    final rawUser = await _storage.read(key: _userKey);
    if (rawUser != null) {
      try {
        _user = AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
      } catch (_) {
        _user = null;
      }
    }
  }

  Future<void> save(AppUser user, String token) async {
    _user = user;
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    _user = null;
    _token = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}

/// Se sobreescribe en main() con la instancia ya cargada.
final sessionStoreProvider = Provider<SessionStore>((ref) {
  throw UnimplementedError('sessionStoreProvider debe inicializarse en main');
});
