import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OptimizedValueListenable<T> extends StatelessWidget {
  final Box<T> box;
  final Widget Function(BuildContext, List<T>) builder;
  final bool listen;

  const OptimizedValueListenable({
    super.key,
    required this.box,
    required this.builder,
    this.listen = true,
  });

  @override
  Widget build(BuildContext context) {
    return listen
        ? ValueListenableBuilder<Box<T>>(
            valueListenable: box.listenable(),
            builder: (context, box, _) {
              final items = box.values.toList();
              return builder(context, items);
            },
          )
        : Builder(
            builder: (context) {
              final items = box.values.toList();
              return builder(context, items);
            },
          );
  }
}