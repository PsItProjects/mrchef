import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService extends GetxService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  
  SharedPreferences? _prefs;

  Future<OnboardingService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  /// Check if user has seen onboarding
  bool get hasSeenOnboarding {
    return _prefs?.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Mark onboarding as seen
  Future<void> setOnboardingAsSeen() async {
    await _prefs?.setBool(_hasSeenOnboardingKey, true);
  }

  /// Reset onboarding state (for testing purposes)
  Future<void> resetOnboarding() async {
    await _prefs?.setBool(_hasSeenOnboardingKey, false);
  }
}
