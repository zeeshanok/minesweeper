import 'package:flutter/material.dart';
import 'package:minesweeper/logic/minesweeper.dart';
import 'package:minesweeper/widgets/board.dart';
import 'package:minesweeper/widgets/clock.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key, required this.difficulty});
  final Difficulty difficulty;
  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  late final game = Minesweeper.createWithDifficulty(widget.difficulty);

  String getPauseText() {
    if (game.state == GameState.paused) {
      return "Resume";
    } else {
      return "Pause";
    }
  }

  IconData getPauseIcon() {
    if (game.state == GameState.paused) {
      return Icons.play_arrow_rounded;
    } else {
      return Icons.pause_rounded;
    }
  }

  void Function()? getPauseOnPressed() {
    if (game.state == GameState.paused) {
      return () => setState(() => game.resume());
    } else if (game.state == GameState.playing) {
      return () => setState(() => game.pause());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  label: Text(getPauseText()),
                  icon: Icon(getPauseIcon()),
                  onPressed: getPauseOnPressed(),
                ),
              ),
              MinesweeperBoard(
                game: game,
                onOpen: (x, y) => setState(() => game.open(x, y)),
                onFlag: (x, y) => setState(() => game.flag(x, y)),
                onUnflag: (x, y) => setState(() => game.unflag(x, y)),
              ),
              MinesweeperClock(elapsedTimeStream: game.elapsedTimeStream)
            ],
          ),
        ),
      ),
    );
  }
}
