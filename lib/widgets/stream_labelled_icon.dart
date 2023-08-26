import 'package:flutter/material.dart';

class StreamLabelledIcon<T> extends StatelessWidget {
  const StreamLabelledIcon({
    super.key,
    required this.icon,
    required this.stream,
    required this.textBuilder,
    required this.initialData,
  });

  final IconData icon;
  final Stream<T> stream;
  final String Function(T data) textBuilder;
  final T initialData;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30),
        const SizedBox(width: 8),
        StreamBuilder(
          initialData: initialData,
          stream: stream,
          builder: (context, snapshot) => Text(
            textBuilder(snapshot.data as T),
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ],
    );
  }
}
