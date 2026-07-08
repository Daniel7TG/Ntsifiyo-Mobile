import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'kid_card.dart';

/// Tarjeta de estadística (mirror de StatCard.jsx) adaptada a móvil.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subText;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.subText,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return KidCard(
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppColors.textMain,
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
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
