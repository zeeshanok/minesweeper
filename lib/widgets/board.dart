import 'package:flutter/material.dart';
import 'package:minesweeper/widgets/cell.dart';
import 'package:minesweeper/logic/minesweeper.dart';

class MinesweeperBoard extends StatefulWidget {
  const MinesweeperBoard({super.key, required this.game});

  final Minesweeper game;

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
    const duration = Duration(seconds: 1);
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var j = 0; j < widget.game.cellGrid.length; j++)
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          for (var i = 0;
                              i < widget.game.cellGrid[j].length;
                              i++)
                            Expanded(
                              child: MinesweeperCell(
                                cell: widget.game.cellGrid[j][i],
                                onFlag: () {
                                  setState(() => widget.game.flag(i, j));
                                },
                                onUnflag: () {
                                  setState(() => widget.game.unflag(i, j));
                                },
                                onOpen: () {
                                  setState(() => widget.game.open(i, j));
                                },
                              ),
                            )
                        ],
                      ),
                  ],
                ),
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
