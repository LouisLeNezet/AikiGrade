import 'package:flutter/material.dart';
import '../centered_constrained.dart';

class PageLayout extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final EdgeInsets padding;

  const PageLayout({
    super.key,
    required this.child,
    this.scrollable = true,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return CenteredConstrained(
      child: scrollable ? SingleChildScrollView(child: content) : content,
    );
  }
}
