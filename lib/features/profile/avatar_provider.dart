import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/user_service.dart';

/// Provider del avatarId del usuario autenticado.
///
/// Carga el avatar del backend y lo almacena en caché local
/// (shared_preferences) para funcionamiento offline.
class AvatarController extends AsyncNotifier<int> {
  static const _cacheKey = 'user_avatar_id';

  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getInt(_cacheKey);

    try {
      final service = ref.read(userServiceProvider);
      final avatarId = await service.getAvatar();
      await prefs.setInt(_cacheKey, avatarId);
      return avatarId;
    } catch (_) {
      return cached ?? 0;
    }
  }

  /// Actualiza el avatar en el backend y refresca el estado local.
  Future<void> updateAvatar(int avatarId) async {
    final service = ref.read(userServiceProvider);
    final saved = await service.updateAvatar(avatarId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheKey, saved);
    state = AsyncData(saved);
  }
}

final avatarControllerProvider =
    AsyncNotifierProvider<AvatarController, int>(
  AvatarController.new,
);
