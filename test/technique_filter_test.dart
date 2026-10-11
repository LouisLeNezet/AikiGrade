import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:aikigrade/functions/technique_filter.dart';
import 'package:aikigrade/functions/config_service.dart';
import 'package:aikigrade/functions/technique_class.dart';
import 'package:aikigrade/functions/technique_load_files.dart';
import 'package:aikigrade/functions/learn_json.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:logger/logger.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String path;
  _FakePathProvider(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();

  group('Technique class', () {
    test('Technique constructor initializes properties correctly', () {
      final technique = Technique(
        waza: 'Tachi waza',
        attack: 'Katate dori',
        technique: 'Nikyo',
        form: 'Ura',
        grade: '4 Kyu',
      );

      expect(technique.waza, 'Tachi waza');
      expect(technique.waza, technique['waza']);
      expect(technique.attack, 'Katate dori');
      expect(technique.attack, technique['attack']);
      expect(technique.technique, 'Nikyo');
      expect(technique.technique, technique['technique']);
      expect(technique.form, 'Ura');
      expect(technique.form, technique['form']);
      expect(technique.grade, '4 Kyu');
      expect(technique.grade, technique['grade']);
    });

    test('Technique toString returns formatted string', () {
      final technique = Technique(
        waza: 'Tachi waza',
        attack: 'Katate dori',
        technique: 'Nikyo',
        form: 'Ura',
        grade: '4 Kyu',
      );

      expect(technique.toString(), 
        '''Technique(
  waza: Tachi waza,
  attack: Katate dori,
  technique: Nikyo,
  form: Ura,
  grade: 4 Kyu,
  links: [],
  markdown: ,
  progression: []
)''');
    });
  });

  group('load files', () {
    test('loadAllTechniques returns techniques up to given grade', () async {
      final techniques = await loadAllTechniques('assets/csv/techniques.csv');
      final allTechGrade = await filterTechniquesGrades(techniques, '4 Kyu');

      logger.d(allTechGrade);
      expect(allTechGrade, isNotEmpty);
      expect(allTechGrade.every((t) => 
        ['5 Kyu', '4 Kyu'].contains(t.grade)), isTrue);
    });

    test('loadGradeTimes returns time per grade', () async {
      final timegrade = await loadGradeTimes('assets/csv/grade_time.csv');

      expect(timegrade, isA<Map<String, Map<String, int>>>());
      expect(timegrade.containsKey('5 Kyu'), isTrue);
      expect(timegrade['5 Kyu']!.containsKey('Tachi waza'), isTrue);
      expect(timegrade['5 Kyu']!['Tachi waza'], 600);
    });

    test('loads and parses ordering correctly from CSV', () async {
      final result = await loadOrderTechnique('assets/csv/techniques_ordering.csv');

      expect(result, isA<Map<String, Map<String, int>>>());
      // Example assertions, change based on your CSV content
      expect(result.containsKey('Attack'), isTrue);
      expect(result['Attack']!.containsKey('Shomen uchi'), isTrue);
      expect(result['Attack']!['Shomen uchi'], 10);

      expect(result['Waza']!.containsKey('Tachi waza'), isTrue);
      expect(result['Waza']!['Tachi waza'], 3);
    });
  });

  test('orderCompare', () async {
    final orderMap = {
      'a': 1,
      'b': 2,
      'c': 3,
    };

    expect(orderCompare('a', 'b', orderMap), lessThan(0));
    expect(orderCompare('b', 'a', orderMap), greaterThan(0));
    expect(orderCompare('c', 'c', orderMap), equals(0));

    final orders = await loadOrderTechnique('assets/csv/techniques_ordering.csv');
    final positionOrder = orders['Waza']!;
    final orderPosition = orderCompare("Tachi waza", "Suwari waza", positionOrder);
    expect(orderPosition, 1, reason: 'Tachi waza should come after Suwari waza');
  });

  test('orderTechniques', () async {
    final techniques = await loadAllTechniques('assets/csv/techniques.csv');
    final allTechGrade = await filterTechniquesGrades(techniques, '4 Kyu');
    final orderedTechniques = await orderTechniques(lstTechniques: allTechGrade);

    expect(orderedTechniques, isNotEmpty);

    expect(orderedTechniques[0].waza, 'Suwari waza');
    expect(orderedTechniques[0].attack, 'Ai hanmi katate dori');
    expect(orderedTechniques[0].technique, 'Ikkyo');
    expect(orderedTechniques[0].form, 'Omote');
    expect(orderedTechniques[0].grade, '4 Kyu');
  });

  group('subset techniques', () {
    late Directory tempDir;
  
    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('config_test');
      PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    });

    tearDownAll(() async {
      await tempDir.delete(recursive: true);
    });

    test('subsetTechniques returns correct number of techniques per waza', () async {
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

      expect(subset, isNotEmpty);

      // Example: 3 positions = tachi, suwari, hanmi → check distribution
      final tachi = subset.where((t) => t.waza == 'Tachi waza');
      final suwari = subset.where((t) => t.waza == 'Suwari waza');
      final hanmi = subset.where((t) => t.waza == 'Hanmi Handachi waza');

      expect(tachi.length, 8);
      expect(suwari.length, 2);
      expect(hanmi.length, 0);
    });
  });
}