import 'package:flutter/material.dart';
import '../../widgets/wide_bottom_panel.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:aikigrade/widgets/centered_constrained.dart';

class ScaffoldWithWideBottomPanel extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;
  final bool showWidePanel;

  const ScaffoldWithWideBottomPanel({
    super.key,
    this.appBar = const CustomAppBar(),
    required this.body,
    this.showWidePanel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(
            child: CenteredConstrained(
              child: body,
            ),
          ),

          const SizedBox(height: 16),
          if (showWidePanel)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: CenteredConstrained(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: WideBottomPanel(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
