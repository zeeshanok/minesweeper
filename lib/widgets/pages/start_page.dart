import 'package:flutter/material.dart';
import 'package:minesweeper/logic/minesweeper.dart';
import 'package:minesweeper/widgets/pages/play_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Minesweeper"),
      ),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Choose Mode",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: ModeSelector(
              onSelect: (d) => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PlayPage(difficulty: d),
              )),
            ),
          )
        ],
      )),
    );
  }
}

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key, required this.onSelect});

  final void Function(Difficulty difficulty) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DescriptiveButton(
          onPressed: () => onSelect(Difficulty.easy),
          label: ("Easy"),
          description: const Text("5x6 board, 5 mines"),
        ),
        const SizedBox(height: 8),
        DescriptiveButton(
          onPressed: () => onSelect(Difficulty.intermediate),
          label: ("Medium"),
          description: const Text("7x10 board, 9 mines"),
        ),
        const SizedBox(height: 8),
        DescriptiveButton(
          onPressed: () => onSelect(Difficulty.hard),
          label: ("Hard"),
          description: const Text("10x14 board, 20 mines"),
        )
      ],
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
    return FilledButton.tonal(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
        ));
  }
}
