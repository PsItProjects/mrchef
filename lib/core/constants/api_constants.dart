class ApiConstants {
  // 🎯 CONTROL VARIABLE - Change this to switch between servers
  static const bool useProductionServer = true; // true = Production, false = Local

  // Server URLs
  static const String _productionUrl = 'https://mr-shife-backend-main-ygodva.laravel.cloud/api';
  static const String _localUrl = 'http://172.20.20.23:8000/api';

  // Base URL for the API (automatically switches based on useProductionServer)
  static String get baseUrl => useProductionServer ? _productionUrl : _localUrl;
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  
  // Customer endpoints
  static const String categories = '/customer/shopping/categories';
  static const String products = '/customer/shopping/products';
  static const String kitchens = '/customer/shopping/kitchens';
  static const String categoriesPageData = '/customer/shopping/categories-page-data';
  
  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 📝 Server Information
  static String get currentServerInfo {
    return useProductionServer
        ? '🌐 Production Server: $_productionUrl'
        : '🏠 Local Server: $_localUrl';
  }

  // 🔄 Quick switch methods for debugging
  static String get productionUrl => _productionUrl;
  static String get localUrl => _localUrl;
}
