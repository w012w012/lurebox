import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/strings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/onboarding_provider.dart';
import '../../core/design/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Widget> _buildPages(AppStrings strings) => [
        _WelcomePage(strings: strings),
        _FeaturesPage(strings: strings),
        _PermissionsPage(strings: strings),
        _SettingsPage(strings: strings),
        _CompletePage(strings: strings),
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
    if (mounted) context.go('/');
  }

  void _skip() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final pages = _buildPages(strings);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _skip, child: Text(strings.onboardingSkip)),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? TeslaColors.electricBlue
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child:
                      Text(_currentPage == pages.length - 1 ? strings.onboardingGetStarted : strings.onboardingNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final AppStrings strings;
  const _WelcomePage({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.water_drop,
              size: 100, color: TeslaColors.electricBlue),
          const SizedBox(height: 24),
          Text(strings.onboardingWelcomeTitle, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(strings.onboardingWelcomeDesc, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _FeaturesPage extends StatelessWidget {
  final AppStrings strings;
  const _FeaturesPage({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(strings.onboardingFeaturesTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _FeatureCard(
                    icon: Icons.camera_alt, title: strings.onboardingFeatureCameraTitle, desc: strings.onboardingFeatureCameraDesc),
                _FeatureCard(
                    icon: Icons.inventory_2, title: strings.onboardingFeatureEquipmentTitle, desc: strings.onboardingFeatureEquipmentDesc),
                _FeatureCard(
                    icon: Icons.bar_chart, title: strings.onboardingFeatureStatsTitle, desc: strings.onboardingFeatureStatsDesc),
                _FeatureCard(
                    icon: Icons.backup, title: strings.onboardingFeatureBackupTitle, desc: strings.onboardingFeatureBackupDesc),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard(
      {required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: TeslaColors.electricBlue),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(desc,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  final AppStrings strings;
  const _PermissionsPage({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(strings.onboardingPermissionsTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _PermissionCard(
                    icon: Icons.camera_alt,
                    title: strings.onboardingPermissionCameraTitle,
                    desc: strings.onboardingPermissionCameraDesc,
                    example: strings.onboardingPermissionCameraExample,
                  ),
                  const SizedBox(height: 16),
                  _PermissionCard(
                    icon: Icons.location_on,
                    title: strings.onboardingPermissionLocationTitle,
                    desc: strings.onboardingPermissionLocationDesc,
                    example: strings.onboardingPermissionLocationExample,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(strings.onboardingPrivacyNote),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String example;
  const _PermissionCard(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.example});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: TeslaColors.electricBlue, size: 32),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(example,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    )),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  final AppStrings strings;
  const _SettingsPage({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(strings.onboardingSettingsTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(strings.onboardingSettingsDesc, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(strings.onboardingSettingsItems, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CompletePage extends StatelessWidget {
  final AppStrings strings;
  const _CompletePage({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle,
              size: 100, color: TeslaColors.electricBlue),
          const SizedBox(height: 24),
          Text(strings.onboardingReadyTitle, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(strings.onboardingReadyDesc, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
