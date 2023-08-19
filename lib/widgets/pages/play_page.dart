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
                child: FilledButton.tonalIcon(
                  label: const Text("Pause"),
                  onPressed: game.state == GameState.playing
                      ? () {
                          setState(() {
                            game.pause();
                          });
                        }
                      : null,
                  icon: const Icon(Icons.pause_rounded),
                ),
              ),
              MinesweeperBoard(
                game: game,
              ),
              MinesweeperClock(elapsedTimeStream: game.elapsedTimeStream)
            ],
          ),
        ),
      ),
    );
  }
}
