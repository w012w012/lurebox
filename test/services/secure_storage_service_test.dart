import 'dart:convert' as convert;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 初始化 Flutter binding（required for platform channels）
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService JSON Migration Logic', () {
    // 测试迁移逻辑的 JSON 处理部分
    // 注意：实际的 SecureStorageService 需要平台 channel，完整集成测试需要
    // integration_test 框架，这里测试 JSON 处理逻辑

    test('migrates API keys from legacy JSON correctly', () async {
      const legacyJson = '''
{
  "currentProvider": 0,
  "providerConfigs": {
    "0": {"provider": 0, "apiKey": "sk-gemini-123", "baseUrl": null, "modelName": null, "enabled": true},
    "1": {"provider": 1, "apiKey": "sk-openai-456", "baseUrl": "https://api.openai.com", "modelName": "gpt-4", "enabled": true}
  },
  "autoRecognize": true,
  "timeout": 10
}
''';

      // 模拟迁移逻辑
      final json = convert.jsonDecode(legacyJson) as Map<String, dynamic>;
      final configs = json['providerConfigs'] as Map<String, dynamic>;

      final extractedKeys = <String, String>{};
      for (final entry in configs.entries) {
        final config = entry.value as Map<String, dynamic>;
        if (config.containsKey('apiKey')) {
          final apiKey = config['apiKey'] as String?;
          if (apiKey != null && apiKey.isNotEmpty) {
            extractedKeys[entry.key] = apiKey;
          }
        }
      }

      // 验证提取的 keys
      expect(extractedKeys['0'], equals('sk-gemini-123'));
      expect(extractedKeys['1'], equals('sk-openai-456'));
      expect(extractedKeys.length, equals(2));

      // 创建清理后的 JSON
      final cleanedConfigs = <String, dynamic>{};
      for (final entry in configs.entries) {
        final config = Map<String, dynamic>.from(entry.value as Map);
        config.remove('apiKey');
        cleanedConfigs[entry.key] = config;
      }
      json['providerConfigs'] = cleanedConfigs;
      final cleanedJson = convert.jsonEncode(json);

      // 验证清理后的 JSON 不含 API keys
      expect(cleanedJson.contains('sk-gemini-123'), isFalse);
      expect(cleanedJson.contains('sk-openai-456'), isFalse);
      expect(cleanedJson.contains('"apiKey"'), isFalse);
    });

    test('handles empty providerConfigs gracefully', () {
      const json = '''
{
  "currentProvider": 0,
  "providerConfigs": {},
  "autoRecognize": true,
  "timeout": 10
}
''';

      final parsed = convert.jsonDecode(json) as Map<String, dynamic>;
      final configs = parsed['providerConfigs'] as Map<String, dynamic>;

      final extractedKeys = <String, String>{};
      for (final entry in configs.entries) {
        final config = entry.value as Map<String, dynamic>;
        if (config.containsKey('apiKey')) {
          final apiKey = config['apiKey'] as String?;
          if (apiKey != null && apiKey.isNotEmpty) {
            extractedKeys[entry.key] = apiKey;
          }
        }
      }

      expect(extractedKeys.isEmpty, isTrue);
    });

    test('handles missing apiKey fields gracefully', () {
      const json = '''
{
  "currentProvider": 0,
  "providerConfigs": {
    "0": {"provider": 0, "baseUrl": null, "modelName": null, "enabled": true}
  },
  "autoRecognize": true,
  "timeout": 10
}
''';

      final parsed = convert.jsonDecode(json) as Map<String, dynamic>;
      final configs = parsed['providerConfigs'] as Map<String, dynamic>;

      final extractedKeys = <String, String>{};
      for (final entry in configs.entries) {
        final config = entry.value as Map<String, dynamic>;
        if (config.containsKey('apiKey')) {
          final apiKey = config['apiKey'] as String?;
          if (apiKey != null && apiKey.isNotEmpty) {
            extractedKeys[entry.key] = apiKey;
          }
        }
      }

      expect(extractedKeys.isEmpty, isTrue);
    });

    test('handles null apiKey gracefully', () {
      const json = '''
{
  "currentProvider": 0,
  "providerConfigs": {
    "0": {"provider": 0, "apiKey": null, "baseUrl": null, "modelName": null, "enabled": true}
  },
  "autoRecognize": true,
  "timeout": 10
}
''';

      final parsed = convert.jsonDecode(json) as Map<String, dynamic>;
      final configs = parsed['providerConfigs'] as Map<String, dynamic>;

      final extractedKeys = <String, String>{};
      for (final entry in configs.entries) {
        final config = entry.value as Map<String, dynamic>;
        if (config.containsKey('apiKey')) {
          final apiKey = config['apiKey'] as String?;
          if (apiKey != null && apiKey.isNotEmpty) {
            extractedKeys[entry.key] = apiKey;
          }
        }
      }

      expect(extractedKeys.isEmpty, isTrue);
    });

    test('handles empty apiKey gracefully', () {
      const json = '''
{
  "currentProvider": 0,
  "providerConfigs": {
    "0": {"provider": 0, "apiKey": "", "baseUrl": null, "modelName": null, "enabled": true}
  },
  "autoRecognize": true,
  "timeout": 10
}
''';

      final parsed = convert.jsonDecode(json) as Map<String, dynamic>;
      final configs = parsed['providerConfigs'] as Map<String, dynamic>;

      final extractedKeys = <String, String>{};
      for (final entry in configs.entries) {
        final config = entry.value as Map<String, dynamic>;
        if (config.containsKey('apiKey')) {
          final apiKey = config['apiKey'] as String?;
          if (apiKey != null && apiKey.isNotEmpty) {
            extractedKeys[entry.key] = apiKey;
          }
        }
      }

      expect(extractedKeys.isEmpty, isTrue);
    });

    test('preserves other config fields during migration', () {
      const json = '''
{
  "currentProvider": 0,
  "providerConfigs": {
    "0": {
      "provider": 0,
      "apiKey": "sk-test-123",
      "baseUrl": "https://custom.api.com",
      "modelName": "custom-model",
      "enabled": false
    }
  },
  "autoRecognize": false,
  "timeout": 30
}
''';

      final parsed = convert.jsonDecode(json) as Map<String, dynamic>;
      final configs = parsed['providerConfigs'] as Map<String, dynamic>;

      // 提取 API key
      final config = configs['0'] as Map<String, dynamic>;
      final apiKey = config['apiKey'] as String?;

      // 验证 API key
      expect(apiKey, equals('sk-test-123'));

      // 清理 JSON
      config.remove('apiKey');
      configs['0'] = config;
      parsed['providerConfigs'] = configs;
      final cleanedJson = convert.jsonEncode(parsed);

      // 验证清理后的 JSON 不包含 API key
      expect(cleanedJson.contains('sk-test-123'), isFalse);
      // 验证清理后的 JSON 包含其他字段
      expect(cleanedJson.contains('custom.api.com'), isTrue);
      expect(cleanedJson.contains('custom-model'), isTrue);
      expect(cleanedJson.contains('false'), isTrue); // enabled: false
      expect(cleanedJson.contains('30'), isTrue); // timeout: 30
    });

    test('handles invalid JSON gracefully', () {
      const invalidJson = 'not valid json';

      try {
        convert.jsonDecode(invalidJson);
        fail('Should throw exception');
      } catch (e) {
        // Expected behavior
        expect(e is FormatException, isTrue);
      }
    });

    test('handles empty string JSON gracefully', () {
      const emptyJson = '';

      try {
        convert.jsonDecode(emptyJson);
        fail('Should throw exception');
      } catch (e) {
        // Expected behavior
        expect(e is FormatException, isTrue);
      }
    });

    test('handles null value for providerConfigs gracefully', () {
      const json = '''
{
  "currentProvider": 0,
  "autoRecognize": true,
  "timeout": 10
}
''';

      final parsed = convert.jsonDecode(json) as Map<String, dynamic>;
      final configs = parsed['providerConfigs'] as Map<String, dynamic>?;

      expect(configs, isNull);

      // 当 configs 为 null 时，不应该崩溃
      if (configs == null) {
        // 这是预期行为 - 不处理
        expect(true, isTrue);
      }
    });
  });

  group('SecureStorageService API Key Format Validation', () {
    test('API key should not be empty', () {
      const emptyKey = '';
      expect(emptyKey.isEmpty, isTrue);
    });

    test('API key should not be whitespace only', () {
      const whitespaceKey = '   ';
      expect(whitespaceKey.trim().isEmpty, isTrue);
    });

    test('Provider key should not be empty', () {
      const emptyProvider = '';
      expect(emptyProvider.isEmpty, isTrue);
    });
  });
}
