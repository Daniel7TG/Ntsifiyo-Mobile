import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/features/games/logic/maze_generator.dart';
import 'package:jnatrjo_mobile/features/games/logic/word_search_generator.dart';

void main() {
  group('generateWordSearch', () {
    test('coloca todas las palabras y rellena la cuadrícula', () {
      final board = generateWordSearch(
        [
          (id: 1, text: "dyo'o"),
          (id: 2, text: 'mizhi'),
          (id: 3, text: 'nrres'),
          (id: 4, text: 'jñatrjo'),
        ],
        random: Random(42),
      );

      expect(board.unplaced, isEmpty);
      expect(board.placements, hasLength(4));
      expect(board.size, greaterThanOrEqualTo(8));

      // Sin celdas vacías
      for (final row in board.grid) {
        expect(row, hasLength(board.size));
        for (final cell in row) {
          expect(cell, isNotEmpty);
        }
      }

      // Las celdas de cada colocación contienen las letras de la palabra
      for (final p in board.placements) {
        for (var i = 0; i < p.letters.length; i++) {
          expect(board.grid[p.cells[i].r][p.cells[i].c], p.letters[i]);
        }
      }
    });

    test('normaliza mayúsculas y espacios conservando apóstrofes', () {
      expect(normalizeWord("dyo'o pale"), "DYO'OPALE");
    });
  });

  group('generateMaze', () {
    test('todas las celdas quedan visitadas (laberinto conexo)', () {
      for (final seed in [1, 7, 99]) {
        final grid = generateMaze(7, 7, random: Random(seed));
        expect(grid, hasLength(7));
        for (final row in grid) {
          for (final cell in row) {
            expect(cell.visited, isTrue,
                reason: 'celda (${cell.x},${cell.y}) no visitada');
          }
        }
      }
    });

    test('paredes consistentes entre celdas vecinas', () {
      final grid = generateMaze(5, 5, random: Random(3));
      for (var y = 0; y < 5; y++) {
        for (var x = 0; x < 4; x++) {
          expect(grid[y][x].right, grid[y][x + 1].left);
        }
      }
      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 5; x++) {
          expect(grid[y][x].bottom, grid[y + 1][x].top);
        }
      }
    });

    test('dimensiones por dificultad', () {
      expect(mazeDimensions('EASY'), (width: 5, height: 5));
      expect(mazeDimensions('MEDIUM'), (width: 7, height: 7));
      expect(mazeDimensions('HARD'), (width: 10, height: 10));
    });
  });
}
