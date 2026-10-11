import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:aikigrade/functions/utils.dart';

class ConfigService {
  static Map<String, dynamic> _config = {};
  static bool _loaded = false;
  static Future<void>? _loadingFuture;

  static Future<void> loadConfig() {
    if (_loaded) return Future.value();
    if (_loadingFuture != null) return _loadingFuture!;

    _loadingFuture = _loadConfigInternal();
    return _loadingFuture!;
  }

  /// Load config using unified JSON system
  static Future<void> _loadConfigInternal() async {
    final configExists = await hasJsonData('user_config');

    if (configExists) {
      try {
        _config = await getJsonData(fileName: 'user_config');
      } catch (e) {
        debugPrint('Corrupt config, falling back to defaults: $e');
        await _loadDefaultConfig();
        await saveConfig();
      }
    } else {
      debugPrint('No user config found, loading defaults...');
      await _loadDefaultConfig();
      await saveConfig();
    }

    _loaded = true;
  }

   /// Fallback: load default config from assets
  static Future<void> _loadDefaultConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config.json');
      _config = jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error loading default config: $e');
      _config = {};
    }
  }

  // Get a configuration value by key
  static dynamic getConfig(String key) {
    return _config[key];
  }

  // Set a configuration value
  static void setConfig(String key, dynamic value) {
    _config[key] = value;
  }

  static Future<void> saveConfig() async {
    try {
      await saveJsonData(
        fileName: 'user_config',
        jsonData: _config,
      );
    } catch (e) {
      debugPrint('Error saving config: $e');
    }
  }

  static Future<void> resetConfig() async {
    _config = {};
    _loaded = false;
    _loadingFuture = null;
    await deleteJsonData('user_config');
  }

  static String getExamDefaultName() {
    final value = _config['examDefaultName'];
    if (value == null || (value as String).trim().isEmpty) {
      return 'My Exam';
    }
    return value;
  }
}
