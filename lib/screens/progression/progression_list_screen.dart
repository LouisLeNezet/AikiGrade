import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../routes.dart';
import '../../functions/exam_json.dart';
import '../../functions/utils.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/layouts/list_screen_layout.dart';
import '../../widgets/confirm_dialog.dart';

/// What the list needs to display one exam.
class _ExamSummary {
  const _ExamSummary({
    required this.fileName,
    required this.examName,
    required this.date,
    required this.hour,
    required this.grade,
  });

  final String fileName;
  final String examName;
  final String date;
  final String hour;
  final String grade;
}

class ProgressionListScreen extends StatefulWidget {
  const ProgressionListScreen({super.key});

  @override
  State<ProgressionListScreen> createState() => _ProgressionListScreenState();
}

class _ProgressionListScreenState extends State<ProgressionListScreen> {
  late Future<List<_ExamSummary>> _summariesFuture;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _summariesFuture = _loadSummaries();
  }

  /// Reads each exam file once and extracts the metadata shown in the list.
  Future<List<_ExamSummary>> _loadSummaries() async {
    final files = await loadExamFiles();

    return Future.wait(
      files.map((fileName) async {
        try {
          final data = await getJsonData(fileName: fileName);
          final meta = data['metadata'] as Map<String, dynamic>;
          return _ExamSummary(
            fileName: fileName,
            examName: meta['examName'] as String? ?? 'Exam',
            date: meta['date'] as String? ?? '-',
            hour: meta['hour'] as String? ?? '-',
            grade: meta['grade'] as String? ?? '-',
          );
        } catch (e) {
          // One unreadable file must not hide the whole history, and the
          // user should still be able to delete it.
          logger.e('Could not read exam file $fileName', error: e);
          return _ExamSummary(
            fileName: fileName,
            examName: 'Unreadable exam',
            date: '-',
            hour: '-',
            grade: '-',
          );
        }
      }),
    );
  }

  Future<void> _confirmAndDelete(_ExamSummary exam) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Delete Exam',
      content: 'This will permanently delete this exam from your progression.',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );
    if (confirm != true) return;

    await deleteJsonData(exam.fileName);
    if (!mounted) return;

    setState(() {
      _summariesFuture = _loadSummaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: FutureBuilder<List<_ExamSummary>>(
        future: _summariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            logger.e('Error loading exams', error: snapshot.error);
            return const Center(child: Text('Could not load the exams.'));
          }

          final exams = snapshot.data ?? [];

          if (exams.isEmpty) {
            return const Center(child: Text('No exam yet available.'));
          }

          return ListScreenLayout(
            header: const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Progression History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(exam.examName),
                    subtitle: Text(
                      'Date: ${exam.date}\n'
                      'Hour: ${exam.hour}\n'
                      'Grade: ${exam.grade}',
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.progressionDetail,
                        arguments: {'fileName': exam.fileName},
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmAndDelete(exam),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
