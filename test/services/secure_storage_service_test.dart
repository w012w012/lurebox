import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/services/secure_storage_service.dart';

void main() {
  group('SecureStorageService', () {
    group('migrateApiKeysFromJson', () {
      test('extracts API keys and returns cleaned JSON without apiKey fields',
          () async {
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

        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());
        final cleanedJson = await service.migrateApiKeysFromJson(legacyJson);

        // API keys should be saved to secure storage
        expect(await service.getProviderApiKey('0'), equals('sk-gemini-123'));
        expect(await service.getProviderApiKey('1'), equals('sk-openai-456'));

        // Cleaned JSON should not contain API keys
        expect(cleanedJson.contains('sk-gemini-123'), isFalse);
        expect(cleanedJson.contains('sk-openai-456'), isFalse);
        expect(cleanedJson.contains('"apiKey"'), isFalse);

        // Other fields should be preserved
        expect(cleanedJson.contains('"currentProvider"'), isTrue);
        expect(cleanedJson.contains('https://api.openai.com'), isTrue);
        expect(cleanedJson.contains('gpt-4'), isTrue);
        expect(cleanedJson.contains('"enabled":true'), isTrue);
      });

      test('handles empty providerConfigs gracefully', () async {
        const json = '''
{
  "currentProvider": 0,
  "providerConfigs": {},
  "autoRecognize": true,
  "timeout": 10
}
''';

        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());
        final cleanedJson = await service.migrateApiKeysFromJson(json);

        expect(await service.getProviderApiKey('0'), isNull);
        expect(cleanedJson.contains('"providerConfigs"'), isTrue);
      });

      test('handles missing apiKey fields gracefully', () async {
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

        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());
        final cleanedJson = await service.migrateApiKeysFromJson(json);

        expect(await service.getProviderApiKey('0'), isNull);
        expect(cleanedJson.contains('"apiKey"'), isFalse);
      });

      test('handles null apiKey gracefully', () async {
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

        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());
        await service.migrateApiKeysFromJson(json);

        expect(await service.getProviderApiKey('0'), isNull);
      });

      test('handles empty apiKey gracefully', () async {
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

        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());
        await service.migrateApiKeysFromJson(json);

        expect(await service.getProviderApiKey('0'), isNull);
      });

      test('preserves other config fields during migration', () async {
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

        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());
        final cleanedJson = await service.migrateApiKeysFromJson(json);

        expect(await service.getProviderApiKey('0'), equals('sk-test-123'));
        expect(cleanedJson.contains('sk-test-123'), isFalse);
        expect(cleanedJson.contains('custom.api.com'), isTrue);
        expect(cleanedJson.contains('custom-model'), isTrue);
        expect(cleanedJson.contains('false'), isTrue);
        expect(cleanedJson.contains('30'), isTrue);
      });

      test('handles null providerConfigs gracefully', () async {
        const json = '''
{
  "currentProvider": 0,
  "autoRecognize": true,
  "timeout": 10
}
''';

        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());
        final cleanedJson = await service.migrateApiKeysFromJson(json);

        expect(cleanedJson, equals(json)); // unchanged
        expect(await service.getProviderApiKey('0'), isNull);
      });

      test('throws when JSON is invalid', () async {
        const invalidJson = 'not valid json';

        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());
        // Rethrow ensures caller handles it — prevents infinite migration
        // loop if the subsequent repository.set() would succeed.
        expect(
          () => service.migrateApiKeysFromJson(invalidJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws when JSON is empty string', () async {
        const emptyJson = '';

        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());
        expect(
          () => service.migrateApiKeysFromJson(emptyJson),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('ApiKeyStorage implementations', () {
      test('InMemoryApiKeyStorage saves and retrieves correctly', () async {
        final storage = InMemoryApiKeyStorage();

        await storage.save('openai', 'sk-test-openai');
        expect(await storage.get('openai'), equals('sk-test-openai'));

        await storage.save('gemini', 'sk-test-gemini');
        expect(await storage.get('openai'), equals('sk-test-openai'));
        expect(await storage.get('gemini'), equals('sk-test-gemini'));
      });

      test('InMemoryApiKeyStorage.has returns true for saved keys',
          () async {
        final storage = InMemoryApiKeyStorage();

        expect(await storage.has('openai'), isFalse);
        await storage.save('openai', 'sk-test');
        expect(await storage.has('openai'), isTrue);
      });

      test('InMemoryApiKeyStorage.delete removes key', () async {
        final storage = InMemoryApiKeyStorage();

        await storage.save('openai', 'sk-test');
        expect(await storage.has('openai'), isTrue);
        await storage.delete('openai');
        expect(await storage.has('openai'), isFalse);
      });

      test('InMemoryApiKeyStorage.deleteAll clears all', () async {
        final storage = InMemoryApiKeyStorage();

        await storage.save('openai', 'sk-test-1');
        await storage.save('gemini', 'sk-test-2');
        await storage.deleteAll();

        expect(await storage.has('openai'), isFalse);
        expect(await storage.has('gemini'), isFalse);
      });

      test('InMemoryApiKeyStorage ignores empty provider or key on save',
          () async {
        final storage = InMemoryApiKeyStorage();

        await storage.save('', 'sk-test');
        await storage.save('openai', '');
        await storage.save('', '');

        expect(await storage.get('openai'), isNull);
        expect(await storage.has('openai'), isFalse);
      });
    });

    group('SecureStorageService saveProviderApiKey', () {
      test('saves and retrieves provider API key', () async {
        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());

        await service.saveProviderApiKey('openai', 'sk-test-123');
        expect(
            await service.getProviderApiKey('openai'), equals('sk-test-123'),);
      });

      test('hasProviderApiKey returns true after save', () async {
        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());

        expect(
            await service.hasProviderApiKey('openai'), isFalse,);
        await service.saveProviderApiKey('openai', 'sk-test');
        expect(
            await service.hasProviderApiKey('openai'), isTrue,);
      });

      test('deleteProviderApiKey removes the key', () async {
        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());

        await service.saveProviderApiKey('openai', 'sk-test');
        await service.deleteProviderApiKey('openai');
        expect(
            await service.hasProviderApiKey('openai'), isFalse,);
      });

      test('deleteAllProviderApiKeys clears all keys', () async {
        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());

        await service.saveProviderApiKey('openai', 'sk-test-1');
        await service.saveProviderApiKey('gemini', 'sk-test-2');
        await service.deleteAllProviderApiKeys();

        expect(
            await service.hasProviderApiKey('openai'), isFalse,);
        expect(
            await service.hasProviderApiKey('gemini'), isFalse,);
      });

      test('saveAllProviderApiKeys saves multiple keys', () async {
        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());

        await service.saveAllProviderApiKeys({
          'openai': 'sk-test-1',
          'gemini': 'sk-test-2',
        });

        expect(
            await service.getProviderApiKey('openai'), equals('sk-test-1'),);
        expect(
            await service.getProviderApiKey('gemini'), equals('sk-test-2'),);
      });

      test('getAllProviderApiKeys returns all saved keys', () async {
        final service =
            SecureStorageService(storage: InMemoryApiKeyStorage());

        // Use numeric provider keys matching AiRecognitionProvider enum values
        await service.saveProviderApiKey('0', 'sk-test-gemini');
        await service.saveProviderApiKey('1', 'sk-test-openai');

        final all = await service.getAllProviderApiKeys();

        expect(all['0'], equals('sk-test-gemini'));
        expect(all['1'], equals('sk-test-openai'));
      });
    });
  });
}
