import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/kid_card.dart';

/// Pantalla de bienvenida llamativa: degradado, coyote mascota,
/// íconos de juegos flotando y CTAs grandes.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  static const _floatingIcons = [
    ('assets/svgs/juegos/quiz_premium.svg', 0.08, 0.10, 52.0),
    ('assets/svgs/juegos/memorama_premium.svg', 0.78, 0.07, 58.0),
    ('assets/svgs/juegos/loteria_premium.svg', 0.12, 0.30, 46.0),
    ('assets/svgs/juegos/laberinto_premium.svg', 0.80, 0.27, 50.0),
    ('assets/svgs/juegos/sopa_letras_premium.svg', 0.06, 0.52, 44.0),
    ('assets/svgs/juegos/tripas_premium.svg', 0.82, 0.48, 46.0),
  ];

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Íconos de juegos flotando con desfase
            AnimatedBuilder(
              animation: _float,
              builder: (context, _) {
                return Stack(
                  children: [
                    for (var i = 0; i < _floatingIcons.length; i++)
                      Positioned(
                        left: _floatingIcons[i].$2 * size.width,
                        top: _floatingIcons[i].$3 * size.height +
                            8 *
                                math.sin(2 * math.pi * _float.value +
                                    i * math.pi / 3),
                        child: Opacity(
                          opacity: 0.85,
                          child: SvgPicture.asset(
                            _floatingIcons[i].$1,
                            width: _floatingIcons[i].$4,
                            height: _floatingIcons[i].$4,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // Contenido principal
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Coyote saludando
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: Image.asset(
                        'assets/coyote/saludo.webp',
                        height: 190,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Título
                    const Text(
                      '¡Jñatrjo!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 44,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aprende mazahua jugando',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Juegos, canciones, leyendas y un diccionario\npara descubrir la lengua jñatrjo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CTAs
                    KidButton(
                      label: '¡Entrar a jugar!',
                      icon: Icons.sports_esports,
                      expanded: true,
                      onPressed: () => context.go('/auth?mode=login'),
                    ),
                    const SizedBox(height: 14),
                    KidButton(
                      label: 'Crear cuenta',
                      icon: Icons.person_add,
                      color: AppColors.primaryBlue,
                      expanded: true,
                      onPressed: () => context.go('/auth?mode=register'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
