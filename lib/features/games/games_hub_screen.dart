import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/theme.dart';
import '../../shared/widgets/kid_card.dart';

/// Cuadrícula de los 10 juegos con tarjetas propias (ícono material +
/// color del juego), sin SVGs.
class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Juegos')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
        ),
        itemCount: playableGameTypes.length,
        itemBuilder: (context, index) {
          final info = activityConfig[playableGameTypes[index]]!;
          return KidCard(
            accentColor: info.color,
            padding: const EdgeInsets.all(14),
            onTap: () => context.go('/juegos/${info.id}'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Insignia circular del juego
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: info.color,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: darken(info.color, 0.15), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: darken(info.color, 0.3),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(info.icon, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 12),
                Text(
                  info.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: info.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
