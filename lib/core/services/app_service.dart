import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/profile/services/profile_service.dart';
import 'biometric_service.dart';
import 'onboarding_service.dart';
import 'profile_switch_service.dart';

class AppService extends GetxService {
  final RxBool isInitialized = false.obs;
  final RxString initialRoute = '/splash'.obs;
  bool _hasInitialized = false; // Prevent double initialization

  @override
  Future<void> onInit() async {
    super.onInit();
    if (_hasInitialized) {
      print('⚠️ AppService.onInit() already called, skipping...');
      return;
    }
    _hasInitialized = true;
    print('🚀 AppService.onInit() starting...');
    await _initializeApp();
    print('🚀 AppService.onInit() completed, isInitialized: ${isInitialized.value}');
  }

  Future<void> _initializeApp() async {
    try {
      print('📱 _initializeApp() starting...');
      
      // Initialize shared preferences
      await SharedPreferences.getInstance();
      print('📱 SharedPreferences initialized');
      
      // Initialize biometric service
      await Get.putAsync<BiometricService>(() => BiometricService().init(), permanent: true);
      print('📱 BiometricService registered');
      
      // Initialize auth service
      final authService = Get.put<AuthService>(AuthService(), permanent: true);
      print('📱 AuthService registered');

      // Initialize profile service
      Get.put<ProfileService>(ProfileService(), permanent: true);
      print('📱 ProfileService registered');

      // Initialize ProfileSwitchService (unified account)
      await Get.putAsync(() => ProfileSwitchService().init(), permanent: true);
      print('📱 ProfileSwitchService registered');
      
      // Wait for auth service to load user data
      await Future.delayed(const Duration(milliseconds: 500));
      print('📱 Auth service delay completed');
      
      // Determine initial route based on authentication status
      print("isuserMarchent oo");

      if (authService.isAuthenticated) {
        // Use locally cached active_role from unified account system
        final prefs = await SharedPreferences.getInstance();
        final activeRole = prefs.getString('active_role');
        final user = authService.user;

        print("📱 Active role: $activeRole, userType: ${user?.userType}");

        // Determine route based on active_role (unified) or userType (legacy)
        final isMerchantMode = activeRole == 'merchant' || (activeRole == null && (user?.isMerchant ?? false));

        if (isMerchantMode) {
          print("🔍 MERCHANT MODE - Will check onboarding via API after navigation");
          initialRoute.value = '/merchant-home';
        } else {
          // Customer - go to home
          initialRoute.value = '/home';
        }
      } else {
        // Check if user has seen onboarding using OnboardingService
        final onboardingService = Get.find<OnboardingService>();
        
        if (onboardingService.hasSeenOnboarding) {
          initialRoute.value = '/login';
        } else {
          initialRoute.value = '/onboarding';
        }
      }
      
      print('📱 Setting initialRoute to: ${initialRoute.value}');
      isInitialized.value = true;
      print('✅ App initialization complete! isInitialized: ${isInitialized.value}');
    } catch (e) {
      print('❌ Error initializing app: $e');
      initialRoute.value = '/onboarding';
      isInitialized.value = true;
      print('⚠️ App initialization failed but set isInitialized to true');
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
