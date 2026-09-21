import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';
import 'kid_card.dart';

/// Estado de error con reintento (mirror de ErrorState.jsx).
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.message = 'Algo salió mal.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: KidCard(
          padding: const EdgeInsets.all(24),
          semanticLabel: message,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/svgs/error_cross.svg',
                  width: 64, height: 64),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.palette.textMain,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                KidButton(
                  label: 'Reintentar',
                  icon: Icons.refresh,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Estado vacío amigable (mirror de los empty states kid-card de la web).
/// Usa un SVG propio en vez de un emoji del sistema, que varía de un
/// teléfono a otro y no se puede teñir para modo oscuro.
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String svgAsset;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle = '',
    this.svgAsset = 'assets/svgs/empty_box.svg',
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: KidCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(svgAsset, width: 72, height: 72),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: palette.textMain,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner de modo offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Sin conexión, tu progreso se guardará y sincronizará después',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Texto oscuro sobre ámbar: blanco sobre este color reprueba
        // contraste AA (~2.1:1); AppColors.textMain sobre el mismo fondo
        // sube a >7:1.
        color: AppColors.warning,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, color: AppColors.textMain, size: 16),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Sin conexión — tu progreso se guardará y sincronizará después',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
