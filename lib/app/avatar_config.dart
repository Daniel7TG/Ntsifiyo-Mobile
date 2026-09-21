/// Configuración de avatares — mirror de client/src/config/avatars.js.
///
/// El backend guarda `avatarId` 0..19; los archivos se llaman
/// avatar_1..avatar_20 (1-indexados). avatarId N ⇄ avatar_{N + 1}.
library;

/// Cantidad de avatares disponibles.
const int avatarCount = 20;

/// Rango válido de avatarId (0-indexado).
bool isValidAvatarId(int? id) => id != null && id >= 0 && id < avatarCount;

/// avatarId (0-indexado) → asset path del .webp.
String avatarAssetPath(int avatarId) {
  final safe = isValidAvatarId(avatarId) ? avatarId : 0;
  return 'assets/avatars/avatar_${safe + 1}.webp';
}
