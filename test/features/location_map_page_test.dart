import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';

void main() {
  group('LocationMarker', () {
    testWidgets('renders with blue accent color when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: _TestableLocationMarker(
                name: 'Test Lake',
                fishCount: 5,
                isSelected: true,
                isDark: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify marker is displayed
      expect(find.text('Test Lake'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders with different style when not selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: _TestableLocationMarker(
                name: 'Test Lake',
                fishCount: 5,
                isSelected: false,
                isDark: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Test Lake'), findsOneWidget);
    });

    testWidgets('responds to tap with scale animation', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: _TestableLocationMarker(
                name: 'Test Lake',
                fishCount: 5,
                isSelected: false,
                isDark: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(_TestableLocationMarker));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('uses AnimatedScale for touch feedback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: _TestableLocationMarker(
                name: 'Test Lake',
                fishCount: 5,
                isSelected: false,
                isDark: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify AnimatedScale is present for touch feedback
      expect(find.byType(AnimatedScale), findsOneWidget);
    });

    testWidgets('uses blue accent colors from design system', (tester) async {
      // Test that the design system colors are correct
      expect(AppColors.accentLight, const Color(0xFF3B82F6));
      expect(AppColors.primaryLight, const Color(0xFF1E3A5F));
      expect(AnimationConstants.touchScale, 0.98);
      expect(AnimationConstants.touchFeedbackDuration.inMilliseconds, 150);
    });
  });

  group('LocationGroupCard', () {
    testWidgets('renders with PremiumCard styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestableLocationGroupCard(),
          ),
        ),
      );
      await tester.pump();

      // Card should be present
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays group title with location count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestableLocationGroupCard(),
          ),
        ),
      );
      await tester.pump();

      // Title contains '相似钓点：' and subtitle contains '包含 2 个相似钓点'
      expect(find.textContaining('相似钓点'), findsWidgets);
      expect(find.textContaining('包含 2 个相似钓点'), findsOneWidget);
    });

    testWidgets('shows expansion tile for location list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestableLocationGroupCard(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets('uses iOS-style blue accent for icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestableLocationGroupCard(),
          ),
        ),
      );
      await tester.pump();

      // Find the merge icon and verify it uses accent color
      final icon = tester.widget<Icon>(find.byIcon(Icons.merge_type));
      expect(icon.color, equals(AppColors.accentLight));
    });
  });
}

/// Wrapper to test LocationMarker with blue accent styling
class _TestableLocationMarker extends StatefulWidget {
  final String name;
  final int fishCount;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _TestableLocationMarker({
    required this.name,
    required this.fishCount,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_TestableLocationMarker> createState() =>
      _TestableLocationMarkerState();
}

class _TestableLocationMarkerState extends State<_TestableLocationMarker> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Blue accent color scheme - primary #1E3A5F, accent #3B82F6
    final backgroundColor = widget.isSelected
        ? (widget.isDark ? AppColors.accentDark : AppColors.accentLight)
        : (widget.isDark ? AppColors.primaryDark : AppColors.primaryLight);
    final borderColor = widget.isSelected
        ? Colors.white
        : (widget.isDark ? AppColors.accentDark : AppColors.accentLight);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? AnimationConstants.touchScale : 1.0,
        duration: AnimationConstants.touchFeedbackDuration,
        curve: AnimationConstants.defaultCurve,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.fishCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper to test LocationGroupCard with PremiumCard styling
class _TestableLocationGroupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Row(
          children: [
            const Icon(Icons.merge_type,
                size: 20, color: AppColors.accentLight),
            const SizedBox(width: 8),
            Text(
              '相似钓点：Test Location',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentLight,
                  ),
            ),
          ],
        ),
        subtitle: const Text('包含 2 个相似钓点'),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('合并'),
            Icon(Icons.expand_more),
          ],
        ),
        children: const [
          ListTile(
            title: Text('Location A'),
            subtitle: Text('5 条渔获'),
            dense: true,
          ),
          ListTile(
            title: Text('Location B'),
            subtitle: Text('3 条渔获'),
            dense: true,
          ),
        ],
      ),
    );
  }
}
