import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import '../../../core/services/biometric_service.dart';
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
  BiometricService? _biometricService;
  
  BiometricService get biometricService {
    _biometricService ??= Get.find<BiometricService>();
    return _biometricService!;
  }

  @override
  void onInit() {
    super.onInit();
    _initControllers();
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

  /// Reset phone input for new login attempt
  void resetPhoneInput() {
    if (_isInitialized) {
      phoneController.clear();
      isPhoneNumberValid.value = false;
    }
  }

  Future<void> sendLoginOTP() async {
    if (!isPhoneNumberValid.value) {
      Get.snackbar(
        'Invalid Phone Number',
        'Please enter a valid phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
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
        Get.snackbar(
          'OTP Sent',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.3),
        );

        // Navigate to OTP verification screen
        final arguments = {
          'phone_number': phoneController.text.replaceAll(' ', ''),
          'country_code': countryCodeController.text,
          'purpose': 'login',
        };

        print('🚀 LOGIN: Navigating to OTP with arguments: $arguments');
        Get.toNamed(AppRoutes.OTP_VERIFICATION, arguments: arguments);
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithFacebook() {
    // Implement Facebook login
    Get.snackbar(
      'Facebook Login',
      'Processing Facebook login...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void loginWithGoogle() {
    // Implement Google login
    Get.snackbar(
      'Google Login',
      'Processing Google login...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// تسجيل الدخول بالبصمة
  Future<void> loginWithBiometric() async {
    if (isBiometricLoading.value) return;
    
    isBiometricLoading.value = true;

    try {
      // التحقق من البصمة أولاً
      final isAuthenticated = await biometricService.authenticate();
      
      if (!isAuthenticated) {
        Get.snackbar(
          'فشل التحقق',
          'لم يتم التعرف على البصمة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
        return;
      }

      print('🔐 Starting biometric login...');
      
      // محاولة تسجيل الدخول بالتوكن المحفوظ
      final result = await biometricService.loginWithBiometric();
      
      print('🔐 Biometric result: ${result != null}');
      
      if (result != null && result.token.isNotEmpty) {
        print('🔐 Token received: ${result.token.substring(0, 10)}...');
        print('🔐 User type: ${result.userType}');
        
        // حفظ التوكن ونوع المستخدم في AuthService
        await _authService.saveTokenWithUserType(result.token, result.userType);
        print('🔐 Token saved to AuthService');
        
        // محاولة تحميل بيانات المستخدم من السيرفر
        print('🔐 Loading user from token...');
        final userLoaded = await _authService.loadUserFromToken();
        print('🔐 User loaded: $userLoaded');
        
        if (userLoaded) {
          print('✅ Biometric login successful!');
          Get.snackbar(
            'تم تسجيل الدخول',
            'مرحباً بعودتك!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.3),
          );

          // التوجيه حسب نوع المستخدم
          if (result.userType == 'merchant') {
            print('🔐 Navigating to merchant home...');
            Get.offAllNamed(AppRoutes.MERCHANT_HOME);
          } else {
            print('🔐 Navigating to customer home...');
            Get.offAllNamed(AppRoutes.HOME);
          }
        } else {
          // التوكن غير صالح - محاولة تجديد التوكن
          print('⚠️ Token expired - trying to refresh...');
          
          final refreshResult = await _authService.refreshToken();
          
          if (refreshResult != null) {
            print('✅ Token refreshed successfully!');
            
            // تحديث التوكن في البصمة
            await biometricService.updateCredentialsWithoutAuth(
              token: refreshResult.token,
              userType: refreshResult.userType,
              userId: result.userId,
              phoneNumber: result.phoneNumber,
            );
            
            // تحميل بيانات المستخدم مرة أخرى
            final userLoadedAfterRefresh = await _authService.loadUserFromToken();
            
            if (userLoadedAfterRefresh) {
              Get.snackbar(
                'تم تسجيل الدخول',
                'مرحباً بعودتك!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withValues(alpha: 0.3),
              );
              
              if (refreshResult.userType == 'merchant') {
                Get.offAllNamed(AppRoutes.MERCHANT_HOME);
              } else {
                Get.offAllNamed(AppRoutes.HOME);
              }
            } else {
              _showLoginRequired();
            }
          } else {
            // فشل تجديد التوكن - يجب تسجيل الدخول يدوياً
            print('❌ Token refresh failed - manual login required');
            _showLoginRequired();
          }
        }
      } else {
        // فشل المصادقة البيومترية أو لا توجد بيانات محفوظة
        print('❌ Biometric authentication failed or no saved data');
        Get.snackbar(
          'فشلت المصادقة',
          'يرجى تسجيل الدخول يدوياً',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
      }
    } catch (e) {
      print('❌ Biometric login error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الدخول بالبصمة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
    } finally {
      isBiometricLoading.value = false;
    }
  }

  /// عرض رسالة طلب تسجيل الدخول يدوياً
  void _showLoginRequired() {
    Get.snackbar(
      'انتهت الجلسة',
      'يرجى تسجيل الدخول برمز التحقق',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.3),
    );
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
