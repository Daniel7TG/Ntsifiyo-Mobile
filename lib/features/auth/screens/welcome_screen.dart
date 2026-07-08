import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/kid_card.dart';

/// Pantalla de bienvenida: degradado con burbujas decorativas, coyote
/// flotando, título grande y CTAs 3D. Sin SVGs.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Burbujas decorativas de fondo
          const Positioned.fill(
            child: CustomPaint(painter: _BubblesPainter()),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Coyote flotando suavemente
                    AnimatedBuilder(
                      animation: _float,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                            0,
                            6 *
                                math.sin(
                                    _float.value * math.pi)),
                        child: child,
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) =>
                            Transform.scale(scale: value, child: child),
                        child: Image.asset(
                          'assets/coyote/saludo.webp',
                          height: 210,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Título
                    const Text(
                      '¡Jñatrjo!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 48,
                        color: AppColors.primary,
                        height: 1.05,
                        shadows: [
                          Shadow(
                            color: Color(0x33E65100),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
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
                    const SizedBox(height: 20),

                    // Chips de features (íconos material, sin SVG)
                    const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _FeatureChip(
                            icon: Icons.sports_esports,
                            label: '10 juegos',
                            color: AppColors.primary),
                        _FeatureChip(
                            icon: Icons.menu_book,
                            label: 'Diccionario',
                            color: Color(0xFF7C3AED)),
                        _FeatureChip(
                            icon: Icons.music_note,
                            label: 'Canciones',
                            color: AppColors.accentPink),
                        _FeatureChip(
                            icon: Icons.emoji_events,
                            label: 'Gana XP',
                            color: AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 30),

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
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(color: darken(color, 0.1), offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Burbujas suaves de colores de la paleta, estáticas (bajo costo).
class _BubblesPainter extends CustomPainter {
  const _BubblesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bubbles = [
      (0.12, 0.10, 46.0, AppColors.primary),
      (0.88, 0.08, 34.0, AppColors.accentPink),
      (0.08, 0.42, 26.0, AppColors.primaryBlue),
      (0.92, 0.38, 40.0, AppColors.warning),
      (0.15, 0.85, 36.0, AppColors.success),
      (0.85, 0.88, 48.0, AppColors.primary),
      (0.50, 0.05, 22.0, AppColors.success),
    ];
    for (final (fx, fy, radius, color) in bubbles) {
      canvas.drawCircle(
        Offset(fx * size.width, fy * size.height),
        radius,
        Paint()..color = color.withValues(alpha: 0.10),
      );
      canvas.drawCircle(
        Offset(fx * size.width, fy * size.height),
        radius * 0.55,
        Paint()..color = color.withValues(alpha: 0.08),
      );
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter oldDelegate) => false;
}
