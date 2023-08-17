import 'dart:math';

typedef Coord = Point<int>;
bool isInRangeInclusive(int x, int a, int b) => a <= x && x <= b;

Set<(int x, int y)> getSurroundingPoints((int x, int y) coord, Coord endCoord) {
  final x = coord.$1, y = coord.$2;
  return {
    (x - 1, y - 1),
    (x + 1, y - 1),
    (x + 1, y + 1),
    (x - 1, y + 1),
    (x, y - 1),
    (x + 1, y),
    (x, y + 1),
    (x - 1, y),
  }
      .where((p) =>
          isInRangeInclusive(p.$1, 0, endCoord.x) &&
          isInRangeInclusive(p.$2, 0, endCoord.y))
      .toSet();
}

class Minesweeper {
  final List<List<Cell>> cellGrid;

  GameState gameState;

  Minesweeper(this.cellGrid) : gameState = GameState.playing;

  Point<int> get lastGridPoint =>
      Point(cellGrid.first.length - 1, cellGrid.length - 1);

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

        final isCorner = ({
          // corner cells shouldn't be mines
          (0, 0),
          (boardWidth - 1, boardHeight - 1),
          (boardWidth - 1, 0),
          (0, boardHeight - 1),
        }.contains((i, j)));

        if (isCorner) {
          isMine = false;
        } else if (minesLeft == totalCells - cellsDone) {
          // coming here is very unlikely
          isMine = true;
        } else {
          final prob = minesLeft / (totalCells - cellsDone++);

          isMine = rand.nextDouble() <= prob;
        }

        if (isMine) {
          minesLeft--;

          grid[j][i] = -1; // set as mine
          for (var point in getSurroundingPoints(
              (i, j), Point(boardWidth - 1, boardHeight - 1))) {
            if (grid[point.$2][point.$1] != -1) {
              grid[point.$2][point.$1]++;
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
        return Minesweeper.create(7, 7, 9);
      case Difficulty.hard:
        return Minesweeper.create(10, 10, 20);
    }
  }
  // void _openSurrounding(int x, int y, [int? fromX, int? fromY]) {
  //   var points =
  //       getSurroundingPoints((x, y), lastGridPoint, nonDiagonal: true);
  //   if (fromX != null && fromY != null) {
  //     points = points.where((p) => p != Point(fromX, fromY)).toSet();
  //   }
  //   for (final point in points) {
  //     var cell = cellGrid[point.y][point.x];
  //     cell.state = CellState.opened;
  //     if (cell.neighbouringMineCount == 0 && cell.state == CellState.unopened) {
  //       _openSurrounding(point.x, point.y, x, y);
  //     }
  //   }
  // }

  void _open(int x, int y, {bool recursing = false}) {
    // if (cell.state)
    var cell = cellGrid[y][x];
    if (!recursing && cell.isMine) {
      // the only place where the game is lost
      gameState = GameState.defeat;
    }
    if (cell.state == CellState.unopened) {
      cell.state = CellState.opened;

      if (cell.neighbouringMineCount == 0) {
        final points = getSurroundingPoints((x, y), lastGridPoint);
        for (final point in points) {
          _open(point.$1, point.$2, recursing: true);
        }
      }
    }
  }

  void open(
    int x,
    int y,
  ) =>
      _open(x, y);
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
