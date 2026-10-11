import 'package:flutter/material.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/layouts/list_screen_layout.dart';
import '../../widgets/rating_emoticon.dart';
import '../../routes.dart';
import 'package:aikigrade/functions/utils.dart';
import 'package:aikigrade/functions/learn_json.dart';

/// Latest rating of a technique, or 0 if it was never evaluated.
/// Null-safe: a missing or malformed `progression` never crashes the build.
int _latestRating(Map<String, dynamic> technique) {
  final progression = technique['progression'];
  if (progression is List && progression.isNotEmpty) {
    final last = progression.last;
    if (last is Map) {
      return (last['rating'] as num?)?.toInt() ?? 0;
    }
  }
  return 0;
}

class LearnMenuScreen extends StatefulWidget {
  final String fileName;

  const LearnMenuScreen({required this.fileName, super.key});

  @override
  State<LearnMenuScreen> createState() => _LearnMenuScreenState();
}

class _LearnMenuScreenState extends State<LearnMenuScreen> {
  late Future<Map<String, dynamic>> _learnData;
  String _searchQuery = '';
  String _sortField = 'grade';
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _learnData = getJsonData(fileName: widget.fileName);
  }

  void _setSort(String field) {
    setState(() {
      if (_sortField == field) {
        _ascending = !_ascending; // Toggle order if same field
      } else {
        _sortField = field;
        _ascending = true; // Default to ascending on new field
      }
    });
  }

  /// Applies the search filter and the sort order to the loaded techniques.
  List<Map<String, dynamic>> _visibleTechniques(Map<String, dynamic> data) {
    var list = List<Map<String, dynamic>>.from(data.values);

    final queryWords = _searchQuery
        .toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (queryWords.isNotEmpty) {
      list = list.where((technique) {
        final text = [
          technique['waza'],
          technique['attack'],
          technique['technique'],
          technique['form'],
        ].where((e) => e != null).join(' ').toLowerCase();

        return queryWords.every((word) => text.contains(word));
      }).toList();
    }

    list.sort((a, b) => compareTechniques(a, b, _sortField, _ascending));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _learnData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Error loading learning data: ${snapshot.error}');
            return const Center(
              child: Text('Could not load your learning data.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final learnList = _visibleTechniques(snapshot.data!);

          return ListScreenLayout(
            header: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search techniques',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: PopupMenuButton<String>(
                        onSelected: _setSort,
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'rating', child: Text('Rating')),
                          PopupMenuItem(value: 'grade', child: Text('Grade')),
                          PopupMenuItem(value: 'waza', child: Text('Waza')),
                          PopupMenuItem(value: 'attack', child: Text('Attack')),
                          PopupMenuItem(
                            value: 'technique',
                            child: Text('Technique'),
                          ),
                        ],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _sortField[0].toUpperCase() +
                                  _sortField.substring(1),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() => _ascending = !_ascending);
                              },
                              child: Icon(
                                _ascending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Techniques:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            child: learnList.isEmpty
                ? const Center(child: Text('No technique matches your search.'))
                : ListView.builder(
                    itemCount: learnList.length,
                    itemBuilder: (context, index) {
                      final technique = learnList[index];
                      final form = (technique['form'] ?? '').toString();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            '${technique['waza']} - ${technique['attack']} - '
                            '${technique['technique']}',
                          ),
                          subtitle: Text(
                            '${form.isNotEmpty ? 'Form: $form | ' : ''}'
                            'Grade: ${technique['techniqueGrade']}',
                          ),
                          trailing: RatingEmoticon(
                            rating: _latestRating(technique),
                            showValue: false,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.techniqueDetail,
                              arguments: technique,
                            );
                          },
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
