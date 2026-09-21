import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/palette.dart';
import '../../../app/theme.dart';

class SenderoDestination {
  final String svgAsset;
  final String svgAssetSelected;
  final String label;

  const SenderoDestination({
    required this.svgAsset,
    required this.svgAssetSelected,
    required this.label,
  });
}

/// Barra inferior de 4 destinos, en píldora kid-card con sombra dura —
/// el destino activo se pinta como una tarjeta propia dentro de la barra,
/// en vez del subrayado/indicador plano de Material `NavigationBar`.
class SenderoNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<SenderoDestination> destinations;

  const SenderoNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: palette.border, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: palette.shadowNeutral,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _NavItem(
                      destination: destinations[i],
                      selected: i == selectedIndex,
                      onTap: () {
                        if (i != selectedIndex) {
                          HapticFeedback.selectionClick();
                        }
                        onDestinationSelected(i);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final SenderoDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                selected ? destination.svgAssetSelected : destination.svgAsset,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  selected ? AppColors.primary : context.palette.textMuted,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? AppColors.primary
                      : context.palette.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
