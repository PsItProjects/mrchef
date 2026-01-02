import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling biometric authentication (fingerprint/face)
class BiometricService extends GetxService {
  static BiometricService get to => Get.find<BiometricService>();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Keys for SharedPreferences
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyBiometricToken = 'biometric_token';
  static const String _keyBiometricUserType = 'biometric_user_type';
  static const String _keyBiometricUserId = 'biometric_user_id';
  static const String _keyBiometricPhoneNumber = 'biometric_phone_number';
  
  // Observable states
  final RxBool isBiometricAvailable = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isLoading = false.obs;
  
  late SharedPreferences _prefs;
  
  /// Initialize the biometric service
  Future<BiometricService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkBiometricAvailability();
    _loadBiometricStatus();
    return this;
  }
  
  /// Check if device supports biometric authentication
  Future<void> _checkBiometricAvailability() async {
    try {
      // Check if device can check biometrics
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (canCheckBiometrics && isDeviceSupported) {
        // Get available biometrics
        final List<BiometricType> availableBiometrics = 
            await _localAuth.getAvailableBiometrics();
        
        isBiometricAvailable.value = availableBiometrics.isNotEmpty;
        
        print('🔐 Biometric available: ${isBiometricAvailable.value}');
        print('🔐 Available biometrics: $availableBiometrics');
      } else {
        isBiometricAvailable.value = false;
        print('🔐 Device does not support biometrics');
      }
    } on PlatformException catch (e) {
      print('🔐 Error checking biometric availability: $e');
      isBiometricAvailable.value = false;
    }
  }
  
  /// Load saved biometric status from preferences
  void _loadBiometricStatus() {
    isBiometricEnabled.value = _prefs.getBool(_keyBiometricEnabled) ?? false;
    
    // If biometric is enabled but no token saved, disable it
    if (isBiometricEnabled.value && !hasSavedCredentials) {
      isBiometricEnabled.value = false;
      _prefs.setBool(_keyBiometricEnabled, false);
    }
    
    print('🔐 Biometric enabled: ${isBiometricEnabled.value}');
  }
  
  /// Check if there are saved biometric credentials
  bool get hasSavedCredentials {
    final token = _prefs.getString(_keyBiometricToken);
    final userType = _prefs.getString(_keyBiometricUserType);
    return token != null && token.isNotEmpty && userType != null;
  }
  
  /// Get saved user type (customer/merchant)
  String? get savedUserType => _prefs.getString(_keyBiometricUserType);
  
  /// Get saved user ID
  String? get savedUserId => _prefs.getString(_keyBiometricUserId);
  
  /// Get saved phone number
  String? get savedPhoneNumber => _prefs.getString(_keyBiometricPhoneNumber);
  
  /// Get saved token
  String? get savedToken => _prefs.getString(_keyBiometricToken);
  
  /// Enable biometric login and save credentials
  /// This replaces any existing saved credentials
  Future<bool> enableBiometricLogin({
    required String token,
    required String userType,
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      isLoading.value = true;
      
      // First authenticate with biometric to confirm user identity
      final bool authenticated = await authenticate(
        reason: 'يرجى التحقق من هويتك لتفعيل تسجيل الدخول بالبصمة',
      );
      
      if (!authenticated) {
        print('🔐 Biometric authentication failed during setup');
        return false;
      }
      
      // Clear any existing credentials first (ensure only one token)
      await _clearCredentials();
      
      // Save new credentials
      await _prefs.setString(_keyBiometricToken, token);
      await _prefs.setString(_keyBiometricUserType, userType);
      await _prefs.setString(_keyBiometricUserId, userId);
      await _prefs.setString(_keyBiometricPhoneNumber, phoneNumber);
      await _prefs.setBool(_keyBiometricEnabled, true);
      
      isBiometricEnabled.value = true;
      
      print('🔐 Biometric login enabled for $userType (ID: $userId)');
      return true;
    } catch (e) {
      print('🔐 Error enabling biometric login: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Disable biometric login and clear saved credentials
  Future<bool> disableBiometricLogin() async {
    try {
      isLoading.value = true;
      
      await _clearCredentials();
      await _prefs.setBool(_keyBiometricEnabled, false);
      
      isBiometricEnabled.value = false;
      
      print('🔐 Biometric login disabled');
      return true;
    } catch (e) {
      print('🔐 Error disabling biometric login: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Clear saved credentials
  Future<void> _clearCredentials() async {
    await _prefs.remove(_keyBiometricToken);
    await _prefs.remove(_keyBiometricUserType);
    await _prefs.remove(_keyBiometricUserId);
    await _prefs.remove(_keyBiometricPhoneNumber);
  }
  
  /// Authenticate using biometric
  Future<bool> authenticate({String? reason}) async {
    try {
      if (!isBiometricAvailable.value) {
        print('🔐 Biometric not available');
        return false;
      }
      
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason ?? 'يرجى التحقق من هويتك لتسجيل الدخول',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
      
      print('🔐 Biometric authentication result: $authenticated');
      return authenticated;
    } on PlatformException catch (e) {
      print('🔐 Biometric authentication error: $e');
      return false;
    }
  }
  
  /// Perform biometric login - returns credentials if successful
  Future<BiometricLoginResult?> loginWithBiometric() async {
    try {
      isLoading.value = true;
      
      if (!isBiometricEnabled.value || !hasSavedCredentials) {
        print('🔐 Biometric login not enabled or no saved credentials');
        return null;
      }
      
      // Authenticate with biometric
      final bool authenticated = await authenticate();
      
      if (!authenticated) {
        print('🔐 Biometric authentication failed');
        return null;
      }
      
      // Return saved credentials
      final result = BiometricLoginResult(
        token: savedToken!,
        userType: savedUserType!,
        userId: savedUserId!,
        phoneNumber: savedPhoneNumber!,
      );
      
      print('🔐 Biometric login successful for ${result.userType}');
      return result;
    } catch (e) {
      print('🔐 Error during biometric login: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update saved token (e.g., when token is refreshed)
  Future<void> updateToken(String newToken) async {
    if (isBiometricEnabled.value) {
      await _prefs.setString(_keyBiometricToken, newToken);
      print('🔐 Biometric token updated');
    }
  }
  
  /// تحديث بيانات البصمة بدون طلب مصادقة (يستخدم بعد login ناجح لتجديد التوكن)
  Future<void> updateCredentialsWithoutAuth({
    required String token,
    required String userType,
    required String userId,
    required String phoneNumber,
  }) async {
    if (isBiometricEnabled.value) {
      try {
        await _prefs.setString(_keyBiometricToken, token);
        await _prefs.setString(_keyBiometricUserType, userType);
        await _prefs.setString(_keyBiometricUserId, userId);
        await _prefs.setString(_keyBiometricPhoneNumber, phoneNumber);
        print('✅ Biometric credentials updated (token refreshed)');
      } catch (e) {
        print('❌ Error updating biometric credentials: $e');
      }
    }
  }
  
  /// Called when user logs out - optionally clear biometric data
  Future<void> onLogout({bool clearBiometric = false}) async {
    if (clearBiometric) {
      await disableBiometricLogin();
    }
  }
}

/// Result of biometric login
class BiometricLoginResult {
  final String token;
  final String userType;
  final String userId;
  final String phoneNumber;
  
  BiometricLoginResult({
    required this.token,
    required this.userType,
    required this.userId,
    required this.phoneNumber,
  });
  
  bool get isCustomer => userType == 'customer';
  bool get isMerchant => userType == 'merchant';
}
