import 'package:flutter/material.dart';
import 'package:minesweeper/logic/minesweeper.dart';
import 'package:minesweeper/util.dart';
import 'package:minesweeper/widgets/pages/play_page.dart';
import 'package:minesweeper/widgets/tutorial.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  void showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Instructions",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Tutorial(
                mineCount: 1,
                message: "${isDesktop() ? "Click" : "Tap"} to open a cell",
              ),
              Tutorial(
                mineCount: 2,
                message:
                    "${isDesktop() ? "Right click" : "Swipe up/down"} to flag a cell",
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: !isDesktop(),
        title: const Text("Minesweeper"),
        actions: [
          IconButton(
            onPressed: () {
              showInstructionsDialog(context);
            },
            icon: const Icon(Icons.help_outline_rounded),
          )
        ],
      ),
      body: Center(
        child: ModeSelector(
          onSelect: (diff) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlayPage(difficulty: diff),
            ),
          ),
        ),
      ),
    );
  }
}

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key, required this.onSelect});

  final void Function(Difficulty difficulty) onSelect;

  @override
  Widget build(BuildContext context) {
    final children = [
      Text(
        "Choose difficulty",
        style: TextStyle(fontSize: 22),
      ),
      DescriptiveButton(
        onPressed: () => onSelect(Difficulty.easy),
        label: "Easy",
        description: const Text("5x6 board, 5 mines"),
      ),
      DescriptiveButton(
        onPressed: () => onSelect(Difficulty.intermediate),
        label: "Medium",
        description: const Text("7x10 board, 9 mines"),
      ),
      DescriptiveButton(
        onPressed: () => onSelect(Difficulty.hard),
        label: "Hard",
        description: const Text("10x14 board, 20 mines"),
      )
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class DescriptiveButton extends StatelessWidget {
  final void Function()? onPressed;

  final Widget description;
  final String label;

  const DescriptiveButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          foregroundColor: Theme.of(context).colorScheme.onBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            description,
          ],
        ),
      ),
    );
  }
}
