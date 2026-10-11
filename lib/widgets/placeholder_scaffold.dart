import 'package:flutter/material.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';

class PlaceholderScaffold extends StatelessWidget {
  final String title;
  const PlaceholderScaffold({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: Center(child: Text(title, style: const TextStyle(fontSize: 20))),
    );
  }
}
