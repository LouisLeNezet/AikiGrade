import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../routes.dart';

class WideBottomPanel extends StatelessWidget {
  const WideBottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.widePanelBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.config),
            tooltip: 'Configure',
          ),
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.mainMenu),
            tooltip: 'Home',
          ),
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.trending_up),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.progressionList),
            tooltip: 'Progression',
          ),
        ],
      ),
    );
  }
}
