import 'dart:io';
import 'package:aikigrade/functions/technique_class.dart';
import 'package:aikigrade/functions/config_service.dart';
import 'package:aikigrade/functions/technique_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:aikigrade/functions/exam_json.dart';
import 'package:aikigrade/functions/learn_json.dart';
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

  group('createExamJsonFile', () {
    test('creates a JSON file with correct content', () async {
      // Arrange
      const fakeGrade = '4 Kyu';
      const fakeExamName = 'My Exam';
      const fakeVersion = '1.0.0';
      await ConfigService.loadConfig();
      ConfigService.setConfig('prioritizeBy', 'attack');
      ConfigService.setConfig('timePerTechnique', 60);
      ConfigService.saveConfig();
      
      final technique1 = Technique(
        waza: 'Position1',
        attack: 'Attack1',
        technique: 'Technique1',
        form: 'Form1',
        grade: fakeGrade,
      );
      final technique2 = Technique(
        waza: 'Position1',
        attack: 'Attack1',
        technique: 'Technique2',
        form: 'Form1',
        grade: fakeGrade,
      );
      final technique3 = Technique(
        waza: 'Position1',
        attack: 'Attack2',
        technique: 'Technique2',
        form: 'Form2',
        grade: fakeGrade,
      );
      final technique4 = Technique(
        waza: 'Position2',
        attack: 'Attack2',
        technique: 'Technique2',
        form: 'Form2',
        grade: fakeGrade,
      );

      // Act
      final fileName = await createExamJsonFile(
        grade: fakeGrade,
        examName: fakeExamName,
        getAppVersionFn: () async => fakeVersion,
        subsetTechniquesFn: ({required grade, required gradeTimeCsvPath}) async => [
          technique1,
          technique2,
          technique3,
          technique4,
        ],
      );

      // Assert
      final decoded = await getJsonData(fileName: fileName);

      logger.d(decoded);

      expect(decoded['metadata']['grade'], fakeGrade);
      expect(decoded['metadata']['examName'], fakeExamName);
      expect(decoded['metadata']['version'], fakeVersion);
      expect(decoded['metadata']['size']['total'], 4);

      expect(decoded['evaluation'], isA<List>());
      expect(decoded['evaluation'].length, 4);

      expect(decoded['evaluation'][0]['waza'], 'Position1');
      expect(decoded['evaluation'][3]['waza'], 'Position2');
      expect(decoded['evaluation'][1]['duration'], 60);

      // Check nextPositionIndex
      expect(decoded['evaluation'][0]['nextWazaIndex'], 3);
      expect(decoded['evaluation'][1]['nextWazaIndex'], 3);
      expect(decoded['evaluation'][2]['nextWazaIndex'], 3);
      expect(decoded['evaluation'][3]['nextWazaIndex'], null);

      expect(fileName.endsWith('_My_Exam'), isTrue);
    });
  });

  test('creates a JSON file with real data', () async {
      await ConfigService.loadConfig();
      ConfigService.setConfig('prioritizeBy', 'attack');
      ConfigService.setConfig('timePerTechnique', 70);
      ConfigService.saveConfig();

      await createLearnJsonFile(
        path: 'assets/csv/techniques.csv',
      );

      final subset = await subsetTechniques(
        grade: '4 Kyu',
        gradeTimeCsvPath: 'assets/csv/grade_time.csv',
      );

      const fakeGrade = '4 Kyu';
      const fakeExamName = 'My Exam';
      const fakeVersion = '1.0.0';
      final fileName = await createExamJsonFile(
        grade: fakeGrade,
        examName: fakeExamName,
        getAppVersionFn: () async => fakeVersion,
        subsetTechniquesFn: ({required grade, required gradeTimeCsvPath}) async => subset,
      );

      // Assert
      final decoded = await getJsonData(fileName: fileName);

      logger.d(decoded);

      expect(decoded['metadata']['grade'], fakeGrade);
      expect(decoded['metadata']['examName'], fakeExamName);
      expect(decoded['metadata']['version'], fakeVersion);
      expect(decoded['metadata']['size']['total'], 10);

      expect(decoded['evaluation'], isA<List>());
      expect(decoded['evaluation'].length, 10);

      expect(decoded['evaluation'][0]['waza'], 'Suwari waza');
      expect(decoded['evaluation'][0]['nextWazaIndex'], 2);
      expect(decoded['evaluation'][0]['nextAttackIndex'], 1);

      await saveTechniqueRating(fileName: fileName, index: 1, rating: 3);
      final decodedUpd = await getJsonData(fileName: fileName);
      logger.d(decodedUpd);
      expect(decodedUpd['evaluation'][1]['rating'], 3);
    });
}
