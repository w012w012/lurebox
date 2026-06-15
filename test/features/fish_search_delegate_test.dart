import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/features/fish_list/widgets/fish_search_delegate.dart';

void main() {
  // FIX 3 (H-3): allCatches 为空时旧实现 close(context, allCatches.first)
  // 抛 StateError。新实现 close(context, null)，返回类型可空。
  group('FishSearchDelegate empty list (FIX 3)', () {
    testWidgets('tapping back with empty catches does not throw',
        (tester) async {
      FishCatch? tappedFish;
      final delegate = FishSearchDelegate(
        const <FishCatch>[],
        AppStrings.chinese,
        (fish) => tappedFish = fish,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showSearch<FishCatch?>(
                  context: context,
                  delegate: delegate,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // 搜索页已打开，点击返回箭头（buildLeading）
      final back = find.byIcon(Icons.arrow_back);
      expect(back, findsOneWidget);
      await tester.tap(back);
      await tester.pumpAndSettle();

      // 关键断言：没有 StateError 抛出
      expect(tester.takeException(), isNull);
      // onTap 不应被触发（没有选择任何鱼获）
      expect(tappedFish, isNull);
    });
  });
}
