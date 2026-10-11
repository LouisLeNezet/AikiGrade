import 'package:flutter/material.dart';

class CenteredConstrained extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredConstrained({
    super.key,
    required this.child,
    this.maxWidth = 500,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
