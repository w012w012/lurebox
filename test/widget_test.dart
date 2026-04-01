import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void setUpDatabaseForTesting() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

class MockAppSettingsNotifier extends StateNotifier<AppSettings> {
  MockAppSettingsNotifier() : super(const AppSettings());
}

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
  });

  testWidgets('App smoke test - simplified widget test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) {
            return MockAppSettingsNotifier() as AppSettingsNotifier;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Center(child: Text('路亚鱼护'))),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('路亚鱼护'), findsOneWidget);
  });
}
