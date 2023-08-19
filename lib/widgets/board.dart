import 'package:flutter/material.dart';
import 'package:minesweeper/widgets/cell.dart';
import 'package:minesweeper/logic/minesweeper.dart';

class MinesweeperBoard extends StatefulWidget {
  const MinesweeperBoard({super.key});

  @override
  State<MinesweeperBoard> createState() => _MinesweeperBoardState();
}

class _MinesweeperBoardState extends State<MinesweeperBoard> {
  Minesweeper game = Minesweeper.createWithDifficulty(Difficulty.easy);

  String getGameForegroundText() {
    switch (game.gameState) {
      case GameState.victory:
        return "You Won";
      case GameState.defeat:
        return "You Lost";
      case GameState.paused:
        return "Paused";
      default:
        return "bruh";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = game.gameState == GameState.playing;
    // gotta make sure the user slowly understands the games result
    const duration = Duration(seconds: 1);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedScale(
            scale: isPlaying ? 1 : 0.82,
            duration: duration + const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: !isPlaying,
              child: AnimatedOpacity(
                opacity: isPlaying ? 1 : 0.4,
                duration: duration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var j = 0; j < game.cellGrid.length; j++)
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          for (var i = 0; i < game.cellGrid[j].length; i++)
                            Expanded(
                              child: MinesweeperCell(
                                cell: game.cellGrid[j][i],
                                onFlag: () {
                                  setState(() {
                                    game.flag(i, j);
                                  });
                                },
                                onUnflag: () {
                                  setState(() {
                                    game.unflag(i, j);
                                  });
                                },
                                onOpen: () {
                                  setState(() {
                                    game.open(i, j);
                                  });
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
            opacity: isPlaying ? 0 : 1,
            duration: duration,
            child: Visibility(
              visible: !isPlaying,
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
