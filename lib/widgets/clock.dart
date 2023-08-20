import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _f = NumberFormat("00");

class MinesweeperClock extends StatelessWidget {
  const MinesweeperClock({super.key, required this.elapsedTimeStream});

  final Stream<Duration> elapsedTimeStream;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 30),
        const SizedBox(width: 8),
        StreamBuilder(
            initialData: Duration.zero,
            stream: elapsedTimeStream,
            builder: (context, snapshot) {
              final total = snapshot.data!.inSeconds;
              final mins = total ~/ 60;
              final seconds = total % 60;
              return Text(
                "${_f.format(mins)}:${_f.format(seconds)}",
                style: const TextStyle(fontSize: 30),
              );
            }),
      ],
    );
  }
}
