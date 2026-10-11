import 'dart:io';
import 'package:aikigrade/functions/config_service.dart';
import 'package:aikigrade/functions/technique_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:aikigrade/functions/learn_json.dart';
import 'package:aikigrade/functions/exam_json.dart';
import 'package:aikigrade/functions/utils.dart';
import 'package:logger/logger.dart';

// --- Fake path_provider ---
class _FakePathProvider extends PathProviderPlatform {
  final String path;
  _FakePathProvider(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  final logger = Logger();

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('exam_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  test('creates a JSON file with real data', () async {
    await ConfigService.loadConfig();
    ConfigService.setConfig('prioritizeBy', 'attack');
    ConfigService.setConfig('timePerTechnique', 70);
    await ConfigService.saveConfig();

    final fileNameLearn = await createLearnJsonFile(
      path: 'assets/csv/techniques.csv',
    );

    // Assert
    final decoded = await getJsonData(fileName: fileNameLearn);

    expect(
      decoded['Suwari waza|Ai hanmi katate dori|Ikkyo|Omote']['waza'],
      "Suwari waza",
    );
    expect(
      decoded['Suwari waza|Ai hanmi katate dori|Ikkyo|Omote']['attack'],
      "Ai hanmi katate dori",
    );
    expect(
      decoded['Suwari waza|Ai hanmi katate dori|Ikkyo|Omote']['technique'],
      "Ikkyo",
    );
    expect(
      decoded['Suwari waza|Ai hanmi katate dori|Ikkyo|Omote']['form'],
      "Omote",
    );
    expect(
      decoded['Suwari waza|Ai hanmi katate dori|Ikkyo|Omote']['techniqueGrade'],
      "4 Kyu",
    );
    expect(
      decoded['Suwari waza|Ai hanmi katate dori|Ikkyo|Omote']['progression'],
      [],
    );

    final subset = await subsetTechniques(
      grade: '4 Kyu',
      gradeTimeCsvPath: 'assets/csv/grade_time.csv',
    );

    const fakeGrade = '4 Kyu';
    const fakeExamName = 'My Exam';
    const fakeVersion = '1.0.0';
    final fileNameExam = await createExamJsonFile(
      grade: fakeGrade,
      examName: fakeExamName,
      getAppVersionFn: () async => fakeVersion,
      subsetTechniquesFn: ({required grade, required gradeTimeCsvPath}) async =>
          subset,
    );

    await saveTechniqueRating(fileName: fileNameExam, index: 0, rating: 5);

    final decodedUpdExam = await getJsonData(fileName: fileNameExam);
    final examDate = decodedUpdExam["metadata"]["date"];
    final examHour = decodedUpdExam["metadata"]["hour"];
    final dateHour = '$examDate $examHour';

    expect(decodedUpdExam['evaluation'][0]["rating"], 5);

    final fileNameLearnUpd = await updateLearnJsonFile(
      learnFile: fileNameLearn,
      examFile: fileNameExam,
    );
    final decodedUpdLearn = await getJsonData(fileName: fileNameLearnUpd);
    logger.d(decodedUpdLearn['Suwari waza|Ai hanmi katate dori|Ikkyo|Omote']);
    expect(
      decodedUpdLearn['Suwari waza|Ai hanmi katate dori|Ikkyo|Omote']['progression'],
      [
        {"date": dateHour, "rating": 5},
      ],
    );
  });
}
