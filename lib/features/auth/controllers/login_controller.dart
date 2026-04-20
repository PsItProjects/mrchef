import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/localization/translation_helper.dart';
import '../../../core/services/toast_service.dart';
import '../services/auth_service.dart';
import '../models/auth_request.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late TextEditingController phoneController;
  late TextEditingController countryCodeController;

  final RxBool isLoading = false.obs;
  final RxBool isPhoneNumberValid = false.obs;
  final RxBool isBiometricLoading = false.obs;
  bool _isInitialized = false;

  final AuthService _authService = Get.find<AuthService>();
  final ApiClient _apiClient = ApiClient.instance;
  BiometricService? _biometricService;
  
  BiometricService get biometricService {
    _biometricService ??= Get.find<BiometricService>();
    return _biometricService!;
  }

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _showPendingPostLogoutToast();
  }

  void _showPendingPostLogoutToast() {
    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final message = prefs.getString('post_logout_toast');
        if (message != null && message.trim().isNotEmpty) {
          await prefs.remove('post_logout_toast');
          ToastService.showInfo(message.trim());
        }
      } catch (_) {
        // ignore
      }
    });
  }

  void _initControllers() {
    if (!_isInitialized) {
      phoneController = TextEditingController();
      countryCodeController = TextEditingController(text: '+966');
      phoneController.addListener(_validatePhoneNumber);
      _isInitialized = true;
    }
  }

  void _validatePhoneNumber() {
    if (_isInitialized) {
      String phoneNumber = phoneController.text.replaceAll(' ', '');
      isPhoneNumberValid.value = phoneNumber.length >= 9;
    }
  }

  String _extractBackendMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }
    }
    return 'unexpected_error'.tr;
  }

  /// Reset phone input for new login attempt
  void resetPhoneInput() {
    if (_isInitialized) {
      phoneController.clear();
      isPhoneNumberValid.value = false;
    }
  }

  Future<void> sendLoginOTP() async {
    if (!isPhoneNumberValid.value) {
      ToastService.showError('enter_valid_phone'.tr);
      return;
    }

    isLoading.value = true;

    try {
      final request = LoginRequest(
        phoneNumber: phoneController.text.replaceAll(' ', ''),
        countryCode: countryCodeController.text,
      );

      final response = await _authService.sendLoginOTP(request);

      if (response.isSuccess) {
        ToastService.showSuccess(response.message);

        // Navigate to OTP verification screen
        final arguments = {
          'phone_number': phoneController.text.replaceAll(' ', ''),
          'country_code': countryCodeController.text,
          'purpose': 'login',
        };

        print('🚀 LOGIN: Navigating to OTP with arguments: $arguments');
        Get.toNamed(AppRoutes.OTP_VERIFICATION, arguments: arguments);
      } else {
        ToastService.showError(response.message);
      }
    } catch (e) {
      ToastService.showError(_extractBackendMessage(e is Object ? e : Exception(e.toString())));
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithFacebook() {
    // Implement Facebook login
    ToastService.showInfo('processing_facebook_login'.tr);
  }

  void loginWithGoogle() {
    // Implement Google login
    ToastService.showInfo('processing_google_login'.tr);
  }

  /// تسجيل الدخول بالبصمة
  Future<void> loginWithBiometric() async {
    if (isBiometricLoading.value) return;
    
    isBiometricLoading.value = true;
    
    // منع عرض رسالة session expired أثناء عملية البصمة
    _apiClient.setBiometricLoginInProgress(true);

    try {
      // التحقق من البصمة أولاً
      final isAuthenticated = await biometricService.authenticate();
      
      if (!isAuthenticated) {
        ToastService.showError(TranslationHelper.tr('biometric_verify_identity'));
        // cleanup and return
        isBiometricLoading.value = false;
        _apiClient.setBiometricLoginInProgress(false);
        return;
      }

      print('🔐 Starting biometric login...');
      
      // محاولة تسجيل الدخول بالتوكن المحفوظ (البصمة تم التحقق منها مسبقاً)
      final result = await biometricService.loginWithBiometric();
      
      print('🔐 Biometric result: ${result != null}');
      
      if (result != null && result.token.isNotEmpty) {
        print('🔐 Token received: ${result.token.substring(0, 10)}...');
        print('🔐 User type: ${result.userType}');
        print('🔐 Active role: ${result.activeRole}');

        // حفظ التوكن ونوع المستخدم في AuthService
        await _authService.saveTokenWithUserType(result.token, result.userType);
        print('🔐 Token saved to AuthService');

        // استعادة الدور النشط الذي كان يستخدمه المستخدم آخر مرة
        // (تاجر أو عميل) - حتى يفتح التطبيق على نفس الواجهة التي تركها
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('active_role', result.activeRole);
        print('🔐 Active role restored: ${result.activeRole}');

        // محاولة تحميل بيانات المستخدم من السيرفر
        print('🔐 Loading user from token...');
        final userLoaded = await _authService.loadUserFromToken();
        print('🔐 User loaded: $userLoaded');

        if (userLoaded) {
          print('✅ Biometric login successful!');
          ToastService.showSuccess(TranslationHelper.tr('biometric_welcome_back'));

          // التوجيه حسب الدور النشط الأخير (وليس userType)
          if (result.shouldOpenAsMerchant) {
            print('🔐 Navigating to merchant home (last active role)...');
            Get.offAllNamed(AppRoutes.MERCHANT_HOME);
          } else {
            print('🔐 Navigating to customer home (last active role)...');
            Get.offAllNamed(AppRoutes.HOME);
          }
        } else {
          // التوكن غير صالح - استخدام API البصمة للحصول على توكن جديد
          print('⚠️ Token expired - calling biometric login API...');
          
          // استدعاء API تسجيل الدخول بالبصمة
          final apiResult = await _authService.biometricLoginApi(
            phoneNumber: result.phoneNumber,
            userType: result.userType,
            userId: result.userId,
          );
          
          if (apiResult != null) {
            print('✅ Biometric API login successful!');

            // تحديث التوكن في البصمة (مع الاحتفاظ بالدور النشط الأخير)
            await biometricService.updateCredentialsWithoutAuth(
              token: apiResult.token,
              userType: apiResult.userType,
              userId: result.userId,
              phoneNumber: result.phoneNumber,
              activeRole: result.activeRole,
            );

            // تحميل بيانات المستخدم مرة أخرى
            final userLoadedAfterApi = await _authService.loadUserFromToken();

            if (userLoadedAfterApi) {
              ToastService.showSuccess(TranslationHelper.tr('biometric_welcome_back'));

              // التوجيه حسب الدور النشط الأخير
              if (result.shouldOpenAsMerchant) {
                Get.offAllNamed(AppRoutes.MERCHANT_HOME);
              } else {
                Get.offAllNamed(AppRoutes.HOME);
              }
            } else {
              _showLoginRequired();
            }
          } else {
            // فشل تسجيل الدخول - يجب تسجيل الدخول يدوياً
            print('❌ Biometric API login failed - manual login required');
            _showLoginRequired();
          }
        }
      } else {
        // فشل المصادقة البيومترية أو لا توجد بيانات محفوظة
        print('❌ Biometric authentication failed or no saved data');
        ToastService.showError(TranslationHelper.tr('biometric_login_manually'));
      }
    } catch (e) {
      print('❌ Biometric login error: $e');
      ToastService.showError(TranslationHelper.tr('biometric_enable_failed'));
    } finally {
      isBiometricLoading.value = false;
      // إعادة تفعيل رسالة session expired
      _apiClient.setBiometricLoginInProgress(false);
    }
  }

  /// عرض رسالة طلب تسجيل الدخول يدوياً
  void _showLoginRequired() {
    ToastService.showWarning(TranslationHelper.tr('biometric_login_manually'));
  }

  /// التحقق من توفر البصمة وتفعيلها
  bool get canShowBiometric {
    try {
      return biometricService.isBiometricAvailable.value && 
             biometricService.isBiometricEnabled.value;
    } catch (e) {
      return false;
    }
  }

  @override
  void onClose() {
    if (_isInitialized) {
      phoneController.removeListener(_validatePhoneNumber);
      phoneController.dispose();
      countryCodeController.dispose();
      _isInitialized = false;
    }
    super.onClose();
  }
}
