import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:minesweeper/logic/minesweeper.dart';

class MinesweeperCell extends StatefulWidget {
  const MinesweeperCell({super.key, required this.cell});
  final Cell cell;

  @override
  State<MinesweeperCell> createState() => _MinesweeperCellState();
}

class _MinesweeperCellState extends State<MinesweeperCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  double verticalOffset = 0;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onDragStop() {
    controller.animateWith(SpringSimulation(
      SpringDescription.withDampingRatio(mass: 10, stiffness: 10, ratio: 0.3),
      verticalOffset,
      0,
      10,
    ));
    setState(() {
      isDragging = false;
      verticalOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => setState(() {
        isDragging = true;
      }),
      onPanUpdate: (details) =>
          setState(() => verticalOffset += details.delta.dy),
      onPanEnd: (e) => onDragStop(),
      onPanCancel: () => onDragStop(),
      child: Container(
        margin: const EdgeInsets.all(2),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) => Transform.translate(
                  offset:
                      Offset(0, isDragging ? verticalOffset : controller.value),
                  child: child),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: widget.cell.isMine ? Colors.red : Colors.blueGrey,
                ),
                child: Center(
                  child: Text(widget.cell.isMine ? "!" : "?"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
