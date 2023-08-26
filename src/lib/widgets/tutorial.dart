import 'package:flutter/material.dart';
import 'package:minesweeper/logic/minesweeper.dart';
import 'package:minesweeper/widgets/cell.dart';

class Tutorial extends StatefulWidget {
  const Tutorial({
    super.key,
    required this.mineCount,
    required this.message,
  });

  final int mineCount;
  final String message;

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  late Cell cell = Cell.empty(widget.mineCount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MinesweeperCell(
            cell: cell,
            size: 50,
            onOpen: () => setState(() => cell.state = CellState.opened),
            onFlag: () => setState(() => cell.state = CellState.flagged),
            onUnflag: () => setState(() => cell.state = CellState.unopened),
          ),
          const SizedBox(width: 16),
          Text(widget.message)
        ],
      ),
    );
  }
}
