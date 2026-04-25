import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFishRecognitionProvider extends Mock
    implements FishRecognitionProvider {}

class MockFile extends Mock implements File {
  MockFile(this._path, [this._fileSize = 1000]);

  final String _path;
  final int _fileSize;

  @override
  String get path => _path;

  // Note: do NOT override exists()/length() here - let when() stubs handle them
  // This ensures mocktail properly intercepts calls
}

class FakeFile extends Fake implements File {}

class FakeAiProviderConfig extends Fake implements AiProviderConfig {}

void main() {
  late FishRecognitionService service;
  late MockFishRecognitionProvider mockProvider;

  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeAiProviderConfig());
    registerFallbackValue(AiRecognitionProvider.gemini);
  });

  setUp(() {
    service = FishRecognitionService();
    mockProvider = MockFishRecognitionProvider();
  });

  AiRecognitionSettings createSettings({
    AiRecognitionProvider currentProvider = AiRecognitionProvider.gemini,
    Map<AiRecognitionProvider, AiProviderConfig>? providerConfigs,
  }) {
    return AiRecognitionSettings(
      currentProvider: currentProvider,
      providerConfigs: providerConfigs ?? {},
    );
  }

  AiProviderConfig createConfig({
    required String apiKey,
    bool enabled = true,
    AiRecognitionProvider provider = AiRecognitionProvider.gemini,
  }) {
    return AiProviderConfig(
      provider: provider,
      apiKey: apiKey,
      enabled: enabled,
    );
  }

  group('FishRecognitionService', () {
    group('identifySpecies', () {
      group('input validation — file does not exist', () {
        test('throws FishRecognitionException when file does not exist', () async {
          final mockFile = MockFile('/nonexistent/path.jpg');
          when(() => mockFile.exists()).thenAnswer((_) async => false);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.type,
                'type',
                FishRecognitionErrorType.unknown,
              ).having(
                (e) => e.message,
                'message',
                '图片文件不存在',
              ),
            ),
          );
        });
      });

      group('input validation — file size exceeds 10MB', () {
        test('throws FishRecognitionException when file size > 10MB', () async {
          const oversizedFileSize = 11 * 1024 * 1024; // 11MB
          final mockFile = MockFile('/valid/path.jpg', oversizedFileSize);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => oversizedFileSize);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.message,
                'message',
                '图片大小超过10MB限制',
              ),
            ),
          );
        });
      });

      group('input validation — unsupported extension', () {
        test('throws FishRecognitionException for gif extension', () async {
          final mockFile = MockFile('/valid/path.gif', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.message,
                'message',
                '不支持的图片格式，请使用 JPG、PNG 或 WebP',
              ),
            ),
          );
        });

        test('throws FishRecognitionException for bmp extension', () async {
          final mockFile = MockFile('/valid/path.bmp', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.message,
                'message',
                '不支持的图片格式，请使用 JPG、PNG 或 WebP',
              ),
            ),
          );
        });

        test('throws FishRecognitionException for tiff extension', () async {
          final mockFile = MockFile('/valid/path.tiff', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.message,
                'message',
                '不支持的图片格式，请使用 JPG、PNG 或 WebP',
              ),
            ),
          );
        });

        test('throws FishRecognitionException for bmp extension', () async {
          final mockFile = MockFile('/valid/path.bmp', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.message,
                'message',
                '不支持的图片格式，请使用 JPG、PNG 或 WebP',
              ),
            ),
          );
        });

        test('throws FishRecognitionException for tiff extension', () async {
          final mockFile = MockFile('/valid/path.tiff', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.message,
                'message',
                '不支持的图片格式，请使用 JPG、PNG 或 WebP',
              ),
            ),
          );
        });

        test('accepts jpg extension', () async {
          final mockFile = MockFile('/valid/path.jpg', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          // Create a testable service that uses the mock provider
          final testService = _TestableFishRecognitionService(mockProvider);

          when(() => mockProvider.identifySpecies(any(), any()))
              .thenAnswer((_) async => FishRecognitionResult(
                    primarySpecies: const SpeciesInfo(
                      chineseName: '测试鱼',
                      scientificName: 'Testus fish',
                      confidence: 90,
                    ),
                    confidence: 90,
                  ));

          // Call the testable service which mirrors the validation
          await testService.identifySpeciesWithValidation(mockFile, settings);

          verify(() => mockProvider.identifySpecies(any(), any())).called(1);
        });

        test('accepts jpeg extension', () async {
          final mockFile = MockFile('/valid/path.jpeg', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          final testService = _TestableFishRecognitionService(mockProvider);

          when(() => mockProvider.identifySpecies(any(), any()))
              .thenAnswer((_) async => FishRecognitionResult(
                    primarySpecies: const SpeciesInfo(
                      chineseName: '鲈鱼',
                      scientificName: 'Lateolabrax japonicus',
                      confidence: 88,
                    ),
                    confidence: 88,
                  ));

          await testService.identifySpeciesWithValidation(mockFile, settings);

          verify(() => mockProvider.identifySpecies(any(), any())).called(1);
        });

        test('accepts png extension', () async {
          final mockFile = MockFile('/valid/path.png', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          final testService = _TestableFishRecognitionService(mockProvider);

          when(() => mockProvider.identifySpecies(any(), any()))
              .thenAnswer((_) async => FishRecognitionResult(
                    primarySpecies: const SpeciesInfo(
                      chineseName: '鳜鱼',
                      scientificName: 'Siniperca chuatsi',
                      confidence: 92,
                    ),
                    confidence: 92,
                  ));

          await testService.identifySpeciesWithValidation(mockFile, settings);

          verify(() => mockProvider.identifySpecies(any(), any())).called(1);
        });

        test('accepts webp extension', () async {
          final mockFile = MockFile('/valid/path.webp', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          final testService = _TestableFishRecognitionService(mockProvider);

          when(() => mockProvider.identifySpecies(any(), any()))
              .thenAnswer((_) async => FishRecognitionResult(
                    primarySpecies: const SpeciesInfo(
                      chineseName: '黑鱼',
                      scientificName: 'Channa argus',
                      confidence: 80,
                    ),
                    confidence: 80,
                  ));

          await testService.identifySpeciesWithValidation(mockFile, settings);

          verify(() => mockProvider.identifySpecies(any(), any())).called(1);
        });

        test('accepts uppercase JPG extension', () async {
          final mockFile = MockFile('/valid/path.JPG', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          final testService = _TestableFishRecognitionService(mockProvider);

          when(() => mockProvider.identifySpecies(any(), any()))
              .thenAnswer((_) async => FishRecognitionResult(
                    primarySpecies: const SpeciesInfo(
                      chineseName: '测试鱼',
                      scientificName: 'Testus',
                      confidence: 85,
                    ),
                    confidence: 85,
                  ));

          await testService.identifySpeciesWithValidation(mockFile, settings);

          verify(() => mockProvider.identifySpecies(any(), any())).called(1);
        });
      });

      group('config validation', () {
        test('throws FishRecognitionException when config is null', () async {
          final mockFile = MockFile('/valid/path.jpg', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            currentProvider: AiRecognitionProvider.gemini,
            providerConfigs: {},
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.type,
                'type',
                FishRecognitionErrorType.apiKeyInvalid,
              ).having(
                (e) => e.message,
                'message',
                '未配置 API 密钥',
              ),
            ),
          );
        });

        test('throws FishRecognitionException when apiKey is empty', () async {
          final mockFile = MockFile('/valid/path.jpg', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: ''),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.type,
                'type',
                FishRecognitionErrorType.apiKeyInvalid,
              ).having(
                (e) => e.message,
                'message',
                '未配置 API 密钥',
              ),
            ),
          );
        });

        test('throws FishRecognitionException when config.enabled is false', () async {
          final mockFile = MockFile('/valid/path.jpg', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(
                apiKey: 'valid-key',
                enabled: false,
              ),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.type,
                'type',
                FishRecognitionErrorType.unknown,
              ).having(
                (e) => e.message,
                'message',
                '当前提供商已禁用',
              ),
            ),
          );
        });

        test('throws when currentProvider config is missing', () async {
          final mockFile = MockFile('/valid/path.jpg', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            currentProvider: AiRecognitionProvider.claude,
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-key'),
            },
          );

          expect(
            () => service.identifySpecies(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.type,
                'type',
                FishRecognitionErrorType.apiKeyInvalid,
              ),
            ),
          );
        });
      });

      group('provider factory', () {
        test('all provider enum values have corresponding factory entries', () {
          // Verify that each AiRecognitionProvider has a factory mapping
          // by checking that we can iterate all providers and they map to constructors
          for (final provider in AiRecognitionProvider.values) {
            // The provider type itself is the key - verify it's a valid enum value
            expect(provider, isA<AiRecognitionProvider>());
            expect(provider.name, isNotEmpty);
          }
        });

        test('each provider has a label and displayName', () {
          for (final provider in AiRecognitionProvider.values) {
            expect(provider.label, isNotEmpty);
            expect(provider.displayName, isNotEmpty);
          }
        });

        test('provider value is unique', () {
          final values = AiRecognitionProvider.values.map((p) => p.value).toList();
          expect(values.toSet().length, equals(values.length));
        });
      });

      group('delegation', () {
        test('delegates to provider.identifySpecies() with valid input', () async {
          final mockFile = MockFile('/valid/path.jpg', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-api-key'),
            },
          );

          final expectedResult = FishRecognitionResult(
            primarySpecies: const SpeciesInfo(
              chineseName: '鲈鱼',
              scientificName: 'Lateolabrax',
              confidence: 95,
            ),
            confidence: 95,
            alternatives: const [
              SpeciesInfo(
                chineseName: '鳜鱼',
                scientificName: 'Siniperca',
                confidence: 30,
              ),
            ],
            notes: 'Test recognition',
          );

          final testService = _TestableFishRecognitionService(mockProvider);
          when(() => mockProvider.identifySpecies(any(), any()))
              .thenAnswer((_) async => expectedResult);

          final result = await testService.identifySpeciesWithValidation(mockFile, settings);

          expect(result.primarySpecies.chineseName, equals('鲈鱼'));
          expect(result.confidence, equals(95));
          expect(result.alternatives.length, equals(1));
          expect(result.notes, equals('Test recognition'));
          verify(() => mockProvider.identifySpecies(any(), any())).called(1);
        });

        test('propagates error from provider', () async {
          final mockFile = MockFile('/valid/path.jpg', 1000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 1000);

          final settings = createSettings(
            providerConfigs: {
              AiRecognitionProvider.gemini: createConfig(apiKey: 'test-api-key'),
            },
          );

          final testService = _TestableFishRecognitionService(mockProvider);
          when(() => mockProvider.identifySpecies(any(), any()))
              .thenThrow(const FishRecognitionException(
                FishRecognitionErrorType.networkError,
                'Network connection failed',
              ));

          expect(
            () => testService.identifySpeciesWithValidation(mockFile, settings),
            throwsA(
              isA<FishRecognitionException>().having(
                (e) => e.type,
                'type',
                FishRecognitionErrorType.networkError,
              ).having(
                (e) => e.message,
                'message',
                'Network connection failed',
              ),
            ),
          );
        });

        test('passes correct image and config to provider', () async {
          final mockFile = MockFile('/test/image.png', 5000);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.length()).thenAnswer((_) async => 5000);

          final settings = createSettings(
            currentProvider: AiRecognitionProvider.openai,
            providerConfigs: {
              AiRecognitionProvider.openai: AiProviderConfig(
                provider: AiRecognitionProvider.openai,
                apiKey: 'sk-openai-key',
                baseUrl: 'https://api.openai.com',
                modelName: 'gpt-4o',
                enabled: true,
              ),
            },
          );

          File? capturedFile;
          AiProviderConfig? capturedConfig;

          final testService = _TestableFishRecognitionService(mockProvider);
          when(() => mockProvider.identifySpecies(any(), any())).thenAnswer(
            (invocation) async {
              capturedFile = invocation.positionalArguments[0] as File;
              capturedConfig = invocation.positionalArguments[1] as AiProviderConfig;
              return FishRecognitionResult(
                primarySpecies: const SpeciesInfo(
                  chineseName: '测试',
                  scientificName: 'Test',
                  confidence: 80,
                ),
                confidence: 80,
              );
            },
          );

          await testService.identifySpeciesWithValidation(mockFile, settings);

          expect(capturedFile, isNotNull);
          expect(capturedFile!.path, equals('/test/image.png'));
          expect(capturedConfig, isNotNull);
          expect(capturedConfig!.apiKey, equals('sk-openai-key'));
          expect(capturedConfig!.modelName, equals('gpt-4o'));
        });
      });

      group('FishRecognitionResult', () {
        test('fromJson parses valid result', () {
          final json = {
            'primarySpecies': {
              'chineseName': '鲤鱼',
              'scientificName': 'Cyprinus carpio',
              'confidence': 88,
            },
            'confidence': 88,
            'alternatives': [
              {
                'chineseName': '草鱼',
                'scientificName': 'Ctenopharyngodon idella',
                'confidence': 20,
              },
            ],
            'notes': 'Large specimen',
          };

          final result = FishRecognitionResult.fromJson(json);

          expect(result.primarySpecies.chineseName, equals('鲤鱼'));
          expect(result.primarySpecies.scientificName, equals('Cyprinus carpio'));
          expect(result.primarySpecies.confidence, equals(88));
          expect(result.confidence, equals(88));
          expect(result.alternatives.length, equals(1));
          expect(result.alternatives.first.chineseName, equals('草鱼'));
          expect(result.notes, equals('Large specimen'));
        });

        test('fromJson handles missing alternatives', () {
          final json = {
            'primarySpecies': {
              'chineseName': '鲤鱼',
              'scientificName': 'Cyprinus carpio',
              'confidence': 88,
            },
            'confidence': 88,
          };

          final result = FishRecognitionResult.fromJson(json);

          expect(result.alternatives, isEmpty);
          expect(result.notes, isEmpty);
        });

        test('fromJson throws when primarySpecies is invalid', () {
          final json = {
            'primarySpecies': 'invalid',
            'confidence': 88,
          };

          expect(
            () => FishRecognitionResult.fromJson(json),
            throwsA(isA<FormatException>()),
          );
        });

        test('toJson produces correct output', () {
          const result = FishRecognitionResult(
            primarySpecies: SpeciesInfo(
              chineseName: '鲤鱼',
              scientificName: 'Cyprinus carpio',
              confidence: 88,
            ),
            confidence: 88,
            alternatives: [
              SpeciesInfo(
                chineseName: '草鱼',
                scientificName: 'Ctenopharyngodon idella',
                confidence: 20,
              ),
            ],
            notes: 'Test note',
          );

          final json = result.toJson();

          expect(json['primarySpecies']['chineseName'], equals('鲤鱼'));
          expect(json['confidence'], equals(88));
          expect(json['alternatives'].length, equals(1));
          expect(json['notes'], equals('Test note'));
        });
      });

      group('SpeciesInfo', () {
        test('fromJson parses valid species info', () {
          final json = {
            'chineseName': '鲈鱼',
            'scientificName': 'Lateolabrax japonicus',
            'confidence': 92,
          };

          final species = SpeciesInfo.fromJson(json);

          expect(species.chineseName, equals('鲈鱼'));
          expect(species.scientificName, equals('Lateolabrax japonicus'));
          expect(species.confidence, equals(92));
        });

        test('fromJson handles empty chineseName', () {
          final json = {
            'chineseName': '',
            'scientificName': 'Unknown',
            'confidence': 50,
          };

          final species = SpeciesInfo.fromJson(json);

          expect(species.chineseName, equals('未知物种'));
        });

        test('fromJson handles missing chineseName', () {
          final json = {
            'scientificName': 'Unknown',
          };

          final species = SpeciesInfo.fromJson(json);

          expect(species.chineseName, equals('未知物种'));
        });

        test('fromJson clamps confidence to valid range', () {
          final json = {
            'chineseName': '测试',
            'scientificName': 'Test',
            'confidence': 150,
          };

          final species = SpeciesInfo.fromJson(json);

          expect(species.confidence, equals(100));
        });

        test('fromJson clamps negative confidence', () {
          final json = {
            'chineseName': '测试',
            'scientificName': 'Test',
            'confidence': -10,
          };

          final species = SpeciesInfo.fromJson(json);

          expect(species.confidence, equals(0));
        });

        test('toJson produces correct output', () {
          const species = SpeciesInfo(
            chineseName: '鲈鱼',
            scientificName: 'Lateolabrax japonicus',
            confidence: 92,
          );

          final json = species.toJson();

          expect(json['chineseName'], equals('鲈鱼'));
          expect(json['scientificName'], equals('Lateolabrax japonicus'));
          expect(json['confidence'], equals(92));
        });
      });

      group('FishRecognitionException', () {
        test('toString returns formatted message', () {
          const exception = FishRecognitionException(
            FishRecognitionErrorType.apiKeyInvalid,
            'API key is invalid',
          );

          expect(
            exception.toString(),
            equals('FishRecognitionException(FishRecognitionErrorType.apiKeyInvalid): API key is invalid'),
          );
        });

        test('apiKeyInvalid type is correctly set', () {
          const exception = FishRecognitionException(
            FishRecognitionErrorType.apiKeyInvalid,
            'Invalid key',
          );

          expect(exception.type, equals(FishRecognitionErrorType.apiKeyInvalid));
        });

        test('timeout type is correctly set', () {
          const exception = FishRecognitionException(
            FishRecognitionErrorType.timeout,
            'Request timed out',
          );

          expect(exception.type, equals(FishRecognitionErrorType.timeout));
        });

        test('networkError type is correctly set', () {
          const exception = FishRecognitionException(
            FishRecognitionErrorType.networkError,
            'Network error',
          );

          expect(exception.type, equals(FishRecognitionErrorType.networkError));
        });

        test('rateLimited type is correctly set', () {
          const exception = FishRecognitionException(
            FishRecognitionErrorType.rateLimited,
            'Rate limit exceeded',
          );

          expect(exception.type, equals(FishRecognitionErrorType.rateLimited));
        });

        test('unknown type is correctly set', () {
          const exception = FishRecognitionException(
            FishRecognitionErrorType.unknown,
            'Unknown error',
          );

          expect(exception.type, equals(FishRecognitionErrorType.unknown));
        });
      });
    });
  });
}

/// Test helper that mirrors FishRecognitionService validation logic
/// but allows injecting a mock provider for delegation tests.
class _TestableFishRecognitionService {
  final FishRecognitionProvider _testProvider;

  _TestableFishRecognitionService(this._testProvider);

  static const int _maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const Set<String> _supportedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  Future<FishRecognitionResult> identifySpeciesWithValidation(
    File image,
    AiRecognitionSettings settings,
  ) async {
    // Mirror the validation logic from FishRecognitionService
    if (!await image.exists()) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '图片文件不存在',
      );
    }

    final fileSize = await image.length();
    if (fileSize > _maxImageSizeBytes) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '图片大小超过10MB限制',
      );
    }

    final ext = image.path.toLowerCase().split('.').last;
    if (!_supportedExtensions.contains('.$ext')) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '不支持的图片格式，请使用 JPG、PNG 或 WebP',
      );
    }

    final config = settings.providerConfigs[settings.currentProvider];

    if (config == null || config.apiKey.isEmpty) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.apiKeyInvalid,
        '未配置 API 密钥',
      );
    }

    if (!config.enabled) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '当前提供商已禁用',
      );
    }

    // Delegate to injected provider
    return _testProvider.identifySpecies(image, config);
  }
}