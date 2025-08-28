class ApiConstants {
  // 🎯 CONTROL VARIABLE - Change this to switch between servers
  static const bool useProductionServer = true; // true = Production, false = Local (temporarily using local due to empty production DB)

  // Server URLs
  static const String _productionUrl = 'https://mr-shife-backend-main-ygodva.laravel.cloud/api';
  static const String _localUrl = 'http://127.0.0.1:8000/api'; // Android emulator localhost

  // Base URL for the API (automatically switches based on useProductionServer)
  static String get baseUrl => useProductionServer ? _productionUrl : _localUrl;
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  
  // Customer endpoints
  static const String categories = '/customer/shopping/categories'; // Public route
  static const String products = '/customer/shopping/products'; // Public route
  static const String kitchens = '/customer/shopping/kitchens';
  static const String categoriesPageData = '/customer/shopping/categories-page-data';
  static const String categoriesWithProducts = '/customer/shopping/categories-with-products'; // New combined endpoint

  // Cart endpoints
  static const String cart = '/customer/shopping/cart';
  static const String addToCart = '/customer/shopping/cart/add';

  // Product details endpoints
  static String productDetails(int id) => '/customer/shopping/products/$id';
  static String productReviews(int id) => '/customer/shopping/products/$id/reviews';
  
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
