import 'package:flutter/material.dart';
import 'package:aikigrade/widgets/scaffold_with_wide_bottom_panel.dart';
import 'package:aikigrade/widgets/layouts/page_layout.dart';
import 'package:aikigrade/routes.dart';
import 'package:aikigrade/constants/colors.dart';
import 'package:aikigrade/functions/learn_json.dart';


class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _initializeLearnJsonFile() {
    createLearnJsonFile(path: 'assets/csv/techniques.csv');
  }

  @override
  Widget build(BuildContext context) {
    _initializeLearnJsonFile();
    return ScaffoldWithWideBottomPanel(
      body: PageLayout(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Two columns side-by-side
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.examMenu),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset('assets/images/exam.png', height: 200, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.buttonColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Exam',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.learnMenu),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset('assets/images/learn.png', height: 200, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.buttonColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Learn',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lightbulb icon button at the top-right
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                tooltip: 'More Info',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.moreInfos),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
