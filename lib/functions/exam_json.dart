import 'dart:io';
import 'package:aikigrade/functions/technique_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import './technique_filter.dart';
import './config_service.dart';
import './utils.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

Future<String> createExamJsonFile({
  required String grade,
  required String examName,
  Future<String> Function()? getAppVersionFn,
  Future<List<Technique>> Function({
    required String grade,
    required String gradeTimeCsvPath,
  })?
  subsetTechniquesFn,
}) async {
  try {
    final appVersion = await (getAppVersionFn?.call() ?? getAppVersion());

    final now = DateTime.now();
    final String date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String hour =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Use your getOrderedTechniques function
    final techniques =
        await (subsetTechniquesFn?.call(
              grade: grade,
              gradeTimeCsvPath: 'assets/csv/grade_time.csv',
            ) ??
            subsetTechniques(
              grade: grade,
              gradeTimeCsvPath: 'assets/csv/grade_time.csv',
            ));

    final wazas = techniques.map((t) => t.waza).toList();
    final nextWazaIndices = List<int?>.filled(techniques.length, null);

    for (int i = 0; i < techniques.length; i++) {
      final currentWaza = wazas[i];
      for (int j = i + 1; j < techniques.length; j++) {
        if (wazas[j] != currentWaza) {
          nextWazaIndices[i] = j;
          break;
        }
      }
    }

    final attacks = techniques.map((t) => t.attack).toList();
    final nextAttackIndices = List<int?>.filled(techniques.length, null);

    for (int i = 0; i < techniques.length; i++) {
      final currentAttack = attacks[i];
      for (int j = i + 1; j < techniques.length; j++) {
        if (attacks[j] != currentAttack) {
          nextAttackIndices[i] = j;
          break;
        }
      }
    }

    final List<Map<String, dynamic>> evaluationList = [];
    final timePerTechnique = ConfigService.getConfig('timePerTechnique') ?? 60;

    int index = 0;
    for (int i = 0; i < techniques.length; i++) {
      final technique = techniques[i];
      evaluationList.add({
        "waza": technique.waza,
        "attack": technique.attack,
        "technique": technique.technique,
        "form": technique.form,
        "techniqueGrade": technique.grade,
        "duration": timePerTechnique,
        "rating": 0,
        "index": index,
        "nextWazaIndex": nextWazaIndices[i],
        "nextAttackIndex": nextAttackIndices[i],
      });
      index++;
    }

    final tachi = techniques.where((t) => t.waza == 'Tachi waza');
    final suwari = techniques.where((t) => t.waza == 'Suwari waza');
    final hanmi = techniques.where((t) => t.waza == 'Hanmi Handachi waza');

    // Final JSON structure
    final Map<String, dynamic> examJson = {
      "metadata": {
        "date": date,
        "hour": hour,
        "grade": grade,
        "examName": examName,
        "version": appVersion,
        "size": {
          "Suwari waza": suwari.length,
          "Hanmi Handachi waza": hanmi.length,
          "Tachi waza": tachi.length,
          "total": techniques.length,
        },
      },
      "evaluation": evaluationList,
    };

    // Save JSON to file
    final String safeExamName = examName.replaceAll(
      ' ',
      '_',
    ); // Avoid spaces in filenames
    final String dateTimePrefix =
        '${date.replaceAll('-', '_')}_${hour.replaceAll(':', '_')}';
    final String safeFileName = 'exam_${dateTimePrefix}_$safeExamName';

    logger.d(examJson);

    await saveJsonData(fileName: safeFileName, jsonData: examJson);
    return safeFileName;
  } catch (e, stack) {
    throw Exception("Failed to create exam JSON: $e\n$stack");
  }
}

Future<Map<String, dynamic>> getTechniqueByIndex({
  required String fileName,
  required int index,
}) async {
  try {
    final Map<String, dynamic> data = await getJsonData(fileName: fileName);

    if (!data.containsKey('evaluation') || data['evaluation'] is! List) {
      throw Exception(
        'Invalid exam file: missing or bad "evaluation" section.',
      );
    }

    final List<dynamic> evaluationList = data['evaluation'];

    final technique = evaluationList.firstWhere(
      (item) => item['index'] == index,
      orElse: () => throw Exception('No technique found for index $index.'),
    );

    return Map<String, dynamic>.from(technique);
  } catch (e, stack) {
    throw Exception('Failed to get technique: $e\n$stack');
  }
}

Future<Map<String, dynamic>> getExamMetaData({required String fileName}) async {
  try {
    final Map<String, dynamic> data = await getJsonData(fileName: fileName);

    if (data.containsKey('metadata') &&
        data['metadata'] is Map<String, dynamic>) {
      final metadata = data['metadata'] as Map<String, dynamic>;
      return metadata;
    } else {
      throw Exception('Invalid exam file: missing "metadata" section.');
    }
  } catch (e, stack) {
    throw Exception('Failed to get exam length: $e\n$stack');
  }
}

Future<T> getExamMetadataKey<T>({
  required String fileName,
  required String key,
}) async {
  final examData = await getJsonData(fileName: fileName);

  if (!examData.containsKey('metadata')) {
    throw Exception('Failed to get exam metadata: Missing "metadata" section.');
  }

  final metadata = examData['metadata'];
  if (metadata is! Map<String, dynamic>) {
    throw Exception(
      'Failed to get exam metadata: Expected "metadata" to be of type Map<String, dynamic>, but got ${metadata.runtimeType}.',
    );
  }

  final value = metadata[key];
  if (value is! T) {
    throw Exception(
      'Failed to get exam metadata key: Expected "$key" to be of type $T, but got ${value.runtimeType}.',
    );
  }

  return value;
}

Future<Map<String, dynamic>> getTechniqueAndExamSize({
  required String fileName,
  required int index,
}) async {
  try {
    final technique = await getTechniqueByIndex(
      fileName: fileName,
      index: index,
    );
    final metadata = await getExamMetaData(fileName: fileName);
    final sizeExam = metadata['size']['total'] as int;

    return {'technique': technique, 'sizeExam': sizeExam};
  } catch (e, stack) {
    throw Exception('Failed to get technique and size: $e\n$stack');
  }
}

Future<void> saveTechniqueRating({
  required String fileName,
  required int index,
  required int rating,
}) async {
  final examData = await getJsonData(fileName: fileName);
  final evaluation = examData['evaluation'] as List<dynamic>;
  evaluation[index]['rating'] = rating;
  saveJsonData(fileName: fileName, jsonData: examData);
}

Future<List<String>> loadExamFiles() async {
  if (kIsWeb) {
    // On the Web: Load from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    logger.d('Stored keys in SharedPreferences: $keys');

    // Filter keys to find those representing exam JSON files
    final examFiles = keys.where((key) => key.startsWith('exam_')).toList();
    return examFiles;
  } else {
    // On Mobile: Load from the filesystem
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> files = appDocDir.listSync();

    // Filter only .json files
    final examFiles =
        files
            .where(
              (file) =>
                  file.path.endsWith('.json') &&
                  file.path.split('/').last.startsWith('exam_'),
            )
            .map((file) => file.path.split('/').last.replaceAll('.json', ''))
            .toList()
          ..sort((a, b) => b.compareTo(a)); // Sort in decreasing order
    logger.d("Filtered exam files: $examFiles");
    return examFiles;
  }
}
