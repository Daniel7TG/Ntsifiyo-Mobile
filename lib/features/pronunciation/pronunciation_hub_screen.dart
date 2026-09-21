import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../core/ai/validador_service.dart';
import '../../core/storage/app_database.dart';
import '../../data/models/models.dart';
import '../../data/services/misc_services.dart';
import '../dictionary/dictionary_repository.dart';
import '../games/widgets/game_widgets.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/skeleton.dart';
import 'pronunciation_practice_screen.dart';
import 'practice_words.dart';

/// Pantalla de selección de palabras para Práctica de Pronunciación.
///
/// La lista de palabras practicables está acotada por diseño al vocabulario
/// que el modelo ONNX sabe evaluar (`centroidesProvider`, ver
/// `validador_service.dart`): mostrar una palabra sin centroide invitaría a
/// grabar algo que el validador no puede juzgar de verdad.
class PronunciationHubScreen extends ConsumerStatefulWidget {
  const PronunciationHubScreen({super.key});

  @override
  ConsumerState<PronunciationHubScreen> createState() =>
      _PronunciationHubScreenState();
}

class _PronunciationHubScreenState
    extends ConsumerState<PronunciationHubScreen> {
  String _searchQuery = '';
  final Set<int> _syncedWordIds = {};

  @override
  Widget build(BuildContext context) {
    final dictionaryAsync = ref.watch(dictionaryProvider);
    final centroidesAsync = ref.watch(centroidesProvider);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Práctica de pronunciación',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: dictionaryAsync.when(
          loading: () => const SkeletonGrid(itemCount: 8, aspectRatio: 0.85),
          error: (err, stack) => Center(
            child: Text(
              'No se pudieron cargar las palabras.',
              style: TextStyle(color: palette.textMuted),
            ),
          ),
          data: (dictData) => centroidesAsync.when(
            loading: () =>
                const SkeletonGrid(itemCount: 8, aspectRatio: 0.85),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo cargar el validador de pronunciación. '
                  'Vuelve a intentarlo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textMuted),
                ),
              ),
            ),
            data: (centroidSet) =>
                _buildContent(context, dictData, centroidSet, palette),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DictionaryData dictData,
    Set<String> centroidSet,
    AppPalette palette,
  ) {
    final allWords = dictData.allWords;

    final matchedWords = allWords.where((word) => isPracticeWord(word, centroidSet)).toList();

    // Efecto secundario (marcar pronunciation=true localmente y en el
    // backend), fuera de build: se programa para después del frame en vez
    // de ejecutarse durante la construcción del widget. _syncedWordIds hace
    // que repetirlo en cada rebuild (p. ej. al teclear en el buscador) sea
    // inofensivo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final word in matchedWords) {
        if (word.id != null && !_syncedWordIds.contains(word.id!)) {
          _syncedWordIds.add(word.id!);
          _updatePronunciationStatus(word.id!);
        }
      }
    });

    var availableWords = matchedWords;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      availableWords = availableWords.where((w) {
        return w.spanishWord.toLowerCase().contains(query) ||
            w.mazahuaWord.toLowerCase().contains(query);
      }).toList();
    }

    return Column(
      children: [
        // Cabecera interactiva del Coyote
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/coyote/coyote_happy.png',
                  width: 56,
                  height: 56,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.record_voice_over_rounded,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Demuestra tu voz!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Selecciona una palabra, escucha cómo se pronuncia y graba tu intento.',
                        style: TextStyle(
                          fontFamily: 'PublicSans',
                          fontSize: 13,
                          color: AppColors.textMain,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Buscador de palabras
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Buscar palabra para practicar...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: palette.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide(color: palette.border),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Grilla de palabras
        Expanded(
          child: availableWords.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No se encontraron palabras para practicar.'
                          : 'Aún no hay palabras disponibles para practicar '
                              'pronunciación.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textMuted),
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: availableWords.length,
                  itemBuilder: (context, index) {
                    final word = availableWords[index];
                    return _WordPracticeCard(
                      word: word,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PronunciationPracticeScreen(word: word),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _updatePronunciationStatus(int wordId) async {
    try {
      // 1. Actualizar base de datos local SQLite
      final db = ref.read(appDatabaseProvider);
      await db.updateWordPronunciationFlag(wordId, true);

      // 2. Sincronizar con el endpoint del backend PUT /api/dictionary/word/{id}/media
      final service = ref.read(dictionaryServiceProvider);
      await service.updateWordPronunciation(wordId, true);
    } catch (_) {
      // Ignorar errores puntuales de red
    }
  }
}

class _WordPracticeCard extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;

  const _WordPracticeCard({
    required this.word,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KidCard(
      accentColor: const Color(0xFF8B5CF6),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: WordImage(
                path: word.imageUrl,
                wordId: word.id,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.mazahuaWord,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.mic_rounded,
                      size: 18,
                      color: Color(0xFF8B5CF6),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  word.spanishWord,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PublicSans',
                    fontSize: 12,
                    color: AppColors.textMuted,
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
