import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/avatar_config.dart';
import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../shared/widgets/avatar_circle.dart';
import '../../shared/widgets/kid_card.dart';
import 'avatar_provider.dart';

/// Abre el selector de avatar como un bottom sheet interactivo.
Future<void> showAvatarPickerSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const _AvatarPickerContent(),
  );
}

class _AvatarPickerContent extends ConsumerStatefulWidget {
  const _AvatarPickerContent();

  @override
  ConsumerState<_AvatarPickerContent> createState() =>
      __AvatarPickerContentState();
}

class __AvatarPickerContentState extends ConsumerState<_AvatarPickerContent> {
  int? _selectedId;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final avatarState = ref.watch(avatarControllerProvider);
    final currentAvatarId = avatarState.value ?? 0;
    final activeId = _selectedId ?? currentAvatarId;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.palette.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Elige tu Avatar',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: context.palette.textMain,
            ),
          ),
          Text(
            'Selecciona el personaje que te representará en la app',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.palette.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Vista previa del avatar seleccionado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: AvatarCircle(
              avatarId: activeId,
              radius: 46,
              ring: true,
              ringColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Grid de 20 avatares (4 columnas x 5 filas)
          Flexible(
            child: SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: avatarCount,
                itemBuilder: (context, index) {
                  final isSelected = index == activeId;
                  final isCurrent = index == currentAvatarId;

                  return InkWell(
                    onTap: _saving
                        ? null
                        : () {
                            setState(() {
                              _selectedId = index;
                            });
                          },
                    borderRadius: BorderRadius.circular(36),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isCurrent
                                  ? AppColors.warning
                                  : Colors.transparent,
                          width: isSelected ? 3 : 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AvatarCircle(
                            avatarId: index,
                            radius: 28,
                            ring: false,
                          ),
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.25),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Botón de guardar
          KidButton(
            label: _saving ? 'Guardando...' : 'Guardar avatar',
            icon: Icons.check,
            expanded: true,
            loading: _saving,
            onPressed: (_selectedId == null || _selectedId == currentAvatarId)
                ? () => Navigator.pop(context)
                : () async {
                    setState(() => _saving = true);
                    try {
                      await ref
                          .read(avatarControllerProvider.notifier)
                          .updateAvatar(_selectedId!);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Avatar actualizado con éxito!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al cambiar avatar: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
