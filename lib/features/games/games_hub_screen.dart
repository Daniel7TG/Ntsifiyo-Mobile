import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/theme.dart';
import '../../shared/widgets/kid_card.dart';

/// Cuadrícula de los 10 juegos con sus SVGs premium (mirror de las tarjetas
/// del panel de juegos de la web).
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
          childAspectRatio: 0.82,
        ),
        itemCount: playableGameTypes.length,
        itemBuilder: (context, index) {
          final info = activityConfig[playableGameTypes[index]]!;
          return KidCard(
            accentColor: info.color,
            padding: const EdgeInsets.all(12),
            onTap: () => context.go('/juegos/${info.id}'),
            child: Column(
              children: [
                // Ilustración SVG del juego sobre fondo suave del color
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: info.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: info.color.withValues(alpha: 0.25),
                          width: 2),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(info.svgAsset,
                        fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 10),
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
                  maxLines: 1,
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
