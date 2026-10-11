import 'package:flutter/material.dart';

class ListScreenLayout extends StatelessWidget {
  final Widget header;
  final Widget child;

  const ListScreenLayout({
    super.key,
    required this.header,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // fixed header (search, filters, metadata)
        Padding(padding: const EdgeInsets.all(16), child: header),

        // scrollable content ONLY
        Expanded(child: child),
      ],
    );
  }
}
