import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
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

  final GlobalKey key = GlobalKey();

  late final double widgetHeight;

  bool isOpened = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController.unbounded(vsync: this);
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) =>
          setState(() => widgetHeight = key.currentContext!.size!.height),
    );
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

  Color getBackgroundColor(Cell cell) {
    if (!isOpened) {
      return Colors.grey.shade900;
    }
    if (cell.isMine) {
      return Colors.redAccent.shade400;
    }

    final d = {
      0: Colors.grey.shade800,
      1: Colors.blue.shade700,
      2: Colors.green.shade700,
      3: Colors.yellow.shade900,
      4: Colors.red.shade900,
      5: Colors.indigo.shade600,
      6: Colors.pink.shade900,
      7: Colors.deepOrange.shade900,
      8: Colors.cyan.shade900,
      9: Colors.deepPurple.shade900,
    };
    return d[cell.neighbouringMineCount]!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: key,
      onTap: () => setState(() => isOpened = !isOpened),
      onPanStart: (details) => setState(() {
        isDragging = true;
      }),
      onPanUpdate: (details) =>
          setState(() => verticalOffset += details.delta.dy),
      onPanEnd: (e) => onDragStop(),
      onPanCancel: () => onDragStop(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.flag_rounded, size: 30),
          Container(
            margin: const EdgeInsets.all(2),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      0,
                      isDragging ? verticalOffset : controller.value,
                    ),
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: getBackgroundColor(widget.cell),
                    ),
                    child: Center(
                      child: Text(
                        isOpened
                            ? (widget.cell.isMine
                                ? "!"
                                : widget.cell.neighbouringMineCount.toString())
                            : "",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
