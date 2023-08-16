import 'dart:math';

typedef Coord = Point<int>;
bool isInRangeInclusive(int x, int a, int b) => a <= x && x <= b;

Set<Coord> getSurroundingPoints(Coord coord, Coord endCoord) {
  final x = coord.x, y = coord.y;
  return {
    (x - 1, y - 1),
    (x, y - 1),
    (x + 1, y - 1),
    (x + 1, y),
    (x + 1, y + 1),
    (x, y + 1),
    (x - 1, y + 1),
    (x - 1, y),
  }
      .where((p) =>
          isInRangeInclusive(p.$1, 0, endCoord.x) &&
          isInRangeInclusive(p.$2, 0, endCoord.y))
      .map((e) => Point(e.$1, e.$2))
      .toSet();
}

class Minesweeper {
  final List<List<Cell>> cellGrid;

  GameState gameState;

  Minesweeper(this.cellGrid) : gameState = GameState.notStarted;

  // -1 is a mine
  factory Minesweeper.fromNumericGrid(List<List<int>> grid) {
    return Minesweeper(
      List.generate(
        grid.length,
        (j) =>
            grid[j].map((e) => e == -1 ? Cell.mine() : Cell.empty(e)).toList(),
      ),
    );
  }

  factory Minesweeper.create(int boardWidth, int boardHeight, int mineCount) {
    final totalCells = boardWidth * boardHeight;
    final lastPoint = Point(boardWidth - 1, boardHeight - 1);
    final rand = Random();
    var minesLeft = mineCount;

    final grid = List.generate(
      boardHeight,
      (_) => List.filled(boardWidth, 0, growable: false),
      growable: false,
    );

    for (int j = 0; j < boardHeight; j++) {
      var cellsDone = j * boardWidth;
      for (var i = 0; i < boardWidth; i++) {
        late final bool isMine;

        if (minesLeft == totalCells - cellsDone) {
          // coming here is very unlikely
          isMine = true;
        } else {
          final prob = minesLeft / (totalCells - cellsDone++);
          isMine = rand.nextDouble() <= prob;
        }

        if (isMine) {
          minesLeft--;

          grid[j][i] = -1; // set as mine
          for (var point in getSurroundingPoints(Point(i, j), lastPoint)) {
            if (grid[point.y][point.x] != -1) {
              grid[point.y][point.x]++;
            }
          }
        }
      }
    }

    return Minesweeper.fromNumericGrid(grid);
  }

  factory Minesweeper.createWithDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Minesweeper.create(5, 5, 6);
      case Difficulty.intermediate:
        return Minesweeper.create(9, 9, 14);
      case Difficulty.hard:
        return Minesweeper.create(12, 12, 30);
    }
  }
  void _openSurrounding(int x, int y) {}

  void open(int x, int y) {
    var cell = cellGrid[y][x];
    cell.state = CellState.opened;
    if (cell.isMine) {
      // the only place where the game is lost
      gameState = GameState.defeat;
    }
    // else if (cell.neighbouringMineCount > 0) {
    //   _openSurrounding(x, y);
    // }
  }
}

class Cell {
  CellState state;
  final bool isMine;

  final int? neighbouringMineCount;

  Cell({
    required this.state,
    required this.isMine,
    this.neighbouringMineCount,
  });

  factory Cell.mine() => Cell(state: CellState.unopened, isMine: true);
  factory Cell.empty(int neighbouringMineCount) => Cell(
        state: CellState.unopened,
        isMine: false,
        neighbouringMineCount: neighbouringMineCount,
      );
}

enum CellState { unopened, opened, flagged }

enum GameState { notStarted, playing, paused, victory, defeat }

enum Difficulty { easy, intermediate, hard }
