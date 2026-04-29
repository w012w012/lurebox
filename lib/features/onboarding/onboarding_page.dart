import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/onboarding_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    try {
      await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
      if (mounted) context.go('/');
    } on Object catch (e) {
      if (!mounted) return;
      final errorStrings = ref.read(currentStringsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${errorStrings.errorSaveFailed}: $e')),
      );
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  Future<void> _skip() => _completeOnboarding();

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
              child: TextButton(
                onPressed: _isCompleting ? null : _skip,
                child: Text(strings.onboardingSkip),
              ),
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
                  onPressed: _isCompleting ? null : _nextPage,
                  child: _isCompleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentPage == pages.length - 1
                              ? strings.onboardingGetStarted
                              : strings.onboardingNext,
                        ),
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
  const _WelcomePage({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.water_drop,
            size: 100,
            color: TeslaColors.electricBlue,
          ),
          const SizedBox(height: 24),
          Text(strings.onboardingWelcomeTitle,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(strings.onboardingWelcomeDesc,
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _FeaturesPage extends StatelessWidget {
  const _FeaturesPage({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(strings.onboardingFeaturesTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _FeatureCard(
                  icon: Icons.camera_alt,
                  title: strings.onboardingFeatureCameraTitle,
                  desc: strings.onboardingFeatureCameraDesc,
                ),
                _FeatureCard(
                  icon: Icons.inventory_2,
                  title: strings.onboardingFeatureEquipmentTitle,
                  desc: strings.onboardingFeatureEquipmentDesc,
                ),
                _FeatureCard(
                  icon: Icons.bar_chart,
                  title: strings.onboardingFeatureStatsTitle,
                  desc: strings.onboardingFeatureStatsDesc,
                ),
                _FeatureCard(
                  icon: Icons.backup,
                  title: strings.onboardingFeatureBackupTitle,
                  desc: strings.onboardingFeatureBackupDesc,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });
  final IconData icon;
  final String title;
  final String desc;

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
            Text(
              desc,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionsPage extends StatefulWidget {
  const _PermissionsPage({required this.strings});
  final AppStrings strings;

  @override
  State<_PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<_PermissionsPage> {
  bool _cameraGranted = false;
  bool _locationGranted = false;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    final camera = await Permission.camera.status;
    final location = await Permission.locationWhenInUse.status;
    if (mounted) {
      setState(() {
        _cameraGranted = camera.isGranted;
        _locationGranted = location.isGranted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isRequesting = true);
    final camera = await Permission.camera.request();
    final location = await Permission.locationWhenInUse.request();
    if (mounted) {
      setState(() {
        _cameraGranted = camera.isGranted;
        _locationGranted = location.isGranted;
        _isRequesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            widget.strings.onboardingPermissionsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _PermissionCard(
                    icon: Icons.camera_alt,
                    title: widget.strings.onboardingPermissionCameraTitle,
                    desc: widget.strings.onboardingPermissionCameraDesc,
                    example: widget.strings.onboardingPermissionCameraExample,
                    granted: _cameraGranted,
                  ),
                  const SizedBox(height: 16),
                  _PermissionCard(
                    icon: Icons.location_on,
                    title: widget.strings.onboardingPermissionLocationTitle,
                    desc: widget.strings.onboardingPermissionLocationDesc,
                    example: widget.strings.onboardingPermissionLocationExample,
                    granted: _locationGranted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!_cameraGranted || !_locationGranted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRequesting ? null : _requestPermissions,
                icon: _isRequesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.security),
                label: Text(
                  _isRequesting
                      ? widget.strings.onboardingPermissionsRequesting
                      : widget.strings.onboardingPermissionsGrant,
                ),
              ),
            ),
          if (_cameraGranted && _locationGranted)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    color: TeslaColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.strings.onboardingPermissionsGranted,
                  style: TextStyle(color: TeslaColors.success),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(widget.strings.onboardingPrivacyNote),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.example,
    this.granted = false,
  });
  final IconData icon;
  final String title;
  final String desc;
  final String example;
  final bool granted;

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
                Icon(
                  icon,
                  color:
                      granted ? TeslaColors.success : TeslaColors.electricBlue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (granted)
                  const Icon(
                    Icons.check_circle,
                    color: TeslaColors.success,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              example,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(strings.onboardingSettingsTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(strings.onboardingSettingsDesc,
              style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(strings.onboardingSettingsItems,
              style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CompletePage extends StatelessWidget {
  const _CompletePage({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 100,
            color: TeslaColors.electricBlue,
          ),
          const SizedBox(height: 24),
          Text(strings.onboardingReadyTitle,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(strings.onboardingReadyDesc,
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
