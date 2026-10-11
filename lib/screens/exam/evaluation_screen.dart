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
  bool _busy = false;

  late Future<Map<String, dynamic>?> _techniqueFuture;

  @override
  void initState() {
    super.initState();
    _techniqueFuture = _getTechniqueSafe(widget.fileName, widget.index);
  }

  @override
  void didUpdateWidget(covariant EvaluationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload only if the screen is reused for another technique or file
    if (oldWidget.fileName != widget.fileName ||
        oldWidget.index != widget.index) {
      _currentRating = 0;
      _techniqueFuture = _getTechniqueSafe(widget.fileName, widget.index);
    }
  }

  Future<void> _saveRating(int rating) async {
    await saveTechniqueRating(
      fileName: widget.fileName,
      index: widget.index,
      rating: rating,
    );
  }

  Future<void> _goNextNamed(
    String route,
    Map<String, Object?> arguments,
  ) async {
    if (_busy) return;
    _busy = true;
    try {
      await _saveRating(_currentRating);
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, route, arguments: arguments);
    } finally {
      _busy = false;
    }
  }

  Future<void> _finishOrNext(bool isLast) async {
    if (_busy) return;
    _busy = true;
    try {
      await _saveRating(_currentRating);
      if (!mounted) return;

      if (isLast) {
        await updateLearnJsonFile(
          learnFile: "learningJson",
          examFile: widget.fileName,
        );
        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.progressionDetail,
          arguments: {'fileName': widget.fileName},
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.evaluation,
          arguments: {'fileName': widget.fileName, 'index': widget.index + 1},
        );
      }
    } finally {
      _busy = false;
    }
  }

  Future<Map<String, dynamic>?> _getTechniqueSafe(
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
          future: _techniqueFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              logger.e('Failed to load technique', error: snapshot.error);
              return const Center(
                child: Text(
                  "Could not load this technique",
                  style: TextStyle(color: Colors.red),
                ),
              );
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

            final techniqueData = data['technique'] as Map<String, dynamic>;

            final waza = techniqueData['waza'] as String;
            final attack = techniqueData['attack'] as String;
            final technique = techniqueData['technique'] as String;
            final form = techniqueData['form'] as String? ?? '';
            final techniqueGrade = techniqueData['techniqueGrade'] as String;

            final nextWazaIndex = techniqueData['nextWazaIndex'] as int?;
            final nextAttackIndex = techniqueData['nextAttackIndex'] as int?;

            return CenteredActionScreenLayout(
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    waza,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),

                  Text(
                    attack,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),

                  Text(
                    technique,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),

                  Text(
                    form,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 40),

                  Text(
                    techniqueGrade,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

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
                      onPressed: () => _goNextNamed(AppRoutes.evaluation, {
                        'fileName': widget.fileName,
                        'index': nextWazaIndex,
                      }),
                      label: const Text('Next Waza'),
                      icon: const Icon(Icons.skip_next),
                    ),
                    const SizedBox(width: 12),
                  ],

                  if (nextAttackIndex != null) ...[
                    FloatingActionButton.extended(
                      heroTag: 'attack',
                      onPressed: () => _goNextNamed(AppRoutes.evaluation, {
                        'fileName': widget.fileName,
                        'index': nextAttackIndex,
                      }),
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
