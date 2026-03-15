import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/models/user_model.dart';
import '../../features/auth/services/auth_service.dart';
import '../network/api_client.dart';
import 'fcm_service.dart';

/// Unified Account status model returned from GET /api/account/status
class AccountStatus {
  final String activeRole;
  final bool hasMerchantProfile;
  final bool merchantOnboardingCompleted;
  final int? merchantId;
  final int? customerId;

  AccountStatus({
    required this.activeRole,
    required this.hasMerchantProfile,
    required this.merchantOnboardingCompleted,
    this.merchantId,
    this.customerId,
  });

  factory AccountStatus.fromJson(Map<String, dynamic> json) {
    // Handle both bool and int (0/1) from PHP backend
    final hasMerchant = json['has_merchant_profile'] == true || json['has_merchant_profile'] == 1;
    final onboardingDone = json['merchant_onboarding_completed'] == true || json['merchant_onboarding_completed'] == 1;

    print('📦 AccountStatus.fromJson:');
    print('  raw has_merchant_profile: ${json['has_merchant_profile']} (${json['has_merchant_profile'].runtimeType})');
    print('  raw merchant_onboarding_completed: ${json['merchant_onboarding_completed']} (${json['merchant_onboarding_completed'].runtimeType})');
    print('  parsed hasMerchant: $hasMerchant, onboardingDone: $onboardingDone');
    print('  active_role: ${json['active_role']}');

    return AccountStatus(
      activeRole: json['active_role'] ?? 'customer',
      hasMerchantProfile: hasMerchant,
      merchantOnboardingCompleted: onboardingDone,
      merchantId: json['merchant_id'],
      customerId: json['customer_id'],
    );
  }

  bool get canSwitchToMerchant => hasMerchantProfile && merchantOnboardingCompleted;
  bool get canActivateMerchant => !hasMerchantProfile;
  bool get isMerchantMode => activeRole == 'merchant';
  bool get isCustomerMode => activeRole == 'customer';
}

/// Service that manages switching between customer and merchant profiles.
///
/// This works with the unified_accounts backend system.
/// - One phone → one customer + optionally one merchant.
/// - User can switch roles like Facebook pages without logging out.
/// - Notifications reach both roles regardless of which is active.
class ProfileSwitchService extends getx.GetxService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Current account status (observable).
  final getx.Rx<AccountStatus?> accountStatus = getx.Rx<AccountStatus?>(null);

  /// Whether a switch operation is in progress.
  final getx.RxBool isSwitching = false.obs;

  /// Whether we are loading account status.
  final getx.RxBool isLoadingStatus = false.obs;

  /// Last switch error details (for UI to react)
  final getx.RxnString lastSwitchError = getx.RxnString();
  final getx.RxnString lastSwitchAction = getx.RxnString();
  final getx.RxnString lastMerchantStatus = getx.RxnString();
  final getx.RxnString lastRegistrationStep = getx.RxnString();

  // ─── Initialization ───

  Future<ProfileSwitchService> init() async {
    return this;
  }

  // ─── Account Status ───

  /// Fetch account status from the API.
  /// Call after login and when settings screen opens.
  Future<AccountStatus?> fetchAccountStatus() async {
    try {
      isLoadingStatus.value = true;

      final response = await _apiClient.get('/account/status');

      if (response.statusCode == 200 && response.data['data'] != null) {
        final status = AccountStatus.fromJson(response.data['data']);
        accountStatus.value = status;

        // Persist active role locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('active_role', status.activeRole);

        print('✅ ProfileSwitch: Account status loaded:');
        print('   role: ${status.activeRole}');
        print('   hasMerchant: ${status.hasMerchantProfile}');
        print('   onboardingCompleted: ${status.merchantOnboardingCompleted}');
        print('   canSwitchToMerchant: ${status.canSwitchToMerchant}');
        return status;
      }

      print('⚠️ ProfileSwitch: Failed to fetch account status');
      return null;
    } catch (e) {
      print('❌ ProfileSwitch: Error fetching account status: $e');
      return null;
    } finally {
      isLoadingStatus.value = false;
    }
  }

  // ─── Role Switching ───

  /// Switch to the other role (customer ↔ merchant).
  /// Returns the new token on success, null on failure.
  ///
  /// This will:
  /// 1. Call POST /account/switch-role
  /// 2. Backend deletes old Sanctum token, creates new one from target model
  /// 3. Update local token, user_type, user data
  /// 4. Re-associate FCM token
  Future<bool> switchRole() async {
    final status = accountStatus.value;
    if (status == null) {
      print('❌ ProfileSwitch: No account status available');
      return false;
    }

    final targetRole = status.isMerchantMode ? 'customer' : 'merchant';

    try {
      isSwitching.value = true;
      print('🔄 ProfileSwitch: Switching to $targetRole...');

      final response = await _apiClient.post('/account/switch-role', data: {
        'role': targetRole,  // Changed from 'target_role' to match backend
      });

      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        // ====== UNIFIED MODEL: Token does NOT change ======
        // The backend now only updates active_role, no new token is created
        final newRole = data['active_role'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        // ✅ Preserve customer avatar across role switches (unified profile)
        final authService = getx.Get.find<AuthService>();
        final previousAvatarUrl = authService.currentUser.value?.avatarUrl;
        final user = UserModel.fromJson(userData);

        // If new user data has no avatar, keep the previous one
        final finalUser = (user.avatarUrl == null || user.avatarUrl!.isEmpty)
            ? user.copyWith(avatarUrl: previousAvatarUrl)
            : user;

        // Only update user type in preferences, not token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_type', newRole);
        await prefs.setString('active_role', newRole);

        // ✅ Clear role-specific profile caches to prevent stale data
        await prefs.remove('customer_profile_cache');
        await prefs.remove('merchant_profile_cache');
        await prefs.remove('cached_user_profile');

        // Update current user in AuthService
        authService.currentUser.value = finalUser;
        authService.isLoggedIn.value = true;

        // Re-associate FCM token with new user_type
        try {
          if (getx.Get.isRegistered<FCMService>()) {
            await FCMService.instance.associateWithUser();
          }
        } catch (e) {
          print('⚠️ ProfileSwitch: FCM re-association failed: $e');
        }

        // Refresh account status
        await fetchAccountStatus();

        print('✅ ProfileSwitch: Switched to $newRole successfully (same token)');
        return true;
      }

      print('❌ ProfileSwitch: Switch failed - ${response.data['message']}');
      lastSwitchError.value = response.data['message'] ?? 'switch_failed';
      return false;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        // Backend puts extra data in 'errors' key (not 'data') for error responses
        final errors = data['errors'];
        final action = (errors is Map<String, dynamic>) ? errors['action'] as String? : null;
        final merchantStatus = (errors is Map<String, dynamic>) ? errors['merchant_status'] as String? : null;
        final registrationStep = (errors is Map<String, dynamic>) ? errors['registration_step'] : null;
        final message = data['message'] as String?;
        lastSwitchError.value = message ?? 'switch_failed';
        lastSwitchAction.value = action;
        lastMerchantStatus.value = merchantStatus;
        lastRegistrationStep.value = registrationStep?.toString();
        print('❌ ProfileSwitch: Switch failed - action: $action, status: $merchantStatus, step: $registrationStep, message: $message');
      } else {
        lastSwitchError.value = 'switch_failed';
        print('❌ ProfileSwitch: Error switching role: $e');
      }
      return false;
    } catch (e) {
      lastSwitchError.value = 'switch_failed';
      print('❌ ProfileSwitch: Error switching role: $e');
      return false;
    } finally {
      isSwitching.value = false;
    }
  }

  // ─── Merchant Activation ───

  /// Activate a merchant profile for the current customer.
  /// This creates a new Merchant record linked to the customer.
  ///
  /// In the unified model:
  /// - Token stays the same (Customer token)
  /// - Merchant record is created and linked via unified_accounts
  /// - User is switched to merchant mode
  /// - User must complete onboarding to access merchant features
  ///
  /// Returns true on success. After success, user can switch to merchant mode.
  Future<bool> activateMerchant() async {
    try {
      isSwitching.value = true;
      print('🏪 ProfileSwitch: Activating merchant profile...');

      final response = await _apiClient.post('/account/activate-merchant');

      final statusCode = response.statusCode ?? 0;
      if ((statusCode == 200 || statusCode == 201) && response.data['success'] == true) {
        // Refresh account status to see the new merchant
        await fetchAccountStatus();

        print('✅ ProfileSwitch: Merchant profile activated');
        return true;
      }

      print('❌ ProfileSwitch: Merchant activation failed - ${response.data['message']}');
      return false;
    } catch (e) {
      print('❌ ProfileSwitch: Error activating merchant: $e');
      return false;
    } finally {
      isSwitching.value = false;
    }
  }

  // ─── Notifications ───

  /// Fetch all notifications across both roles.
  /// Returns a combined list with role tagging.
  Future<List<Map<String, dynamic>>> fetchAllNotifications({int page = 1}) async {
    try {
      final response = await _apiClient.get('/account/all-notifications', queryParameters: {
        'page': page,
      });

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> items = response.data['data']['notifications'] ?? [];
        return items.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      print('❌ ProfileSwitch: Error fetching notifications: $e');
      return [];
    }
  }

  // ─── Helpers ───

  /// Get locally cached active role.
  Future<String> getActiveRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('active_role') ?? 'customer';
  }

  /// Whether the user currently has a merchant profile available.
  bool get hasMerchantProfile => accountStatus.value?.hasMerchantProfile ?? false;

  /// Whether the user is currently in merchant mode.
  bool get isMerchantMode => accountStatus.value?.isMerchantMode ?? false;

  /// Whether the user is currently in customer mode.
  bool get isCustomerMode => accountStatus.value?.isCustomerMode ?? true;

  /// Quick check for whether we can show the "switch" button.
  bool get canSwitch => accountStatus.value?.canSwitchToMerchant ?? false;
}
