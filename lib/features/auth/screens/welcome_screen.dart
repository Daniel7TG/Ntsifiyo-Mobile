import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/activity_config.dart';
import '../../../app/palette.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/kid_card.dart';
import '../../about/about_view.dart';

/// Landing pública (mirror libre de Home.jsx, condensado): onboarding de tres
/// pantallas —el coyote saluda, el catálogo de juegos y la comunidad— con el
/// CTA anclado abajo, en vez del scroll largo de secciones apiladas.
///
/// El muestrario de juegos se lee de [playableGameTypes] / [activityConfig],
/// así que añadir un juego nuevo lo actualiza solo: no hay lista paralela.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const _slideCount = 3;

  final _pages = PageController();
  int _index = 0;

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pages.dispose();
    _float.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _slideCount - 1;

  void _next() {
    if (_isLast) {
      context.go('/auth?mode=register');
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _AboutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BubblesPainter(alpha: isDark ? 0.16 : 0.10),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildSkip(),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      _buildGreetingSlide(),
                      _buildGamesSlide(),
                      _buildCommunitySlide(),
                    ],
                  ),
                ),
                _buildDots(),
                _buildActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "Saltar" desaparece en la última lámina: ahí el CTA ya es el destino.
  Widget _buildSkip() {
    final muted = context.palette.textMuted;
    return SizedBox(
      height: 48,
      child: Align(
        alignment: Alignment.centerRight,
        child: AnimatedOpacity(
          opacity: _isLast ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: _isLast,
            child: TextButton(
              onPressed: () => context.go('/auth?mode=login'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Saltar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: muted,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSlide() {
    return _Slide(
      visual: AnimatedBuilder(
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
          child: Image.asset('assets/coyote/saludo.webp', height: 200),
        ),
      ),
      title: '¡Jñatrjo!',
      titleColor: AppColors.primary,
      titleSize: 46,
      subtitle: 'Revitaliza tus raíces: aprende mazahua jugando',
      subtitleColor: AppColors.primaryBlue,
      // El conteo exacto vive en assets/dictionary/manifest.json y crece con
      // cada exportación — por eso "más de 150" y no una cifra que envejezca.
      body: 'Juegos, audio y más de 150 palabras con pronunciación. '
          'Todo sigue funcionando aunque te quedes sin internet.',
    );
  }

  Widget _buildGamesSlide() {
    final games = [for (final t in playableGameTypes) activityConfig[t]!];

    return _Slide(
      visual: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
        childAspectRatio: 0.72,
        children: [for (final info in games) _GameTile(info: info)],
      ),
      title: '${games.length} juegos, un idioma',
      titleColor: AppColors.primary,
      subtitle: 'Aprende jugando',
      subtitleColor: AppColors.success,
      body: 'Memorama, lotería, laberinto, sopa de letras… cada partida suma '
          'XP y avanza tu camino de aprendizaje.',
    );
  }

  Widget _buildCommunitySlide() {
    const accent = Color(0xFF6C63FF);
    return _Slide(
      visual: Image.asset('assets/coyote/celebracion.webp', height: 190),
      title: 'Hecho con el corazón',
      titleColor: accent,
      subtitle: 'La comunidad detrás',
      subtitleColor: accent,
      body: 'Detrás de cada palabra, juego y sonido hay personas reales de la '
          'comunidad mazahua.',
      footer: TextButton(
        onPressed: _openAbout,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Conócenos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: adaptBrand(context, accent),
              ),
            ),
            Icon(Icons.chevron_right, color: adaptBrand(context, accent)),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    final active = adaptBrand(context, AppColors.primary);
    final idle = context.palette.border;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _slideCount; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _index ? 26 : 9,
            height: 9,
            decoration: BoxDecoration(
              color: i == _index ? active : idle,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 8),
      child: Column(
        children: [
          KidButton(
            label: _isLast ? 'Crear cuenta gratis' : 'Siguiente',
            icon: _isLast ? Icons.rocket_launch : Icons.arrow_forward,
            expanded: true,
            onPressed: _next,
          ),
          TextButton(
            onPressed: () => context.go('/auth?mode=login'),
            child: Text(
              'Ya tengo cuenta',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: context.palette.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lámina del onboarding. Centra el contenido, pero deja que haga scroll si la
/// pantalla es baja — así el grid de 10 juegos nunca desborda.
class _Slide extends StatelessWidget {
  final Widget visual;
  final String title;
  final Color titleColor;
  final double titleSize;
  final String subtitle;
  final Color subtitleColor;
  final String body;
  final Widget? footer;

  const _Slide({
    required this.visual,
    required this.title,
    required this.titleColor,
    this.titleSize = 30,
    required this.subtitle,
    required this.subtitleColor,
    required this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = adaptBrand(context, titleColor);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              visual,
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: titleSize,
                  height: 1.1,
                  color: accent,
                  shadows: [
                    Shadow(
                      color: darken(accent, 0.3).withValues(alpha: 0.20),
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: adaptBrand(context, subtitleColor),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: palette.textMuted,
                ),
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

/// Casilla del muestrario: la ilustración premium del juego sobre un fondo
/// suave de su color (mismo tratamiento que GamesHubScreen).
class _GameTile extends StatelessWidget {
  final GameInfo info;

  const _GameTile({required this.info});

  @override
  Widget build(BuildContext context) {
    final color = adaptBrand(context, info.color);
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.30), width: 2),
            ),
            padding: const EdgeInsets.all(7),
            child: SvgPicture.asset(info.svgAsset, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 24,
          child: Text(
            info.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: context.palette.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// Página "Nosotros" abierta desde la landing (fuera del shell autenticado).
class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
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

/// Burbujas suaves de colores de la paleta, estáticas (bajo costo). El alfa
/// sube en oscuro: al 10% del claro casi desaparecen sobre el fondo verdoso.
class _BubblesPainter extends CustomPainter {
  final double alpha;

  const _BubblesPainter({required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    final bubbles = [
      (0.12, 0.06, 46.0, AppColors.primary),
      (0.88, 0.05, 34.0, AppColors.accentPink),
      (0.08, 0.30, 26.0, AppColors.primaryBlue),
      (0.92, 0.26, 40.0, AppColors.warning),
      (0.50, 0.03, 22.0, AppColors.success),
      (0.16, 0.88, 38.0, AppColors.success),
      (0.86, 0.82, 28.0, AppColors.primary),
    ];
    for (final (fx, fy, radius, color) in bubbles) {
      canvas.drawCircle(
        Offset(fx * size.width, fy * size.height),
        radius,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter oldDelegate) => oldDelegate.alpha != alpha;
}
