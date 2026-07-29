import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/kid_card.dart';
import '../../about/about_view.dart';

/// Landing pública (mirror de Home.jsx): hero con coyote, muestrario de
/// juegos, frases comunes, teaser de "Nosotros" y CTAs de acceso.
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

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _AboutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _BubblesPainter())),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHero()),
                SliverToBoxAdapter(child: _buildGamesShowcase()),
                SliverToBoxAdapter(child: _buildPhrases()),
                SliverToBoxAdapter(child: _buildAboutTeaser()),
                SliverToBoxAdapter(child: _buildFinalCta()),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, 6 * math.sin(_float.value * math.pi)),
              child: child,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Image.asset('assets/coyote/saludo.webp', height: 190),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '¡Jñatrjo!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 46,
              color: AppColors.primary,
              height: 1.05,
              shadows: [
                Shadow(
                    color: Color(0x33E65100),
                    offset: Offset(0, 4),
                    blurRadius: 0),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Revitaliza tus raíces: aprende mazahua jugando',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          KidButton(
            label: '¡Entrar a jugar!',
            icon: Icons.sports_esports,
            expanded: true,
            onPressed: () => context.go('/auth?mode=login'),
          ),
          const SizedBox(height: 12),
          KidButton(
            label: 'Crear cuenta',
            icon: Icons.person_add,
            color: AppColors.primaryBlue,
            expanded: true,
            onPressed: () => context.go('/auth?mode=register'),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesShowcase() {
    const games = [
      (Icons.style, 'Memoria Rápida', Color(0xFFE65100)),
      (Icons.quiz, 'Quiz', Color(0xFF7C3AED)),
      (Icons.psychology, 'El Intruso', Color(0xFFD97706)),
      (Icons.casino, 'Lotería', Color(0xFFB45309)),
      (Icons.route, 'Laberinto', Color(0xFF10B981)),
      (Icons.link, 'Pares', Color(0xFF0EA5E9)),
      (Icons.search, 'Sopa de Letras', Color(0xFF0284C7)),
      (Icons.gesture, 'Tripas del Gato', Color(0xFF10B981)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            label: 'JUEGOS',
            title: 'Aprende jugando',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
            children: [
              for (final (icon, title, color) in games)
                _GameChip(icon: icon, title: title, color: color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhrases() {
    const phrases = [
      ('Nde joo ra nde ko', 'Buenos días', Icons.wb_sunny),
      ('Ha ri xi?', '¿Cómo estás?', Icons.sentiment_satisfied),
      ('Pa mbe jña ra kjua', 'Gracias', Icons.favorite),
      ('Nde ndixu', 'Buenas noches', Icons.dark_mode),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            label: 'FRASES COMUNES',
            title: 'Frases que conectan',
            color: Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          for (final (mz, es, icon) in phrases)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: KidCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: AppColors.success, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mz,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            es,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutTeaser() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: KidCard(
        accentColor: const Color(0xFF6C63FF),
        padding: const EdgeInsets.all(20),
        onTap: _openAbout,
        child: Column(
          children: [
            const Icon(Icons.diversity_3,
                size: 40, color: Color(0xFF6C63FF)),
            const SizedBox(height: 10),
            const Text(
              'Un proyecto hecho con el corazón',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Detrás de cada palabra, juego y sonido hay personas reales de la '
              'comunidad mazahua.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Conócenos',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: darken(const Color(0xFF6C63FF), 0.1),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF6C63FF)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalCta() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: KidCard(
        accentColor: AppColors.primary,
        backgroundColor: AppColors.primary.withValues(alpha: 0.06),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '¿List@ para empezar?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            KidButton(
              label: 'Crear cuenta gratis',
              icon: Icons.rocket_launch,
              expanded: true,
              onPressed: () => context.go('/auth?mode=register'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Página "Nosotros" abierta desde la landing (fuera del shell autenticado).
class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Nosotros')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [AboutContent()],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final String title;
  final Color color;

  const _SectionTitle(
      {required this.label, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }
}

class _GameChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _GameChip(
      {required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(color: darken(color, 0.1), offset: const Offset(0, 3)),
            ],
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// Burbujas suaves de colores de la paleta, estáticas (bajo costo).
class _BubblesPainter extends CustomPainter {
  const _BubblesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bubbles = [
      (0.12, 0.06, 46.0, AppColors.primary),
      (0.88, 0.05, 34.0, AppColors.accentPink),
      (0.08, 0.30, 26.0, AppColors.primaryBlue),
      (0.92, 0.26, 40.0, AppColors.warning),
      (0.50, 0.03, 22.0, AppColors.success),
    ];
    for (final (fx, fy, radius, color) in bubbles) {
      canvas.drawCircle(
        Offset(fx * size.width, fy * size.height),
        radius,
        Paint()..color = color.withValues(alpha: 0.10),
      );
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter oldDelegate) => false;
}
