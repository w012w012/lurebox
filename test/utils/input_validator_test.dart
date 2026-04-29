import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/utils/input_validator.dart';

void main() {
  group('InputValidator', () {
    group('validateName', () {
      test('returns trimmed string for valid input', () {
        expect(InputValidator.validateName('  bass  '), equals('bass'));
      });

      test('throws for empty string', () {
        expect(
          () => InputValidator.validateName(''),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws for whitespace-only string', () {
        expect(
          () => InputValidator.validateName('   '),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws for null', () {
        expect(
          () => InputValidator.validateName(null),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws for string exceeding max length', () {
        final longName = 'a' * 201;
        expect(
          () => InputValidator.validateName(longName),
          throwsA(isA<ValidationException>()),
        );
      });

      test('accepts string at max length', () {
        final maxName = 'a' * 200;
        expect(InputValidator.validateName(maxName), equals(maxName));
      });

      test('strips null bytes', () {
        expect(InputValidator.validateName('bass\x00fish'), equals('bassfish'));
      });

      test('preserves newlines and tabs', () {
        expect(InputValidator.validateName('line1\nline2'), equals('line1\nline2'));
        expect(InputValidator.validateName('col1\tcol2'), equals('col1\tcol2'));
      });

      test('strips control characters', () {
        expect(InputValidator.validateName('bass\x01fish'), equals('bassfish'));
      });
    });

    group('validateOptionalName', () {
      test('returns null for null input', () {
        expect(InputValidator.validateOptionalName(null), isNull);
      });

      test('returns null for empty string', () {
        expect(InputValidator.validateOptionalName(''), isNull);
      });

      test('returns null for whitespace-only string', () {
        expect(InputValidator.validateOptionalName('   '), isNull);
      });

      test('returns trimmed string for valid input', () {
        expect(
          InputValidator.validateOptionalName('  bass  '),
          equals('bass'),
        );
      });

      test('throws for string exceeding max length', () {
        final longName = 'a' * 201;
        expect(
          () => InputValidator.validateOptionalName(longName),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('validateDescription', () {
      test('returns null for null input', () {
        expect(InputValidator.validateDescription(null), isNull);
      });

      test('returns trimmed string for valid input', () {
        expect(
          InputValidator.validateDescription('  nice fish  '),
          equals('nice fish'),
        );
      });

      test('throws for string exceeding max length', () {
        final longDesc = 'a' * 2001;
        expect(
          () => InputValidator.validateDescription(longDesc),
          throwsA(isA<ValidationException>()),
        );
      });

      test('accepts string at max length', () {
        final maxDesc = 'a' * 2000;
        expect(InputValidator.validateDescription(maxDesc), equals(maxDesc));
      });
    });
  });
}
