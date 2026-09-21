import 'package:flutter/material.dart';

import '../../app/activity_config.dart';
import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../core/sync/sync_service.dart';
import '../../shared/widgets/kid_card.dart';

/// Resumen de sincronización (requisito del usuario): actividades hechas
/// offline, XP ganada por cada una, XP total y diferencia de nivel.
Future<void> showSyncSummarySheet(
    BuildContext context, SyncSummary summary) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.palette.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Image.asset('assets/coyote/celebracion.webp', height: 110),
          ),
          const SizedBox(height: 8),
          const Text(
            '¡Progreso sincronizado!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: AppColors.primary,
            ),
          ),
          const Text(
            'Esto fue lo que lograste mientras estabas sin conexión:',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Actividades sincronizadas
          for (final activity in summary.activities)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Builder(builder: (context) {
                final info = gameInfoFor(activity.gameType);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: info.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            Icon(activity.gameType == 'daily_pronunciation' ? Icons.mic_rounded : info.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title.isNotEmpty
                                  ? activity.title
                                  : info.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${activity.correctAnswers}/${activity.totalQuestions} correctas',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+${activity.reward.xpGained} XP',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

          const SizedBox(height: 8),

          // Totales
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                  width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('XP total ganada',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '+${summary.totalXpGained} XP',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nivel',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Text(
                          '${summary.levelBefore}',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.textMuted),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.arrow_forward,
                              size: 18, color: AppColors.textMuted),
                        ),
                        Text(
                          '${summary.levelAfter}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: summary.levelAfter > summary.levelBefore
                                ? AppColors.success
                                : AppColors.textMain,
                          ),
                        ),
                        if (summary.levelAfter > summary.levelBefore)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.celebration,
                                size: 18, color: AppColors.success),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          KidButton(
            label: '¡Genial!',
            icon: Icons.check,
            expanded: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
