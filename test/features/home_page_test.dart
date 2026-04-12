import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/providers/home_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/constants/strings.dart';

class MockHomeViewModel extends StateNotifier<HomeState>
    implements HomeViewModel {
  MockHomeViewModel(HomeState initialState) : super(initialState);

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadData() async {}
}

class FakeHomeState extends Fake implements HomeState {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeHomeState());
  });

  group('HomePage State Handling', () {
    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith(
              (ref) => MockHomeViewModel(const HomeState(isLoading: true)),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when errorMessage is set', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith(
              (ref) => MockHomeViewModel(
                const HomeState(
                  isLoading: false,
                  errorMessage: 'Failed to load data',
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline),
                    Text('Failed to load data'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to load data'), findsOneWidget);
    });
  });
}
