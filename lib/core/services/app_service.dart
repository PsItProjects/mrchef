import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/profile/services/profile_service.dart';

class AppService extends GetxService {
  final RxBool isInitialized = false.obs;
  final RxString initialRoute = '/splash'.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize shared preferences
      await SharedPreferences.getInstance();
      
      // Initialize auth service
      final authService = Get.put<AuthService>(AuthService(), permanent: true);

      // Initialize profile service
      Get.put<ProfileService>(ProfileService(), permanent: true);
      
      // Wait for auth service to load user data
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Determine initial route based on authentication status
      print("isuserMarchent oo");

      if (authService.isAuthenticated) {
        // Check if user needs to complete onboarding
        final user = authService.user;
        final isuserMarchent = user?.isMerchant ?? false;

        print("isuserMarchent $isuserMarchent");

        if (user != null && user.isMerchant) {
          // For merchants, always check onboarding status via API
          // Don't rely on local user.registrationStep as it might be outdated
          print("🔍 MERCHANT DETECTED - Will check onboarding via API after navigation");

          // Start with merchant home, but the actual onboarding check will happen
          // when MerchantSettingsService is initialized and tries to load profile
          initialRoute.value = '/merchant-home';
        } else {
          // Customer - go to home
          initialRoute.value = '/home';
        }
      } else {
        // Check if user has seen onboarding
        final prefs = await SharedPreferences.getInstance();
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
        
        if (hasSeenOnboarding) {
          initialRoute.value = '/login';
        } else {
          initialRoute.value = '/onboarding';
        }
      }
      
      isInitialized.value = true;
    } catch (e) {
      print('Error initializing app: $e');
      initialRoute.value = '/onboarding';
      isInitialized.value = true;
    }
  }

  Future<void> markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (e) {
      print('Error marking onboarding complete: $e');
    }
  }

  Future<void> clearAppData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset app state
      isInitialized.value = false;
      initialRoute.value = '/onboarding';
      
      // Re-initialize
      await _initializeApp();
    } catch (e) {
      print('Error clearing app data: $e');
    }
  }
}
