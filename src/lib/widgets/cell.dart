import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:minesweeper/logic/minesweeper.dart';
import 'package:flutter/services.dart';
import 'package:minesweeper/util.dart';

class MinesweeperCell extends StatelessWidget {
  const MinesweeperCell({
    super.key,
    required this.cell,
    required this.size,
    required this.onOpen,
    required this.onFlag,
    required this.onUnflag,
  });
  final Cell cell;
  final double size;

  final void Function() onOpen, onFlag, onUnflag;

  @override
  Widget build(BuildContext context) {
    return isDesktop()
        ? DesktopMinesweeperCell(
            size: size,
            cell: cell,
            onFlag: onFlag,
            onUnflag: onUnflag,
            onOpen: onOpen,
          )
        : MobileMinesweeperCell(
            size: size,
            cell: cell,
            onFlag: onFlag,
            onUnflag: onUnflag,
            onOpen: onOpen,
          );
  }
}

class MobileMinesweeperCell extends StatefulWidget {
  const MobileMinesweeperCell({
    super.key,
    required this.size,
    required this.cell,
    required this.onFlag,
    required this.onUnflag,
    required this.onOpen,
  });
  final Cell cell;
  final double size;

  final void Function() onOpen, onFlag, onUnflag;

  @override
  State<MobileMinesweeperCell> createState() => _MobileMinesweeperCellState();
}

class _MobileMinesweeperCellState extends State<MobileMinesweeperCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  double verticalOffset = 0;
  bool isDragging = false;

  final GlobalKey key = GlobalKey();

  late final double widgetHeight;

  bool hasVibrated = false;

  bool get shouldFirePullEvent => verticalOffset.abs() / widgetHeight >= 1;

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

  bool shouldAllowFlagInteraction(Cell cell) {
    return cell.state != CellState.opened;
  }

  void onDragStop() {
    if (shouldFirePullEvent) {
      if (widget.cell.isFlagged) {
        widget.onUnflag();
      } else {
        widget.onFlag();
      }
    }
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
    final child = SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const FittedBox(
            child: Icon(Icons.flag_circle_rounded, size: 30),
          ),
          SizedBox.expand(
            child: Container(
              margin: const EdgeInsets.all(1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      0,
                      isDragging ? verticalOffset : controller.value,
                    ),
                    child: child,
                  ),
                  child: BaseMinesweeperCell(cell: widget.cell),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return shouldAllowFlagInteraction(widget.cell)
        ? GestureDetector(
            key: key,
            onTap: widget.onOpen,
            onPanStart: (details) => setState(() {
              isDragging = true;
            }),
            onPanUpdate: (details) async {
              setState(() => verticalOffset += details.delta.dy);
              if (shouldFirePullEvent) {
                if (!hasVibrated) {
                  // so we dont keep vibrating
                  hasVibrated = true;
                  await HapticFeedback.vibrate();
                }
              } else {
                hasVibrated = false;
              }
            },
            onPanEnd: (e) => onDragStop(),
            onPanCancel: () => onDragStop(),
            child: child,
          )
        : GestureDetector(
            key: key,
            onTap: widget.onOpen,
            child: child,
          );
  }
}

class DesktopMinesweeperCell extends StatefulWidget {
  const DesktopMinesweeperCell({
    super.key,
    required this.size,
    required this.cell,
    required this.onFlag,
    required this.onUnflag,
    required this.onOpen,
  });

  final double size;
  final Cell cell;

  final void Function() onOpen, onFlag, onUnflag;
  @override
  State<DesktopMinesweeperCell> createState() => _DesktopMinesweeperCellState();
}

class _DesktopMinesweeperCellState extends State<DesktopMinesweeperCell> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          !widget.cell.isOpened ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onOpen,
        onSecondaryTap: () {
          if (widget.cell.isFlagged) {
            widget.onUnflag();
          } else {
            widget.onFlag();
          }
        },
        child: SizedBox.square(
          dimension: widget.size,
          child: Container(
            margin: const EdgeInsets.all(1),
            child: BaseMinesweeperCell(cell: widget.cell),
          ),
        ),
      ),
    );
  }
}

class BaseMinesweeperCell extends StatelessWidget {
  const BaseMinesweeperCell({super.key, required this.cell});

  final Cell cell;

  Color getBackgroundColor() {
    if (cell.isUnopened) {
      return Colors.grey.shade500;
    }
    if (cell.isFlagged) {
      return Colors.redAccent.shade200;
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

  Widget getCellForeground() {
    const style = TextStyle(fontWeight: FontWeight.bold);
    if (cell.isUnopened) {
      return Container();
    } else if (cell.isFlagged) {
      return const FittedBox(
          child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(Icons.flag_rounded),
      ));
    } else if (cell.isMine) {
      return const FittedBox(child: Text("!", style: style));
    } else if (cell.neighbouringMineCount! > 0) {
      return FittedBox(
        child: Text(cell.neighbouringMineCount.toString(), style: style),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: getBackgroundColor(),
      ),
      child: getCellForeground(),
    );
  }
}
