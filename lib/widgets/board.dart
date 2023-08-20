import 'package:flutter/material.dart';
import 'package:minesweeper/widgets/cell.dart';
import 'package:minesweeper/logic/minesweeper.dart';

class MinesweeperBoard extends StatefulWidget {
  const MinesweeperBoard(
      {super.key,
      required this.game,
      required this.onFlag,
      required this.onUnflag,
      required this.onOpen});

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
    return Center(
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
                child: LayoutBuilder(builder: (context, constraints) {
                  final biggest = constraints.biggest;
                  final size = biggest.shortestSide /
                      (biggest.aspectRatio > 1
                          ? widget.game.cellGrid.length
                          : widget.game.cellGrid[0].length);
                  return SizedBox(
                    height: constraints.biggest.height,
                    width: constraints.biggest.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var j = 0; j < widget.game.cellGrid.length; j++)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0;
                                  i < widget.game.cellGrid[j].length;
                                  i++)
                                MinesweeperCell(
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
                                )
                            ],
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
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
  }
}
