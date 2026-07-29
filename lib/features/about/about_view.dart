import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/widgets/kid_card.dart';

/// Sección de "Quiénes somos" (mirror de NosotrosPage.jsx).
class _AboutSection {
  final IconData icon;
  final String label;
  final Color color;
  final String description;

  const _AboutSection({
    required this.icon,
    required this.label,
    required this.color,
    required this.description,
  });
}

const _sections = [
  _AboutSection(
    icon: Icons.code,
    label: 'Desarrolladores',
    color: Color(0xFF6C63FF),
    description:
        'El equipo que diseñó, programó y dio vida a esta plataforma educativa.',
  ),
  _AboutSection(
    icon: Icons.child_care,
    label: 'Niños que prestaron sus voces',
    color: Color(0xFFF59E0B),
    description:
        'Pequeños que grabaron palabras, frases y canciones en mazahua para dar vida a los juegos.',
  ),
  _AboutSection(
    icon: Icons.school,
    label: 'Maestros y adultos hablantes',
    color: Color(0xFF10B981),
    description:
        'Maestros bilingües y adultos de la comunidad que grabaron historias y validaron el contenido lingüístico.',
  ),
  _AboutSection(
    icon: Icons.diversity_3,
    label: 'Otros colaboradores',
    color: Color(0xFFEC4899),
    description:
        'Personas de la comunidad y organizaciones que compartieron historias, canciones y materiales culturales.',
  ),
];

/// Contenido del panel "Quiénes somos", reutilizable en la landing pública
/// y en la pantalla "Acerca de" dentro de la app.
class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                const Color(0xFF6C63FF).withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.kidCard),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.accentPink, width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 14, color: AppColors.accentPink),
                    SizedBox(width: 6),
                    Text(
                      'Hecho con amor por la comunidad',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentPink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Quiénes somos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nts\'i Fíyo es un proyecto colectivo. Detrás de cada palabra, '
                'juego y sonido hay personas reales que creyeron en la '
                'preservación de la lengua mazahua.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        for (final section in _sections) ...[
          KidCard(
            accentColor: section.color,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: section.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(section.icon, color: section.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: section.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section.description,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Cierre
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_stories, color: Color(0xFF6C63FF)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Este proyecto fue posible gracias al apoyo de la Escuela '
                  'primaria bilingüe de Manzanillos, Zitácuaro.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pantalla "Acerca de" dentro de la app (accesible desde el dashboard).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [AboutContent()],
      ),
    );
  }
}
