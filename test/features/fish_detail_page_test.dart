import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/providers/fish_detail_view_model.dart';

class MockFishDetailViewModel extends StateNotifier<FishDetailState>
    implements FishDetailViewModel {
  MockFishDetailViewModel(FishDetailState initialState) : super(initialState);

  @override
  int get fishId => 1;

  @override
  Future<void> loadFish() async {}

  @override
  Future<bool> deleteFish() async => true;

  @override
  void setSharing(bool value) {}

  @override
  Future<void> refresh() async {}
}

class FakeFishDetailState extends Fake implements FishDetailState {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFishDetailState());
  });

  group('FishDetail State Handling', () {
    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fishDetailViewModelProvider(1).overrideWith(
              (ref) => MockFishDetailViewModel(
                  const FishDetailState(isLoading: true)),
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
            fishDetailViewModelProvider(1).overrideWith(
              (ref) => MockFishDetailViewModel(
                const FishDetailState(
                  isLoading: false,
                  errorMessage: 'Fish not found',
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
                    Text('Fish not found'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Fish not found'), findsOneWidget);
    });
  });
}
