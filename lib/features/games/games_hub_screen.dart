import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/activity_config.dart';
import '../../app/theme.dart';
import '../../shared/widgets/kid_card.dart';

/// Cuadrícula de los 10 juegos (equivalente a la navegación de juegos web).
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
          childAspectRatio: 0.92,
        ),
        itemCount: playableGameTypes.length,
        itemBuilder: (context, index) {
          final info = activityConfig[playableGameTypes[index]]!;
          return KidCard(
            accentColor: info.color,
            padding: const EdgeInsets.all(12),
            onTap: () => context.go('/juegos/${info.id}'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SvgPicture.asset(info.svgAsset),
                ),
                const SizedBox(height: 8),
                Text(
                  info.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: info.color,
                  ),
                ),
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
