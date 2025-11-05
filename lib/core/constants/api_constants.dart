class ApiConstants {
  // 🎯 CONTROL VARIABLE - Change this to switch between servers
  static const bool useProductionServer = true; // true = Production, false = Local

  // Server URLs
  static const String _productionUrl = 'https://mr-shife.com/api';

  // Local server URL - Choose based on your device:
  // For Physical Device: Use your computer's IP on local network (e.g., 10.20.20.250)
  // For Android Emulator: Use 10.0.2.2
  // For iOS Simulator: Use 127.0.0.1 or localhost
  static const String _localUrl = 'http://192.168.1.8:8000/api'; // Physical device - Computer IP

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
  static const String kitchens = '/customer/shopping/kitchens'; // Main kitchens/restaurants endpoint
  static const String categoriesPageData = '/customer/shopping/categories-page-data';
  static const String categoriesWithProducts = '/customer/shopping/categories-with-products'; // New combined endpoint

  // Cart endpoints
  static const String cart = '/customer/shopping/cart';
  static const String addToCart = '/customer/shopping/cart/add';

  // Product details endpoints
  static String productDetails(int id) => '/customer/shopping/products/$id';
  static String productReviews(int id) => '/customer/shopping/products/$id/reviews';

  // Kitchen details endpoints
  static String kitchenDetails(int id) => '/customer/shopping/kitchens/$id';
  static String kitchenProducts(int id) => '/customer/shopping/kitchens/$id/products';

  // Favorites endpoints
  static const String favorites = '/customer/shopping/favorites';
  static String addKitchenToFavorites(int id) => '/customer/shopping/favorites/kitchens/$id';
  static String removeKitchenFromFavorites(int id) => '/customer/shopping/favorites/kitchens/$id';
  
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
