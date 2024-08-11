import 'package:flutter/material.dart';

class PlayerToggler extends StatelessWidget {
  final Widget child;
  final bool value;
  final EdgeInsetsGeometry? customDotPostion;
  const PlayerToggler({
    super.key,
    required this.child,
    required this.value,
    this.customDotPostion,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        child,
        if (value)
          Padding(
            padding: customDotPostion ??
                const EdgeInsets.only(
                  top: 28,
                  left: 16,
                ),
            child: Icon(
              Icons.fiber_manual_record,
              size: 6,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
      ],
    );
  }
}
