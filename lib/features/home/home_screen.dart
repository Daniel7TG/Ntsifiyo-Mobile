import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/activity_config.dart';
import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../data/models/daily_pronunciation.dart';
import '../../data/services/daily_pronunciation_service.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/skeleton.dart';
import '../dashboard/dashboard_providers.dart';
import '../games/game_launcher.dart';
import '../games/games_hub_screen.dart';
import '../games/widgets/game_widgets.dart';
import '../progress/progress_providers.dart';
import '../pronunciation/pronunciation_practice_screen.dart';
import 'home_carousel.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final _scroll = ScrollController();
  Timer? _dayTimer;
  bool _carouselVisible = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scroll.addListener(() {
      final visible = _scroll.offset < 340;
      if (visible != _carouselVisible) {
        setState(() => _carouselVisible = visible);
      }
    });
    _dayTimer = Timer.periodic(const Duration(minutes: 1), (_) => _checkDay());
  }

  void _checkDay() {
    final daily = ref.read(dailyChallengeProvider).value;
    if (daily != null && !daily.validAt(DateTime.now())) {
      ref.invalidate(dailyChallengeProvider);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkDay();
  }

  @override
  void dispose() {
    _dayTimer?.cancel();
    _scroll.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(homeGameProvider);
    ref.invalidate(homeAssignmentProvider);
    ref.invalidate(homeMediaProvider);
    ref.invalidate(dailyChallengeProvider);
    ref.invalidate(progressSnapshotProvider);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(homeGameProvider).value;
    final assignment = ref.watch(homeAssignmentProvider).value;
    final media = ref.watch(homeMediaProvider).value;
    final online = ref.watch(isOnlineProvider);
    final items = <HomeSuggestion>[
      if (game != null)
        HomeSuggestion(
          id: 'game:${game.id}',
          badge: 'TE ESPERA EN EL MAPA',
          title: game.title,
          subtitle: 'Un reto pendiente de tu aventura.',
          action: 'Vamos a jugar',
          image: 'assets/home/mapa-juego.webp',
          color: AppColors.success,
          onTap: () async {
            await launchGameWithLoading(
              context,
              ref,
              game: game,
              gameTypeId: gameInfoFor(game.gameType).id,
            );
            ref.invalidate(homeGameProvider);
          },
        ),
      if (assignment != null)
        HomeSuggestion(
          id: 'assignment:${assignment['id']}',
          badge: 'UNA ACTIVIDAD DE TU TAREA',
          title: '${assignment['title'] ?? 'Tu siguiente reto'}',
          subtitle: online
              ? 'Continúa con tu actividad de clase.'
              : 'Conéctate para iniciar tu tarea.',
          action: 'Hacer mi actividad',
          image: 'assets/home/tarea.webp',
          color: AppColors.warning,
          onTap: () async {
            if (!online) {
              _connectionNotice();
              return;
            }
            final id = int.tryParse('${assignment['id']}');
            if (id == null) return;
            await launchGameWithLoading(
              context,
              ref,
              assignmentId: id,
              gameTypeId: gameInfoFor(assignment['gameType'] as String?).id,
            );
            ref.invalidate(homeAssignmentProvider);
          },
        ),
      if (media != null)
        HomeSuggestion(
          id: 'media:${media.id}',
          badge: 'ESCUCHA E IMAGINA',
          title: media.title,
          subtitle: online
              ? 'Una historia, un ritmo, nuevas palabras.'
              : 'Conéctate para escuchar este contenido.',
          action: 'Quiero escuchar',
          image: 'assets/home/historias.webp',
          color: const Color(0xFF0284C7),
          onTap: () {
            if (online) {
              context.push('/reproductor/${media.id}', extra: media);
            } else {
              _connectionNotice();
            }
          },
        ),
      HomeSuggestion(
        id: 'pronunciation',
        badge: 'DALE VOZ AL MAZAHUA',
        title: 'Escucha, repite y sorpréndete.',
        subtitle: 'Practica a tu ritmo, palabra por palabra.',
        action: 'Vamos a practicar',
        image: 'assets/home/pronunciacion.webp',
        color: const Color(0xFF8B5CF6),
        onTap: () => context.go('/explorar/pronunciacion'),
      ),
      HomeSuggestion(
        id: 'dictionary',
        badge: 'ABRE UNA NUEVA PUERTA',
        title: '¿Cómo se dice en mazahua?',
        subtitle: 'Descubre palabras, imágenes y sonidos.',
        action: 'Descubrir palabras',
        image: 'assets/home/diccionario.webp',
        color: AppColors.warning,
        onTap: () => context.go('/palabras'),
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            tooltip: 'Todos los juegos',
            onPressed: () => context.push('/inicio/juegos'),
            icon: const Icon(Icons.grid_view_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const Text(
                '¿Qué hacemos hoy?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              HomeCarousel(items: items, visible: _carouselVisible),
              const SizedBox(height: 14),
              const Text(
                'Tu palabra de hoy',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ref
                  .watch(dailyChallengeProvider)
                  .when(
                    loading: () => const SkeletonBox(
                      width: double.infinity,
                      height: 180,
                      borderRadius: 20,
                    ),
                    error: (_, _) => _dailyUnavailable(online),
                    data: (c) =>
                        c == null ? _dailyUnavailable(online) : _dailyCard(c),
                  ),
              const SizedBox(height: 24),
              MapSummaryCard(progress: ref.watch(totalProgressProvider)),
            ],
          ),
        ),
      ),
    );
  }

  void _connectionNotice() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Necesitas conexión para abrir este contenido.'),
    ),
  );
  Widget _dailyUnavailable(bool online) => KidCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          online
              ? 'No se pudo cargar el reto de hoy.'
              : 'Conéctate para descargar el reto de hoy.',
          style: TextStyle(color: context.palette.textMuted),
        ),
        TextButton(
          onPressed: () => ref.invalidate(dailyChallengeProvider),
          child: const Text('Reintentar'),
        ),
        KidButton(
          label: 'Practicar palabras',
          onPressed: () => context.go('/explorar/pronunciacion'),
        ),
      ],
    ),
  );
  Widget _dailyCard(DailyChallenge c) {
    final words = ref.watch(practiceWordsProvider).value ?? [];
    final word = words.where((w) => w.id == c.word.id).firstOrNull;
    return KidCard(
      accentColor: AppColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              const Text(
                'RETO DE PRONUNCIACIÓN',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
              Text(
                c.completed
                    ? '100 XP ganados'
                    : c.error != null
                    ? 'Sin confirmar'
                    : c.pending
                    ? '100 XP pendientes'
                    : '+100 XP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: adaptBrand(context, AppColors.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: WordImage(
                  path: word?.imageUrl,
                  wordId: c.word.id,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.word.mazahuaWord,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      c.word.spanishWord,
                      style: TextStyle(color: context.palette.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (c.pending)
            Text(
              c.error ?? pendingXpMessage,
              style: TextStyle(color: context.palette.textMuted),
            ),
          if (!c.pending)
            KidButton(
              label: c.completed
                  ? '¡Reto de hoy completado!'
                  : 'Pronuncia tu palabra',
              icon: c.completed ? Icons.check_circle : Icons.mic_rounded,
              color: AppColors.warning,
              expanded: true,
              onPressed: c.completed || word == null
                  ? null
                  : () async {
                      final account = ref.read(homeAccountProvider);
                      if (account == null) return;
                      await Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GradientBackground(
                            child: PronunciationPracticeScreen(
                              word: word,
                              onAccepted: () async {
                                final result = await ref
                                    .read(dailyPronunciationServiceProvider)
                                    .complete(account, c);
                                ref.invalidate(dailyChallengeProvider);
                                if (result.pending) return pendingXpMessage;
                                ref.invalidate(dashboardProvider);
                                return result.reward?.xpGained == 0
                                    ? '¡Reto completado! Tus 100 XP ya estaban registrados.'
                                    : '¡Reto completado! Ganaste 100 XP.';
                              },
                            ),
                          ),
                        ),
                      );
                      if (mounted) ref.invalidate(dailyChallengeProvider);
                    },
            ),
          if (word == null && !c.completed && !c.pending)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Esta palabra no está disponible en el validador de este dispositivo.',
              ),
            ),
        ],
      ),
    );
  }
}
