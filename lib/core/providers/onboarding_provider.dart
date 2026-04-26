import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';

/// Onboarding state provider
/// - true = onboarding has been completed
/// - false = onboarding needs to be shown
final onboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).hasCompletedOnboarding;
});

/// Onboarding notifier for managing onboarding state
class OnboardingNotifier extends StateNotifier<bool> {

  OnboardingNotifier(this._ref) : super(false) {
    // Initialize from AppSettings
    state = _ref.read(appSettingsProvider).hasCompletedOnboarding;
  }
  final Ref _ref;

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final currentSettings = _ref.read(appSettingsProvider);
    final newSettings = currentSettings.copyWith(hasCompletedOnboarding: true);
    await _ref.read(appSettingsProvider.notifier).updateSettings(newSettings);
    if (!mounted) return;
    state = true;
  }

  /// Reset onboarding (for settings re-trigger)
  Future<void> resetOnboarding() async {
    final currentSettings = _ref.read(appSettingsProvider);
    final newSettings = currentSettings.copyWith(hasCompletedOnboarding: false);
    await _ref.read(appSettingsProvider.notifier).updateSettings(newSettings);
    if (!mounted) return;
    state = false;
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref);
});
