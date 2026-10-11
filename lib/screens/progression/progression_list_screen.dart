import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../routes.dart';
import '../../functions/exam_json.dart';
import '../../functions/utils.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/layouts/list_screen_layout.dart';
import '../../widgets/confirm_dialog.dart';

class ProgressionListScreen extends StatefulWidget {
  const ProgressionListScreen({super.key});

  @override
  State<ProgressionListScreen> createState() => _ProgressionListScreenState();
}

class _ProgressionListScreenState extends State<ProgressionListScreen> {
  late Future<List<String>> _examFilesFuture;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _examFilesFuture = loadExamFiles();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: FutureBuilder<List<String>>(
        future: _examFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading exams: ${snapshot.error}'),
            );
          }

          final examFiles = snapshot.data ?? [];

          if (examFiles.isEmpty) {
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
              itemCount: examFiles.length,
              itemBuilder: (context, index) {
                final fileName = examFiles[index];

                return FutureBuilder<Map<String, String>>(
                  future:
                      Future.wait([
                        getExamMetadataKey<String>(
                          fileName: fileName,
                          key: 'examName',
                        ),
                        getExamMetadataKey<String>(
                          fileName: fileName,
                          key: 'date',
                        ),
                        getExamMetadataKey<String>(
                          fileName: fileName,
                          key: 'hour',
                        ),
                        getExamMetadataKey<String>(
                          fileName: fileName,
                          key: 'grade',
                        ),
                      ]).then(
                        (values) => {
                          'examName': values[0],
                          'date': values[1],
                          'hour': values[2],
                          'grade': values[3],
                        },
                      ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final metadata = snapshot.data!;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(metadata['examName']!),
                        subtitle: Text(
                          'Date: ${metadata['date']}\n'
                          'Hour: ${metadata['hour']}\n'
                          'Grade: ${metadata['grade']}',
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.progressionDetail,
                            arguments: {'fileName': fileName},
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showConfirmDialog(
                              context: context,
                              title: 'Delete Exam',
                              content:
                                  'This will permanently delete this exam from your progression.',
                              confirmText: 'Delete',
                              confirmColor: Colors.red,
                            );
                            if (confirm == true) {
                              await deleteJsonData(fileName);
                              setState(() {
                                _examFilesFuture = loadExamFiles();
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
