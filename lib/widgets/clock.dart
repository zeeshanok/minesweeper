import 'package:flutter/material.dart';

class MinesweeperClock extends StatelessWidget {
  const MinesweeperClock({super.key, required this.elapsedTimeStream});

  final Stream<Duration> elapsedTimeStream;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: Duration.zero,
      stream: elapsedTimeStream,
      builder: (context, snapshot) => Text(snapshot.data!.inSeconds.toString()),
    );
  }
}
