import 'package:flutter/material.dart';
import 'package:minesweeper/logic/cell.dart';
import 'package:minesweeper/logic/minesweeper.dart';

class MinesweeperBoard extends StatefulWidget {
  const MinesweeperBoard({super.key});

  @override
  State<MinesweeperBoard> createState() => _MinesweeperBoardState();
}

class _MinesweeperBoardState extends State<MinesweeperBoard> {
  Minesweeper game = Minesweeper.createWithDifficulty(Difficulty.easy);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in game.cellGrid)
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                for (final cell in row)
                  Expanded(
                    child: MinesweeperCell(
                      cell: cell,
                    ),
                  )
              ],
            ),
          const SizedBox(height: 6),
          FilledButton(
            onPressed: () {
              setState(() {
                game =
                    Minesweeper.createWithDifficulty(Difficulty.intermediate);
              });
            },
            child: const Text("Randomise"),
          )
        ],
      ),
    );
  }
}
