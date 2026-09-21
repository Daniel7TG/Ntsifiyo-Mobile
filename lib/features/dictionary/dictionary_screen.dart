import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme.dart';
import '../../core/api/error_messages.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/kid_card.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/states.dart';
import '../games/widgets/game_widgets.dart';
import 'dictionary_repository.dart';

/// Etiqueta y SVG por categoría (mirror de CategoryGrid.jsx).
const _categoryInfo = <String, (String, String)>{
  'ANIMALS': ('Animales', 'assets/svgs/diccionario/topic_animales.svg'),
  'FRUITS': ('Frutas', 'assets/svgs/diccionario/topic_frutas.svg'),
  'FOOD': ('Comida', 'assets/svgs/diccionario/topic_comida.svg'),
  'CLOTHES': ('Ropa', 'assets/svgs/diccionario/topic_ropa.svg'),
  'BODY_PARTS': ('Partes del cuerpo', 'assets/svgs/diccionario/topic_cuerpo.svg'),
  'FIVE_SENSES': ('Los cinco sentidos', 'assets/svgs/diccionario/topic_sentidos.svg'),
  'GREETINGS': ('Saludos', 'assets/svgs/diccionario/topic_saludos.svg'),
  'COLORS': ('Colores', 'assets/svgs/diccionario/topic_colores.svg'),
  'VOWELS': ('Vocales', 'assets/svgs/diccionario/topic_vocales.svg'),
  'PRONOUNS': ('Pronombres', 'assets/svgs/diccionario/topic_pronombres.svg'),
  'LEGENDS': ('Leyendas', 'assets/svgs/diccionario/topic_leyendas.svg'),
  'ANECDOTES': ('Anécdotas', 'assets/svgs/diccionario/topic_anecdotas.svg'),
  'SONGS': ('Canciones', 'assets/svgs/diccionario/topic_canciones.svg'),
  'POEMS': ('Poemas', 'assets/svgs/diccionario/topic_poemas.svg'),
};

(String, String?) _categoryLabel(String category) {
  final info = _categoryInfo[category];
  return (info?.$1 ?? category, info?.$2);
}

/// Diccionario mazahua-español (mirror de DictionaryPage/DictionaryBrowser).
class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  String? _selectedCategory;
  String _search = '';

  bool get _searching => _search.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final dictionary = ref.watch(dictionaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_selectedCategory == null || _searching
            ? 'Diccionario'
            : _categoryLabel(_selectedCategory!).$1),
        leading: _selectedCategory != null && !_searching
            ? BackButton(
                onPressed: () => setState(() => _selectedCategory = null))
            : null,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(dictionaryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: dictionary.when(
        loading: () => const SkeletonGrid(itemCount: 8, aspectRatio: 1.05),
        error: (e, _) => ErrorState(
          message: friendlyErrorMessage(e),
          onRetry: () => ref.read(dictionaryProvider.notifier).refresh(),
        ),
        data: (data) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Buscar en todo el diccionario...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searching
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _search = ''),
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: _searching
                  ? _buildSearchResults(data)
                  : (_selectedCategory == null
                      ? _buildCategoryGrid(data)
                      : _buildWordsGrid(data)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(DictionaryData data) {
    final query = _search.trim().toLowerCase();
    final results = data.allWords
        .where((w) =>
            w.spanishWord.toLowerCase().contains(query) ||
            w.mazahuaWord.toLowerCase().contains(query))
        .toList();
    if (results.isEmpty) {
      return const EmptyState(
        title: 'Sin resultados',
        subtitle: 'Prueba con otra palabra.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) => _WordCard(word: results[index]),
    );
  }

  Widget _buildCategoryGrid(DictionaryData data) {
    // La categoría vacía ('') es el cajón de palabras sin categoría real
    // (D2 del diagnóstico): sus palabras siguen en allWords/el buscador,
    // pero no tiene sentido pintarla como una tarjeta más en la rejilla.
    final categories = data.categories.where((c) => c.isNotEmpty).toList();
    if (categories.isEmpty) {
      return const EmptyState(
        title: 'Diccionario vacío',
        subtitle:
            'Conéctate a internet una vez para descargar las palabras.',
        svgAsset: 'assets/svgs/warning.svg',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final (label, svg) = _categoryLabel(category);
        final count = data.wordsByCategory[category]?.length ?? 0;
        return KidCard(
          accentColor: AppColors.primaryBlue,
          padding: const EdgeInsets.all(14),
          onTap: () => setState(() {
            _selectedCategory = category;
            _search = '';
          }),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: svg != null
                    ? SvgPicture.asset(svg)
                    : const Icon(Icons.category,
                        size: 48, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                '$count palabras',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWordsGrid(DictionaryData data) {
    final words = data.wordsByCategory[_selectedCategory] ?? [];
    if (words.isEmpty) {
      return const EmptyState(
        title: 'Sin palabras',
        subtitle: 'Esta categoría todavía no tiene palabras.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: words.length,
      itemBuilder: (context, index) => _WordCard(word: words[index]),
    );
  }
}

/// Tarjeta de palabra (mirror de WordCard.jsx).
class _WordCard extends StatelessWidget {
  final Word word;
  const _WordCard({required this.word});

  @override
  Widget build(BuildContext context) {
    return KidCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                child: WordImage(path: word.imageUrl),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.mazahuaWord.isNotEmpty ? word.mazahuaWord : word.spanishWord,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          if (word.mazahuaWord.isNotEmpty)
            Text(
              word.spanishWord,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PALABRA',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
              WordAudioButton(audioPath: word.audioUrl, size: 34),
            ],
          ),
        ],
      ),
    );
  }
}
