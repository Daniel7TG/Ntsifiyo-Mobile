import 'dart:math';

/// Port de client/src/components/Games/SopaLetras/wordSearchGenerator.js:
/// genera la sopa de letras conservando acentos/apóstrofes; el relleno usa
/// el alfabeto presente en las palabras colocadas.
class GridPos {
  final int r;
  final int c;
  const GridPos(this.r, this.c);

  @override
  bool operator ==(Object other) =>
      other is GridPos && other.r == r && other.c == c;

  @override
  int get hashCode => Object.hash(r, c);
}

class WordPlacement {
  final int id;
  final String text;
  final List<String> letters;
  final List<GridPos> cells;

  const WordPlacement({
    required this.id,
    required this.text,
    required this.letters,
    required this.cells,
  });
}

class WordSearchBoard {
  final int size;
  final List<List<String>> grid;
  final List<WordPlacement> placements;
  final List<String> unplaced;

  const WordSearchBoard({
    required this.size,
    required this.grid,
    required this.placements,
    required this.unplaced,
  });
}

/// 8 direcciones, incluidas las invertidas.
const allDirections = [
  (dx: 1, dy: 0),
  (dx: -1, dy: 0),
  (dx: 0, dy: 1),
  (dx: 0, dy: -1),
  (dx: 1, dy: 1),
  (dx: -1, dy: -1),
  (dx: 1, dy: -1),
  (dx: -1, dy: 1),
];

/// Mayúsculas, sin espacios; acentos y ʼ se conservan.
String normalizeWord(String raw) =>
    raw.toUpperCase().replaceAll(RegExp(r'\s+'), '');

int gridSizeFor(int longestWord) => max(8, longestWord);

List<GridPos>? _tryPlace(
  List<List<String?>> grid,
  int size,
  List<String> letters,
  ({int dx, int dy}) dir,
  int row,
  int col,
) {
  for (var i = 0; i < letters.length; i++) {
    final r = row + dir.dy * i;
    final c = col + dir.dx * i;
    if (r < 0 || c < 0 || r >= size || c >= size) return null;
    final cur = grid[r][c];
    if (cur != null && cur != letters[i]) return null;
  }
  final cells = <GridPos>[];
  for (var i = 0; i < letters.length; i++) {
    final r = row + dir.dy * i;
    final c = col + dir.dx * i;
    grid[r][c] = letters[i];
    cells.add(GridPos(r, c));
  }
  return cells;
}

List<GridPos>? _placeWord(
  Random random,
  List<List<String?>> grid,
  int size,
  List<String> letters, {
  int maxAttempts = 200,
}) {
  for (var a = 0; a < maxAttempts; a++) {
    final dir = allDirections[random.nextInt(allDirections.length)];
    final row = random.nextInt(size);
    final col = random.nextInt(size);
    final cells = _tryPlace(grid, size, letters, dir, row, col);
    if (cells != null) return cells;
  }
  return null;
}

WordSearchBoard generateWordSearch(
  List<({int id, String text})> entries, {
  Random? random,
}) {
  final rng = random ?? Random();

  final prepared = entries
      .map((e) => (
            id: e.id,
            text: e.text,
            letters: normalizeWord(e.text).split(''),
          ))
      .where((e) => e.letters.isNotEmpty)
      .toList()
    ..sort((a, b) => b.letters.length.compareTo(a.letters.length));

  final longest = prepared.isNotEmpty ? prepared.first.letters.length : 0;

  final alphabet = {for (final e in prepared) ...e.letters}.toList();
  final fillAlphabet =
      alphabet.isNotEmpty ? alphabet : ['A', 'E', 'I', 'O', 'U'];

  final size = gridSizeFor(longest);
  for (var attempt = 0; attempt < 6; attempt++) {
    final grid =
        List.generate(size, (_) => List<String?>.filled(size, null));
    final placements = <WordPlacement>[];
    final unplaced = <String>[];

    for (final e in prepared) {
      final cells = _placeWord(rng, grid, size, e.letters);
      if (cells != null) {
        placements.add(WordPlacement(
            id: e.id, text: e.text, letters: e.letters, cells: cells));
      } else {
        unplaced.add(e.text);
      }
    }

    if (unplaced.isEmpty || attempt == 5) {
      final filled = [
        for (final row in grid)
          [
            for (final cell in row)
              cell ?? fillAlphabet[rng.nextInt(fillAlphabet.length)]
          ]
      ];
      return WordSearchBoard(
        size: size,
        grid: filled,
        placements: placements,
        unplaced: unplaced,
      );
    }
  }
  return WordSearchBoard(
      size: size, grid: const [], placements: const [], unplaced: const []);
}
