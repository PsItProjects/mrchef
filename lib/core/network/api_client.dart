import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../services/language_service.dart';

class ApiClient {
  
  late Dio _dio;
  static ApiClient? _instance;
  
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
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

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
          
          // Handle token expiration
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }
          
          handler.next(error);
        },
      ),
    );
  }
  
  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    // Navigate to login screen
    getx.Get.offAllNamed('/login');

    getx.Get.snackbar(
      'Session Expired',
      'Please login again',
      snackPosition: getx.SnackPosition.BOTTOM,
    );
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
