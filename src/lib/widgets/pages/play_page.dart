import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minesweeper/logic/minesweeper.dart';
import 'package:minesweeper/widgets/board.dart';
import 'package:minesweeper/widgets/fade_in.dart';
import 'package:minesweeper/widgets/stream_labelled_icon.dart';

final _f = NumberFormat("00");

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedVisibility(
                      visible: game.state != GameState.playing,
                      duration: const Duration(milliseconds: 300),
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text("Main Menu"),
                      ),
                    ),
                    TextButton.icon(
                      label: Text(getPauseText()),
                      icon: Icon(getPauseIcon()),
                      onPressed: getPauseOnPressed(),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: MinesweeperBoard(
                    game: game,
                    onOpen: (x, y) => setState(() => game.open(x, y)),
                    onFlag: (x, y) => setState(() => game.flag(x, y)),
                    onUnflag: (x, y) => setState(() => game.unflag(x, y)),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamLabelledIcon(
                      icon: Icons.timer_outlined,
                      stream: game.elapsedTimeStream,
                      initialData: Duration.zero,
                      textBuilder: (data) {
                        final total = data.inSeconds;
                        final mins = total ~/ 60;
                        final seconds = total % 60;
                        return "${_f.format(mins)}:${_f.format(seconds)}";
                      }),
                  const SizedBox(width: 8),
                  StreamLabelledIcon(
                    icon: Icons.flag_rounded,
                    stream: game.minesCountStream,
                    initialData: 0,
                    textBuilder: (data) => data.toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
