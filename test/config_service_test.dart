import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:aikigrade/functions/config_service.dart';

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

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('config_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  group('ConfigService', () {
    test('ConfigService load get and set', () async {
      await ConfigService.resetConfig();
      await ConfigService.loadConfig();
      final appVersion = ConfigService.getConfig('appVersion');

      expect(appVersion, isNotNull);
      expect(appVersion, isA<String>());
      expect(appVersion, '0.1.0+1');

      final examDefaultName = ConfigService.getConfig('examDefaultName');
      expect(examDefaultName, "My Exam");

      ConfigService.setConfig('examDefaultName', 'NewDefaultName');
      await ConfigService.saveConfig();

      await ConfigService.loadConfig();
      final newDefaultName = ConfigService.getConfig('examDefaultName');
      expect(newDefaultName, isNotNull);
      expect(newDefaultName, isA<String>());
      expect(newDefaultName, 'NewDefaultName');
    });
  });
}
