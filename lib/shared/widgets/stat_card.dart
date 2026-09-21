import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/palette.dart';
import 'kid_card.dart';

/// Tarjeta de estadística (mirror de StatCard.jsx) adaptada a móvil.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subText;
  final IconData icon;
  final Color color;

  /// Si se pasa, sustituye a [icon] (por ejemplo, un SVG propio de racha/XP
  /// en vez del Material Icon genérico).
  final String? svgAsset;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.subText,
    required this.icon,
    required this.color,
    this.svgAsset,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final adapted = adaptBrand(context, color);
    return Semantics(
      label: '$label: $value, $subText',
      child: KidCard(
        accentColor: color,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: adapted.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: svgAsset != null ? const EdgeInsets.all(8) : null,
                  child: svgAsset != null
                      ? SvgPicture.asset(svgAsset!,
                          colorFilter:
                              ColorFilter.mode(adapted, BlendMode.srcIn))
                      : Icon(icon, color: adapted, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: palette.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: palette.textMain,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: adapted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
