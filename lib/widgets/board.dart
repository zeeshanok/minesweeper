import 'package:flutter/material.dart';
import 'package:minesweeper/logic/cell.dart';
import 'package:minesweeper/logic/minesweeper.dart';

class MinesweeperBoard extends StatefulWidget {
  const MinesweeperBoard({super.key});

  @override
  State<MinesweeperBoard> createState() => _MinesweeperBoardState();
}

class _MinesweeperBoardState extends State<MinesweeperBoard> {
  Minesweeper game = Minesweeper.createWithDifficulty(Difficulty.hard);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: game.gameState == GameState.playing
            ? Column(
                key: const ValueKey('game'),
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
                              onFlag: () {},
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
              )
            : const Text("bruh"),
      ),
    );
  }
}
