import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/api_response.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/services/language_service.dart';
import '../../../core/services/profile_switch_service.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

class AuthService extends getx.GetxService {
  final ApiClient _apiClient = ApiClient.instance;
  final getx.Rx<UserModel?> currentUser = getx.Rx<UserModel?>(null);
  final getx.RxBool isLoggedIn = false.obs;
  final getx.RxBool isLoading = false.obs;
  final getx.RxString userType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  // Load user data from local storage
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');
      final savedUserType = prefs.getString('user_type');

      if (token != null && userData != null) {
        final userJson = jsonDecode(userData);
        currentUser.value = UserModel.fromJson(userJson);
        isLoggedIn.value = true;

        // Load saved user type
        if (savedUserType != null) {
          userType.value = savedUserType;
        }
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }

  // Save user data to local storage
  // [skipLanguageUpdate] - إذا true، لا يحدث لغة التطبيق (يُستخدم بعد تعديل الملف الشخصي)
  Future<void> _saveUserToStorage(UserModel user, String token, {bool skipLanguageUpdate = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_data', jsonEncode(user.toJson()));

      currentUser.value = user;
      isLoggedIn.value = true;

      // ✅ Update language from user profile ONLY if not skipped
      // نتخطى التحديث بعد تعديل الملف الشخصي لمنع تغيير لغة التطبيق
      if (!skipLanguageUpdate) {
        try {
          final languageService = LanguageService.instance;
          final userData = user.toJson();
          await languageService.updateLanguageFromUserProfile(userData);
        } catch (e) {
          print('Error updating language from user data: $e');
        }
      } else {
        print('⏭️ AUTH: Skipping language update in _saveUserToStorage');
      }
    } catch (e) {
      print('Error saving user to storage: $e');
    }
  }

  // Save user type to local storage
  Future<void> _saveUserType(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', type);
      userType.value = type;
    } catch (e) {
      print('Error saving user type: $e');
    }
  }

  // تحديث التوكن في البصمة إذا كانت مفعلة (تجديد التوكن بعد login ناجح)
  Future<void> _updateBiometricTokenIfEnabled(
    String newToken,
    String userType,
    UserModel user,
  ) async {
    try {
      if (getx.Get.isRegistered<BiometricService>()) {
        final biometricService = getx.Get.find<BiometricService>();
        
        // إذا كانت البصمة مفعلة، تحديث التوكن والبيانات بدون طلب مصادقة إضافية
        if (biometricService.isBiometricEnabled.value) {
          await biometricService.updateCredentialsWithoutAuth(
            token: newToken,
            userType: userType,
            userId: user.id.toString(),
            phoneNumber: user.phoneNumber ?? '',
          );
          
          print('✅ Biometric credentials updated with new token after login');
        }
      }
    } catch (e) {
      print('⚠️ Error updating biometric token: $e');
      // لا نريد أن يفشل تسجيل الدخول بسبب مشكلة في البصمة
    }
  }

  // Clear user data from local storage
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if token exists before clearing
      final existingToken = prefs.getString('auth_token');
      print('🗑️ CLEARING STORAGE: Token exists: ${existingToken != null}');

      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('user_type');

      // Verify token is actually removed
      final tokenAfterClear = prefs.getString('auth_token');
      print('🗑️ STORAGE CLEARED: Token removed: ${tokenAfterClear == null}');

      currentUser.value = null;
      isLoggedIn.value = false;
      userType.value = '';

      print(
          '🗑️ USER STATE CLEARED: isLoggedIn = ${isLoggedIn.value}, currentUser = ${currentUser.value}');
    } catch (e) {
      print('❌ Error clearing user from storage: $e');
    }
  }

  /// الحصول على التوكن الحالي
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// حفظ التوكن (للاستخدام مع البصمة)
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      isLoggedIn.value = true;
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  /// حفظ التوكن ونوع المستخدم (للاستخدام مع البصمة)
  Future<void> saveTokenWithUserType(String token, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_type', type);
      isLoggedIn.value = true;
      userType.value = type;
      print('✅ Token and user type saved: $type');
    } catch (e) {
      print('Error saving token with user type: $e');
    }
  }

  /// تحميل بيانات المستخدم من السيرفر باستخدام التوكن
  Future<bool> loadUserFromToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final savedUserType = prefs.getString('user_type');
      
      print('🔄 Loading user from token...');
      print('   Token exists: ${token != null}');
      print('   User type: $savedUserType');
      
      if (token == null) {
        print('❌ No token found');
        return false;
      }
      
      // جلب بيانات المستخدم من السيرفر
      final endpoint = savedUserType == 'merchant' 
          ? '/merchant/profile' 
          : '/customer/profile';
      
      print('📡 Fetching profile from: $endpoint');
          
      final response = await _apiClient.get(endpoint);
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final userData = response.data['data'];
        
        // تحميل نوع المستخدم
        if (savedUserType != null) {
          userType.value = savedUserType;
        }
        
        currentUser.value = UserModel.fromJson(userData);
        isLoggedIn.value = true;
        print('✅ User loaded from token successfully');
        return true;
      }
      
      print('❌ Failed to load user: Invalid response');
      return false;
    } catch (e) {
      print('❌ Error loading user from token: $e');
      if (e is DioException) {
        print('   Status code: ${e.response?.statusCode}');
        print('   Response: ${e.response?.data}');
      }
      return false;
    }
  }

  /// تجديد التوكن من السيرفر (للبصمة)
  /// يستخدم التوكن المحفوظ في البصمة لطلب توكن جديد
  Future<RefreshTokenResult?> refreshToken({String? oldToken}) async {
    try {
      print('🔄 Refreshing token...');
      
      // استخدام التوكن المُمرر أو محاولة الحصول عليه من storage
      String? tokenToUse = oldToken ?? await getToken();
      
      if (tokenToUse == null || tokenToUse.isEmpty) {
        print('❌ No token available for refresh');
        return null;
      }
      
      print('🔄 Using token: ${tokenToUse.substring(0, 10)}...');
      
      // إرسال الطلب مع التوكن القديم في الـ header
      final response = await _apiClient.post(
        '/auth/refresh-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $tokenToUse',
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        final newToken = data['token'] as String;
        final refreshedUserType = data['user_type'] as String;
        
        // حفظ التوكن الجديد
        await saveTokenWithUserType(newToken, refreshedUserType);
        
        print('✅ Token refreshed successfully');
        return RefreshTokenResult(
          token: newToken,
          userType: refreshedUserType,
        );
      }
      
      print('❌ Failed to refresh token: Invalid response');
      return null;
    } catch (e) {
      print('❌ Error refreshing token: $e');
      if (e is DioException) {
        print('   Status code: ${e.response?.statusCode}');
        print('   Response: ${e.response?.data}');
      }
      return null;
    }
  }

  /// تسجيل الدخول بالبصمة - يُنشئ توكن جديد بناءً على بيانات البصمة المحفوظة
  /// لا يحتاج توكن صالح - الجهاز يتولى المصادقة
  Future<BiometricLoginApiResult?> biometricLoginApi({
    required String phoneNumber,
    required String userType,
    required String userId,
  }) async {
    try {
      print('🔐 API: Biometric login request...');
      print('   Phone: $phoneNumber');
      print('   User type: $userType');
      print('   User ID: $userId');
      
      final response = await _apiClient.post(
        '/auth/biometric-login',
        data: {
          'phone_number': phoneNumber,
          'user_type': userType,
          'user_id': int.parse(userId),
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        final newToken = data['token'] as String;
        final returnedUserType = data['user_type'] as String;
        
        // حفظ التوكن الجديد
        await saveTokenWithUserType(newToken, returnedUserType);
        
        print('✅ Biometric login API successful');
        return BiometricLoginApiResult(
          token: newToken,
          userType: returnedUserType,
        );
      }
      
      print('❌ Biometric login API failed: Invalid response');
      return null;
    } catch (e) {
      print('❌ Error in biometric login API: $e');
      if (e is DioException) {
        print('   Status code: ${e.response?.statusCode}');
        print('   Response: ${e.response?.data}');
      }
      return null;
    }
  }

  /// الحصول على معرف المستخدم الحالي
  int? get currentUserId => currentUser.value?.id;

  // Send login OTP
  Future<ApiResponse<SendOTPResponse>> sendLoginOTP(
      LoginRequest request) async {
    try {
      isLoading.value = true;

      // Use unified endpoint that auto-detects user type
      const endpoint = '/auth/send-login-otp';

      final response = await _apiClient.post(endpoint, data: request.toJson());

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => SendOTPResponse.fromJson(data),
        );

        // Store detected user type if available
        if (response.data['data'] != null &&
            response.data['data']['user_type'] != null) {
          await _saveUserType(response.data['data']['user_type']);
        }

        return apiResponse;
      } else {
        return ApiResponse<SendOTPResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to send OTP',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<SendOTPResponse>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<SendOTPResponse>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Verify login OTP
  Future<ApiResponse<LoginResponse>> verifyLoginOTP(
      OTPVerificationRequest request) async {
    try {
      isLoading.value = true;

      // Use unified endpoint that auto-detects user type
      const endpoint = '/auth/verify-login-otp';

      // Build payload for unified backend
      final cleanedCode = request.otpCode.replaceAll(RegExp(r'[^0-9]'), '');
      final payload = {
        'phone_number': request.phoneNumber,
        'otp': cleanedCode,
        'country_code': request.countryCode,
      };

      print('🚀 UNIFIED LOGIN OTP REQUEST: $endpoint');
      print('📤 Payload: $payload');

      final response = await _apiClient.post(endpoint, data: payload);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => LoginResponse.fromJson(data),
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          await _saveUserToStorage(
              apiResponse.data!.user, apiResponse.data!.token);

          // Save user type from response
          if (response.data['data'] != null &&
              response.data['data']['user_type'] != null) {
            await _saveUserType(response.data['data']['user_type']);
          }

          // تحديث التوكن في البصمة إذا كانت مفعلة
          await _updateBiometricTokenIfEnabled(
            apiResponse.data!.token,
            response.data['data']['user_type'] ?? 'customer',
            apiResponse.data!.user,
          );

          // Associate FCM token with authenticated user
          try {
            if (getx.Get.isRegistered<FCMService>()) {
              await FCMService.instance.associateWithUser();
            }
          } catch (e) {
            print('Error associating FCM token: $e');
          }

          // Fetch unified account status (for profile switching)
          try {
            if (getx.Get.isRegistered<ProfileSwitchService>()) {
              await getx.Get.find<ProfileSwitchService>().fetchAccountStatus();
            }
          } catch (e) {
            print('Error fetching account status: $e');
          }
        }

        return apiResponse;
      } else {
        return ApiResponse<LoginResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to verify OTP',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Register customer
  Future<ApiResponse<RegistrationResponse>> registerCustomer(
      CustomerRegistrationRequest request) async {
    try {
      isLoading.value = true;

      final response =
          await _apiClient.post('/customer/register', data: request.toJson());

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => RegistrationResponse.fromJson(data),
        );
        return apiResponse;
      } else {
        return ApiResponse<RegistrationResponse>(
          success: false,
          message: response.data['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<RegistrationResponse>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<RegistrationResponse>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Register merchant
  Future<ApiResponse<RegistrationResponse>> registerMerchant(
      MerchantRegistrationRequest request) async {
    try {
      isLoading.value = true;

      final response =
          await _apiClient.post('/merchant/register', data: request.toJson());

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => RegistrationResponse.fromJson(data),
        );
        return apiResponse;
      } else {
        return ApiResponse<RegistrationResponse>(
          success: false,
          message: response.data['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<RegistrationResponse>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<RegistrationResponse>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Verify registration OTP
  Future<ApiResponse<OTPVerificationResponse>> verifyRegistrationOTP(
      OTPVerificationRequest request) async {
    try {
      isLoading.value = true;

      final userType = request.userType ?? 'customer';
      final endpoint = userType == 'customer'
          ? '/customer/verify-otp'
          : '/merchant/verify-otp';

      // Build payload to match backend expectation: use 'otp' for registration OTP
      final cleanedCode = request.otpCode.replaceAll(RegExp(r'[^0-9]'), '');
      final payload = {
        'phone_number': request.phoneNumber,
        'otp': cleanedCode,
        'country_code': request.countryCode,
        if (request.userType != null) 'user_type': request.userType!,
      };

      print('🚀 REGISTRATION OTP REQUEST: $endpoint');
      print('📤 Payload: $payload');

      final response = await _apiClient.post(endpoint, data: payload);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => OTPVerificationResponse.fromJson(data),
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          await _saveUserToStorage(
              apiResponse.data!.user, apiResponse.data!.token);

          // Save user type for new registration
          await _saveUserType(userType);

          // Persist active_role explicitly so the unified-account UI
          // immediately treats the new account as the correct role
          // (default 'customer'), without relying on /account/status.
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('active_role', userType);
          } catch (e) {
            print('Error saving active_role after registration: $e');
          }

          // Associate FCM token with newly registered user
          try {
            if (getx.Get.isRegistered<FCMService>()) {
              await FCMService.instance.associateWithUser();
              print('✅ FCM token associated with new $userType');
            }
          } catch (e) {
            print('Error associating FCM token after registration: $e');
          }

          // Fetch unified account status (for profile switching)
          try {
            if (getx.Get.isRegistered<ProfileSwitchService>()) {
              await getx.Get.find<ProfileSwitchService>().fetchAccountStatus();
            }
          } catch (e) {
            print('Error fetching account status after registration: $e');
          }
        }

        return apiResponse;
      } else {
        return ApiResponse<OTPVerificationResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to verify OTP',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<OTPVerificationResponse>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<OTPVerificationResponse>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP using unified endpoint
  Future<ApiResponse<SendOTPResponse>> resendOTP(
      ResendOTPRequest request) async {
    try {
      isLoading.value = true;

      // Use unified endpoint
      const endpoint = '/auth/resend-otp';

      final response = await _apiClient.post(endpoint, data: request.toJson());

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => SendOTPResponse.fromJson(data),
        );

        // Print OTP code clearly for testing
        if (response.data['data'] != null &&
            response.data['data']['verification_code'] != null) {
          print(
              '🎯🎯🎯 RESENT OTP CODE: ${response.data['data']['verification_code']} 🎯🎯🎯');
          print('📱 Phone: ${request.phoneNumber}');
          print('👤 User Type: ${request.userType}');
          print('🎯🎯🎯 USE THIS CODE IN THE OTP SCREEN 🎯🎯🎯');
        }

        return apiResponse;
      } else {
        return ApiResponse<SendOTPResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to resend OTP',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<SendOTPResponse>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<SendOTPResponse>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<ApiResponse<void>> logout({
    bool suppressUnauthorizedToast = true,
    String? postLogoutToastMessage,
  }) async {
    try {
      isLoading.value = true;

      if (suppressUnauthorizedToast) {
        // Prevent the global 401 handler from showing "please login again"
        // while we intentionally clear tokens during logout.
        _apiClient.suppressUnauthorizedFor(const Duration(seconds: 10));
      }

      // Deactivate FCM token before logout
      try {
        if (getx.Get.isRegistered<FCMService>()) {
          await FCMService.instance.deactivate();
        }
      } catch (e) {
        print('Error deactivating FCM token: $e');
      }

      // ⚠️ لا نعطل البصمة عند logout - سيتم تحديث التوكن تلقائياً
      // عند تسجيل دخول ناجح أو من خلال refresh token

      // Determine the correct logout endpoint based on user type
      final userType = currentUser.value?.userType ?? 'customer';
      final endpoint =
          userType == 'customer' ? '/customer/logout' : '/merchant/logout';

      print('🚪 LOGOUT REQUEST: $endpoint');

      // Call logout API with authentication header
      final response = await _apiClient.post(endpoint);

      print('✅ LOGOUT RESPONSE: ${response.statusCode}');

      // Clear local storage regardless of API response
      await _clearUserFromStorage();

      // If we have a post-logout message (e.g., account deletion flow),
      // store it to show on the login screen after navigation.
      if (postLogoutToastMessage != null && postLogoutToastMessage.trim().isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('post_logout_toast', postLogoutToastMessage.trim());
        } catch (_) {
          // ignore
        }
      }

      // Also clear ApiClient auth data
      await _apiClient.clearAuthData();

      return ApiResponse<void>(
        success: true,
        message: 'Logged out successfully',
      );
    } catch (e) {
      print('❌ LOGOUT ERROR: $e');
      // Clear local storage even if API call fails
      await _clearUserFromStorage();

      if (postLogoutToastMessage != null && postLogoutToastMessage.trim().isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('post_logout_toast', postLogoutToastMessage.trim());
        } catch (_) {
          // ignore
        }
      }

      // Also clear ApiClient auth data
      await _apiClient.clearAuthData();

      return ApiResponse<void>(
        success: true,
        message: 'Logged out successfully',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value && currentUser.value != null;

  // Get current user
  UserModel? get user => currentUser.value;

  // Get stored user type
  String get storedUserType => userType.value;

  // Check if user is customer
  bool get isCustomer => currentUser.value?.isCustomer ?? false;

  // Check if user is merchant
  bool get isMerchant => currentUser.value?.isMerchant ?? false;

  /// Get the appropriate home route based on user type
  String getHomeRoute() {
    if (storedUserType == 'merchant') {
      return '/merchant-dashboard';
    } else {
      return '/home'; // Default for customers
    }
  }

  /// Check if user should be redirected based on stored user type
  bool shouldRedirectToMerchantDashboard() {
    return isAuthenticated && storedUserType == 'merchant';
  }

  // Update customer profile
  Future<ApiResponse<UserModel>> updateCustomerProfile(
      CustomerProfileUpdateRequest request) async {
    try {
      isLoading.value = true;

      print('🔄 PROFILE UPDATE REQUEST: /customer/profile');
      print('📤 Payload: ${request.toJson()}');

      final response =
          await _apiClient.put('/customer/profile', data: request.toJson());

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => UserModel.fromJson(data['customer']),
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          // ⚠️ مهم: نحفظ اللغة الحالية للتطبيق قبل التحديث (من LanguageService وليس من المستخدم)
          final languageService = LanguageService.instance;
          final currentAppLanguage = languageService.currentLanguage;
          print('🌐 PROFILE UPDATE: Current app language before update: $currentAppLanguage');
          print('🌐 PROFILE UPDATE: Backend returned language: ${apiResponse.data?.preferredLanguage}');
          
          // Update current user data but preserve the app language
          currentUser.value = apiResponse.data!.copyWith(
            preferredLanguage: currentAppLanguage,
          );
          print('✅ PROFILE UPDATE: Language preserved as: $currentAppLanguage');
          
          // ✅ skipLanguageUpdate: true - لمنع تغيير لغة التطبيق
          await _saveUserToStorage(
              currentUser.value!,
              (await SharedPreferences.getInstance()).getString('auth_token') ?? '',
              skipLanguageUpdate: true,
          );
        }

        return apiResponse;
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get customer profile
  // [skipLanguageUpdate] - إذا true، لا يحدث لغة التطبيق (يُستخدم بعد تعديل الملف الشخصي)
  Future<ApiResponse<UserModel>> getCustomerProfile({bool skipLanguageUpdate = false}) async {
    try {
      isLoading.value = true;

      print('📋 GET PROFILE REQUEST: /customer/profile (skipLanguageUpdate: $skipLanguageUpdate)');

      final response = await _apiClient.get('/customer/profile');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) =>
              UserModel.fromJson(data), // ✅ data is already the user object
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          currentUser.value = apiResponse.data;

          // ✅ Update language from user profile ONLY if not skipped
          // نتخطى التحديث بعد تعديل الملف الشخصي لمنع تغيير لغة التطبيق
          if (!skipLanguageUpdate) {
            try {
              final languageService = LanguageService.instance;
              final userData = response.data['data'] as Map<String, dynamic>;
              await languageService.updateLanguageFromUserProfile(userData);
            } catch (e) {
              print('Error updating language from profile: $e');
            }
          } else {
            print('⏭️ PROFILE: Skipping language update (preserving current app language)');
          }
        }

        return apiResponse;
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to get profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update customer avatar
  Future<ApiResponse<UserModel>> updateAvatar(File avatarFile) async {
    try {
      isLoading.value = true;

      print('🔄 AVATAR UPDATE REQUEST: /customer/profile/avatar');

      // Create FormData for file upload
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          avatarFile.path,
          filename: 'avatar.jpg',
        ),
      });

      final response = await _apiClient.post(
        '/customer/profile/avatar',
        data: formData,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => UserModel.fromJson(data['customer']),
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          // Update current user data
          currentUser.value = apiResponse.data;
          await _saveUserToStorage(
            apiResponse.data!,
            (await SharedPreferences.getInstance()).getString('auth_token') ??
                '',
          );
        }

        return apiResponse;
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update avatar',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete customer avatar
  Future<ApiResponse<UserModel>> deleteAvatar() async {
    try {
      isLoading.value = true;

      print('🗑️ AVATAR DELETE REQUEST: /customer/profile/avatar');

      final response = await _apiClient.delete('/customer/profile/avatar');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => UserModel.fromJson(data['customer']),
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          // Update current user data
          currentUser.value = apiResponse.data;
          await _saveUserToStorage(
            apiResponse.data!,
            (await SharedPreferences.getInstance()).getString('auth_token') ??
                '',
          );
        }

        return apiResponse;
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to delete avatar',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

/// نتيجة تجديد التوكن
class RefreshTokenResult {
  final String token;
  final String userType;

  RefreshTokenResult({
    required this.token,
    required this.userType,
  });
}

/// نتيجة تسجيل الدخول بالبصمة من API
class BiometricLoginApiResult {
  final String token;
  final String userType;

  BiometricLoginApiResult({
    required this.token,
    required this.userType,
  });
}
