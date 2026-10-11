import 'package:aikigrade/functions/learn_json.dart';
import 'package:flutter/material.dart';
import '../../functions/exam_json.dart';
import '../../routes.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/layouts/centered_action_screen_layout.dart';
import '../../widgets/rating_selector.dart';
import 'package:logger/logger.dart';

class EvaluationScreen extends StatefulWidget {
  final String fileName;
  final int index;

  const EvaluationScreen({
    super.key,
    required this.fileName,
    required this.index,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  int _currentRating = 0;
  final Logger logger = Logger();

  Future<void> _saveRating(int rating) async {
    await saveTechniqueRating(
      fileName: widget.fileName,
      index: widget.index,
      rating: rating,
    );
  }

  Future<void> _goNextNamed(String route, Map<String, Object?> arguments) async {
    await _saveRating(_currentRating);
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      route,
      arguments: arguments,
    );
  }

  Future<void> _finishOrNext(bool isLast) async {
    await _saveRating(_currentRating);
    if (!mounted) return;

    if (isLast) {
      updateLearnJsonFile(
        learnFile: "learningJson",
        examFile: widget.fileName,
      );

      Navigator.pushNamed(
        context,
        AppRoutes.progressionDetail,
        arguments: {'fileName': widget.fileName},
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.evaluation,
        arguments: {
          'fileName': widget.fileName,
          'index': widget.index + 1,
        },
      );
    }
  }

  Future<Map<String, dynamic>?> getTechniqueSafe(
    String fileName,
    int index,
  ) async {
    return getTechniqueAndExamSize(
      fileName: fileName,
      index: index,
    ).timeout(const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      showWidePanel: false,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: getTechniqueSafe(widget.fileName, widget.index),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text(
                  "No data found",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final data = snapshot.data!;
            final examSize = data['sizeExam'] as int;
            final isLast = widget.index == examSize - 1;

            final techniqueData =
                data['technique'] as Map<String, dynamic>;

            final waza = techniqueData['waza'] as String;
            final attack = techniqueData['attack'] as String;
            final technique = techniqueData['technique'] as String;
            final form = techniqueData['form'] as String? ?? '';
            final techniqueGrade =
                techniqueData['techniqueGrade'] as String;

            final nextWazaIndex = techniqueData['nextWazaIndex'] as int?;
            final nextAttackIndex = techniqueData['nextAttackIndex'] as int?;

            logger.d(techniqueData);

            return CenteredActionScreenLayout(
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(waza,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),

                  Text(attack,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),

                  Text(technique,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),

                  Text(form,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),

                  const SizedBox(height: 40),

                  Text(techniqueGrade,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),

                  const SizedBox(height: 10),

                  Text(
                    "Technique: ${widget.index + 1} / $examSize",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 20),

                  RatingSelector(
                    rating: _currentRating,
                    onChanged: (rating) {
                      setState(() => _currentRating = rating);
                    },
                  ),
                ],
              ),

              bottom: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (nextWazaIndex != null) ...[
                    FloatingActionButton.extended(
                      heroTag: 'waza',
                      onPressed: () => _goNextNamed(
                        AppRoutes.evaluation,
                        {
                          'fileName': widget.fileName,
                          'index': nextWazaIndex,
                        },
                      ),
                      label: const Text('Next Waza'),
                      icon: const Icon(Icons.skip_next),
                    ),
                    const SizedBox(width: 12),
                  ],

                  if (nextAttackIndex != null) ...[
                    FloatingActionButton.extended(
                      heroTag: 'attack',
                      onPressed: () => _goNextNamed(
                        AppRoutes.evaluation,
                        {
                          'fileName': widget.fileName,
                          'index': nextAttackIndex,
                        },
                      ),
                      label: const Text('Next Attack'),
                      icon: const Icon(Icons.skip_next),
                    ),
                    const SizedBox(width: 12),
                  ],

                  FloatingActionButton.extended(
                    heroTag: 'finish',
                    onPressed: () => _finishOrNext(isLast),
                    label: Text(isLast ? 'Finish Exam' : 'Next'),
                    icon: Icon(isLast ? Icons.check : Icons.navigate_next),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}