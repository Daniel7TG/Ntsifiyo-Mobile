import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/widgets/kid_card.dart';
import '../progress/progress_providers.dart';

/// Punto de entrada de la rama Explorar: mapa de aventuras y contenido multimedia.
/// Muestra dos botones grandes con imágenes principales e información descriptiva.
class ExploreHubScreen extends ConsumerWidget {
  const ExploreHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(totalProgressProvider);
    final percent = (progress.percent * 100).round();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Explorar',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ExploreBigButton(
              imageAsset: 'assets/explore/pronunciacion.webp',
              title: 'Práctica de pronunciación',
              subtitle:
                  'Escucha palabras en mazahua, graba tu voz y descubre tu puntuación con IA al instante',
              accentColor: const Color(0xFF8B5CF6),
              onTap: () => context.push('/explorar/pronunciacion'),
            ),
            const SizedBox(height: 20),
            _ExploreBigButton(
              imageAsset: 'assets/explore/map.webp',
              title: 'Mapa de aventuras',
              subtitle: 'Tu aventura · $percent% completado',
              accentColor: AppColors.success,
              onTap: () => context.push('/explorar/mapa'),
            ),
            const SizedBox(height: 20),
            _ExploreBigButton(
              imageAsset: 'assets/explore/anecdotas.webp',
              title: 'Contenido',
              subtitle: 'Canciones, leyendas, anécdotas y poemas',
              accentColor: const Color(0xFFDB2777),
              onTap: () => context.push('/explorar/contenido'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreBigButton extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _ExploreBigButton({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KidCard(
      accentColor: accentColor,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen grande recortada estilizada
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sección de información con el texto debajo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'PublicSans',
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: accentColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
