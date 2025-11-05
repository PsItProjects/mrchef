import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' as getx;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../services/language_service.dart';
import '../localization/translation_helper.dart';

class ApiClient {

  late Dio _dio;
  static ApiClient? _instance;
  bool _isHandlingUnauthorized = false; // Flag to prevent multiple redirects

  ApiClient._internal() {
    _dio = Dio();
    _setupInterceptors();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }
  
  void _setupInterceptors() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60); // Increased for file uploads
    _dio.options.receiveTimeout = const Duration(seconds: 300); // 5 minutes for large files
    _dio.options.sendTimeout = const Duration(seconds: 300); // 5 minutes for file uploads

    print('🔧 ApiClient initialized with: ${ApiConstants.currentServerInfo}');
    
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token if available
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Add language header from LanguageService
          try {
            final languageService = LanguageService.instance;
            final language = languageService.currentLanguage;
            options.headers['X-Language'] = language;
            options.headers['Accept-Language'] = language;
          } catch (e) {
            // Fallback to stored preference or default
            final language = prefs.getString('app_language') ?? 'en';
            options.headers['X-Language'] = language;
            options.headers['Accept-Language'] = language;
          }
          
          // Add content type
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          
          print('🚀 REQUEST: ${options.method} ${options.uri}');
          print('📤 Headers: ${options.headers}');
          if (options.data != null) {
            print('📤 Data: ${options.data}');
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
          print('📥 Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('❌ Message: ${error.message}');
          print('❌ Data: ${error.response?.data}');

          // Handle token expiration (401 Unauthorized)
          if (error.response?.statusCode == 401) {
            // Only handle if it's a token expiration, not a login failure
            final uri = error.requestOptions.uri.toString();
            final isLoginRequest = uri.contains('/login') ||
                                   uri.contains('/verify-login-otp') ||
                                   uri.contains('/verify-otp');

            if (!isLoginRequest) {
              _handleUnauthorized();
            }
          }

          handler.next(error);
        },
      ),
    );
  }
  
  void _handleUnauthorized() async {
    // Prevent multiple simultaneous redirects
    if (_isHandlingUnauthorized) {
      print('⚠️ UNAUTHORIZED: Already handling, skipping...');
      return;
    }

    _isHandlingUnauthorized = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get user type BEFORE clearing data
      final userType = prefs.getString('user_type') ?? 'customer';

      print('🔒 UNAUTHORIZED: Token expired for user type: $userType');

      // Clear authentication data
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('user_type');

      // Use WidgetsBinding to ensure navigation happens after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          // Check if GetX is ready and we have a valid context
          if (getx.Get.isRegistered<getx.GetMaterialController>()) {
            // Determine login route based on user type
            final loginRoute = '/login'; // Same login screen for both types

            print('🔄 UNAUTHORIZED: Redirecting to $loginRoute');

            // Navigate to login screen
            getx.Get.offAllNamed(loginRoute);

            // Show session expired message ONCE
            getx.Get.snackbar(
              TranslationHelper.tr('session_expired'),
              TranslationHelper.tr('please_login_again'),
              snackPosition: getx.SnackPosition.BOTTOM,
              backgroundColor: getx.Get.theme.colorScheme.error.withOpacity(0.1),
              colorText: getx.Get.theme.colorScheme.error,
              duration: const Duration(seconds: 3),
            );

            // Reset flag after navigation
            Future.delayed(const Duration(seconds: 2), () {
              _isHandlingUnauthorized = false;
            });
          } else {
            print('⚠️ GetX not ready for navigation, will retry...');
            // Retry after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (getx.Get.isRegistered<getx.GetMaterialController>()) {
                getx.Get.offAllNamed('/login');

                // Reset flag after navigation
                Future.delayed(const Duration(seconds: 2), () {
                  _isHandlingUnauthorized = false;
                });
              } else {
                _isHandlingUnauthorized = false;
              }
            });
          }
        } catch (e) {
          print('❌ Navigation error in _handleUnauthorized: $e');
          _isHandlingUnauthorized = false;
        }
      });
    } catch (e) {
      print('❌ Error in _handleUnauthorized: $e');
      _isHandlingUnauthorized = false;
    }
  }

  /// Clear authentication data (used during logout)
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('user_type');

      print('🗑️ API CLIENT: Authentication data cleared');
    } catch (e) {
      print('❌ API CLIENT: Error clearing auth data: $e');
    }
  }

  /// Clear all cached data when language changes
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all cached API responses
      final keys = prefs.getKeys().where((key) =>
        key.startsWith('cache_') ||
        key.startsWith('products_') ||
        key.startsWith('categories_') ||
        key.startsWith('kitchens_')
      ).toList();

      for (String key in keys) {
        await prefs.remove(key);
      }

      print('🗑️ ApiClient: Cache cleared successfully');
    } catch (e) {
      print('❌ ApiClient: Error clearing cache: $e');
    }
  }
  
  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
