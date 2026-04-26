import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/widgets/common/app_snack_bar.dart';

void main() {
  group('AppSnackBar', () {
    testWidgets('showSuccess displays snackbar with check_circle icon',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppSnackBar.showSuccess(context, 'Operation successful');
                },
                child: const Text('Show Success'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.text('Operation successful'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('showError displays snackbar with error_outline icon',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppSnackBar.showError(context, 'Something went wrong');
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('showInfo displays snackbar with info_outline icon',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppSnackBar.showInfo(context, 'Here is some information');
                },
                child: const Text('Show Info'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Info'));
      await tester.pump();

      expect(find.text('Here is some information'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('snackbars appear when triggered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppSnackBar.showSuccess(context, 'Dismiss me');
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Dismiss me'), findsOneWidget);
    });

    testWidgets('showSuccess uses carbonDark background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppSnackBar.showSuccess(context, 'Success message');
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, equals(TeslaColors.carbonDark));
    });

    testWidgets('showError uses danger background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppSnackBar.showError(context, 'Error message');
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, equals(TeslaColors.danger));
    });

    testWidgets('showInfo uses carbonDark background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppSnackBar.showInfo(context, 'Info message');
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, equals(TeslaColors.carbonDark));
    });

    testWidgets('showSuccessWithUndo displays snackbar with undo action',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppSnackBar.showSuccessWithUndo(
                    context,
                    'Item deleted',
                    'Undo',
                    () {},
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Item deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('snackBar has floating behavior', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppSnackBar.showSuccess(context, 'Floating snackbar');
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, equals(SnackBarBehavior.floating));
    });
  });
}
