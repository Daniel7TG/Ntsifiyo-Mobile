import 'dart:math';

/// Port de client/src/utils/mazeGenerator.js — recursive backtracker (DFS).
class MazeCell {
  final int x;
  final int y;
  bool top = true;
  bool right = true;
  bool bottom = true;
  bool left = true;
  bool visited = false;

  MazeCell(this.x, this.y);
}

({int width, int height}) mazeDimensions(String difficulty) {
  switch (difficulty.toUpperCase()) {
    case 'EASY':
      return (width: 5, height: 5);
    case 'HARD':
      return (width: 10, height: 10);
    case 'MEDIUM':
    default:
      return (width: 7, height: 7);
  }
}

List<List<MazeCell>> generateMaze(int width, int height, {Random? random}) {
  final rng = random ?? Random();
  final grid = [
    for (var y = 0; y < height; y++)
      [for (var x = 0; x < width; x++) MazeCell(x, y)]
  ];

  var current = grid[rng.nextInt(height)][rng.nextInt(width)];
  current.visited = true;
  final stack = <MazeCell>[];

  List<({String dir, MazeCell cell})> unvisitedNeighbors(MazeCell cell) {
    final neighbors = <({String dir, MazeCell cell})>[];
    final x = cell.x, y = cell.y;
    if (y > 0 && !grid[y - 1][x].visited) {
      neighbors.add((dir: 'top', cell: grid[y - 1][x]));
    }
    if (x < width - 1 && !grid[y][x + 1].visited) {
      neighbors.add((dir: 'right', cell: grid[y][x + 1]));
    }
    if (y < height - 1 && !grid[y + 1][x].visited) {
      neighbors.add((dir: 'bottom', cell: grid[y + 1][x]));
    }
    if (x > 0 && !grid[y][x - 1].visited) {
      neighbors.add((dir: 'left', cell: grid[y][x - 1]));
    }
    return neighbors;
  }

  void removeWalls(MazeCell a, MazeCell b, String dir) {
    switch (dir) {
      case 'top':
        a.top = false;
        b.bottom = false;
      case 'right':
        a.right = false;
        b.left = false;
      case 'bottom':
        a.bottom = false;
        b.top = false;
      case 'left':
        a.left = false;
        b.right = false;
    }
  }

  do {
    final neighbors = unvisitedNeighbors(current);
    if (neighbors.isNotEmpty) {
      final next = neighbors[rng.nextInt(neighbors.length)];
      stack.add(current);
      removeWalls(current, next.cell, next.dir);
      current = next.cell;
      current.visited = true;
    } else if (stack.isNotEmpty) {
      current = stack.removeLast();
    }
  } while (stack.isNotEmpty || unvisitedNeighbors(current).isNotEmpty);

  return grid;
}
