import 'package:flutter/material.dart';
import 'package:minesweeper/widgets/cell.dart';
import 'package:minesweeper/logic/minesweeper.dart';

class MinesweeperBoard extends StatefulWidget {
  const MinesweeperBoard({
    super.key,
    required this.game,
    required this.onFlag,
    required this.onUnflag,
    required this.onOpen,
  });

  final Minesweeper game;
  final void Function(int x, int y) onFlag, onUnflag, onOpen;

  @override
  State<MinesweeperBoard> createState() => _MinesweeperBoardState();
}

class _MinesweeperBoardState extends State<MinesweeperBoard> {
  String getGameForegroundText() {
    switch (widget.game.state) {
      case GameState.notStarted:
        return "Not started";
      case GameState.victory:
        return "You Won";
      case GameState.defeat:
        return "You Lost";
      case GameState.paused:
        return "Paused";
      case GameState.playing:
        return "Playing";
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldAllowPlay = widget.game.state == GameState.playing ||
        widget.game.state == GameState.notStarted;

    // gotta make sure the user slowly understands the games result
    const duration = Duration(milliseconds: 400);
    return LayoutBuilder(
      builder: (context, constraints) {
        final biggest = constraints.biggest;
        final grid = widget.game.cellGrid;
        final x = grid[0].length;
        final y = grid.length;
        double size;
        if (x / y >= biggest.aspectRatio) {
          // cellgrid proportionally looks wider than available
          // space so we should constrain with width
          size = biggest.width / x;
        } else {
          size = biggest.height / y;
        }
        return SizedBox(
          width: size * grid[0].length,
          height: size * grid.length,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedScale(
                scale: shouldAllowPlay ? 1 : 0.82,
                duration: duration + const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                    ignoring: !shouldAllowPlay,
                    child: AnimatedOpacity(
                      opacity: shouldAllowPlay ? 1 : 0.4,
                      duration: duration,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var j = 0; j < widget.game.cellGrid.length; j++)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0;
                                    i < widget.game.cellGrid[j].length;
                                    i++)
                                  Expanded(
                                      child: MinesweeperCell(
                                    size: size,
                                    cell: widget.game.cellGrid[j][i],
                                    onFlag: () {
                                      widget.onFlag(i, j);
                                    },
                                    onUnflag: () {
                                      widget.onUnflag(i, j);
                                    },
                                    onOpen: () {
                                      widget.onOpen(i, j);
                                    },
                                  ))
                              ],
                            ),
                        ],
                      ),
                    )),
              ),
              AnimatedOpacity(
                opacity: shouldAllowPlay ? 0 : 1,
                duration: duration,
                child: Visibility(
                  visible: !shouldAllowPlay,
                  child: Text(
                    getGameForegroundText(),
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
