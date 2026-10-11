import 'package:aikigrade/functions/utils.dart';
import 'package:flutter/material.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/layouts/list_screen_layout.dart';
import '../../widgets/rating_emoticon.dart';
import '../../widgets/header_chip.dart';

class ProgressionDetailScreen extends StatefulWidget {
  final String fileName;

  const ProgressionDetailScreen({required this.fileName, super.key});

  @override
  State<ProgressionDetailScreen> createState() =>
      _ProgressionDetailScreenState();
}

class _ProgressionDetailScreenState extends State<ProgressionDetailScreen> {
  late Future<Map<String, dynamic>> _examData;

  @override
  void initState() {
    super.initState();
    _examData = getJsonData(fileName: widget.fileName);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _examData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Error loading exam: ${snapshot.error}');
            return const Center(child: Text('Could not load this exam.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final metadata = snapshot.data!['metadata'] as Map<String, dynamic>;

          final evaluationList = List<Map<String, dynamic>>.from(
            snapshot.data!['evaluation'],
          );

          return ListScreenLayout(
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MAIN TITLE SECTION
                Center(
                  child: Text(
                    metadata['examName'] ?? 'Exam',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                const Divider(),

                const SizedBox(height: 12),

                // METADATA GRID-LIKE BLOCK
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    HeaderChip(label: 'Date', value: metadata['date']),
                    HeaderChip(label: 'Hour', value: metadata['hour']),
                    HeaderChip(label: 'Grade', value: metadata['grade']),
                    HeaderChip(
                      label: 'Size',
                      value: '${metadata['size']['total']}',
                    ),
                    HeaderChip(label: 'Version', value: metadata['version']),
                  ],
                ),

                const SizedBox(height: 20),

                // SECTION TITLE
                Center(
                  child: Text(
                    'Techniques',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),

            child: ListView(
              children: [
                ...evaluationList.map(
                  (technique) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        '${technique['waza']} - ${technique['technique']}',
                      ),
                      subtitle: Text(
                        'Attack: ${technique['attack']}\n'
                        'Form: ${technique['form']} | Grade: ${technique['techniqueGrade']}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Index: ${technique['index']}'),
                          const SizedBox(height: 4),
                          RatingEmoticon(
                            rating: (technique['rating'] as num?)?.toInt() ?? 0,
                            showValue: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
