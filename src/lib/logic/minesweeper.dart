import 'dart:async';
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

  late Timer _stopwatchTimer;

  final Stopwatch stopwatch;
  final StreamController<Duration> _elapsedTimeController = StreamController();
  Stream<Duration> get elapsedTimeStream => _elapsedTimeController.stream;

  int _minesCount = 0;
  int get minesCount => _minesCount;
  set minesCount(int value) {
    _minesCount = value;
    _minesCountStream.sink.add(_minesCount);
  }

  final StreamController<int> _minesCountStream = StreamController();
  Stream<int> get minesCountStream => _minesCountStream.stream;

  GameState _state;
  GameState get state => _state;
  set state(GameState state) {
    _state = state;
    if (_state == GameState.playing) {
      startStopwatch();
    } else {
      stopStopwatch();
    }
  }

  void start() {
    if (state == GameState.notStarted) {
      resume();
    }
  }

  Minesweeper(this.cellGrid)
      : _state = GameState.notStarted,
        stopwatch = Stopwatch() {
    minesCount = cellGrid.fold(
      0,
      (previousValue, element) =>
          previousValue +
          element.fold(
            0,
            (value, element) => value + (element.isMine ? 1 : 0),
          ),
    );
  }

  Point<int> get lastGridPoint =>
      Point(cellGrid.first.length - 1, cellGrid.length - 1);

  int flaggedCount = 0;

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
        return Minesweeper.create(5, 6, 5);
      case Difficulty.intermediate:
        return Minesweeper.create(7, 10, 9);
      case Difficulty.hard:
        return Minesweeper.create(10, 14, 20);
    }
  }

  void _open(int x, int y, {bool recursing = false}) {
    start();
    var cell = cellGrid[y][x];
    if (!recursing && cell.isMine && !cell.isFlagged) {
      // the only place where the game is lost
      openAllMines();
      state = GameState.defeat;
    }
    if (cell.isUnopened) {
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
  ) {
    _open(x, y);
    checkResult();
  }

  void flag(int x, int y) {
    start();
    minesCount--;
    final cell = cellGrid[y][x];
    if (cell.isUnopened) {
      cell.state = CellState.flagged;
      if (cell.isMine) flaggedCount++;
    }
    checkResult();
  }

  void unflag(int x, int y) {
    start();
    minesCount++;
    final cell = cellGrid[y][x];
    if (cell.isFlagged) {
      flaggedCount--;
      cell.state = CellState.unopened;
    }
    checkResult();
  }

  void openAllMines() {
    for (var j = 0; j < cellGrid.length; j++) {
      for (var i = 0; i < cellGrid[j].length; i++) {
        final cell = cellGrid[j][i];
        if (cell.isMine) {
          cell.state = CellState.opened;
        }
      }
    }
  }

  void checkResult() {
    final isVictory = cellGrid.every((element) => element.every((cell) =>
        cell.isMine ? cell.isUnopened || cell.isFlagged : cell.isOpened));
    if (isVictory) {
      openAllMines();
      state = GameState.victory;
    }
  }

  void stopStopwatch() {
    stopwatch.stop();
    _elapsedTimeController.sink.add(stopwatch.elapsed);
    _stopwatchTimer.cancel();
  }

  void startStopwatch() {
    stopwatch.start();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1),
        (_) => _elapsedTimeController.sink.add(stopwatch.elapsed));
  }

  void pause() {
    state = GameState.paused;
  }

  void resume() {
    state = GameState.playing;
  }
}

class Cell {
  CellState state;
  final bool isMine;
  final int? neighbouringMineCount;

  bool get isFlagged => state == CellState.flagged;
  bool get isOpened => state == CellState.opened;
  bool get isUnopened => state == CellState.unopened;

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
