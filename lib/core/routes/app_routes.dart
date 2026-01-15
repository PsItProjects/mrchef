abstract class AppRoutes {
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const FINAL_ONBOARDING = '/final-onboarding';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const OTP_VERIFICATION = '/otp-verification';
  static const HOME = '/home';
  static const PRODUCT_DETAILS = '/product-details';
  static const CATEGORIES = '/categories';
  static const STORE_DETAILS = '/store-details';
  static const SEARCH = '/search';
  static const MERCHANT_HOME = '/merchant-home';
  static const MERCHANT_DASHBOARD = '/merchant-dashboard';
  static const MERCHANT_PRODUCTS = '/merchant/products';
  static const MERCHANT_PRODUCTS_ADD = '/merchant/products/add';
  static const MERCHANT_PRODUCTS_DETAILS = '/merchant/products/details';
  static const MERCHANT_PRODUCTS_EDIT = '/merchant/products/edit';
  static const MERCHANT_ORDER_DETAILS = '/merchant/order-details';
  static const MERCHANT_CHAT = '/merchant/chat';
  static const MERCHANT_STATISTICS = '/merchant/statistics';
  static const MERCHANT_NOTIFICATIONS = '/merchant/notifications';

  // Customer notifications
  static const NOTIFICATIONS = '/notifications';
  
  // Customer orders
  static const MY_ORDERS = '/my-orders';
  static const ORDER_DETAILS = '/orders/:id';

  // Customer reviews
  static const MY_REVIEWS = '/my-reviews';

  // Vendor onboarding routes
  static const VENDOR_STEP1 = '/vendor-step1';
  static const VENDOR_STEP2 = '/vendor-step2';
  static const VENDOR_STEP3 = '/vendor-step3';
  static const VENDOR_STEP4 = '/vendor-step4';

  // Chat routes
  static const CONVERSATIONS = '/conversations';
  static const CHAT = '/chat';
  static const CHECKOUT = '/checkout';

  // Support
  static const SUPPORT_TICKETS = '/support/tickets';
  static const SUPPORT_TICKET_DETAIL = '/support/tickets/:id';
  static const MY_REPORTS = '/support/reports';
  static const REPORT_DETAIL = '/support/reports/:id';

  // Restaurants routes
  static const ALL_RESTAURANTS = '/all-restaurants';
}
