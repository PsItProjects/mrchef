import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/middleware/auth_middleware.dart';
import 'package:mrsheaf/features/profile/bindings/profile_binding.dart';
import 'package:mrsheaf/features/auth/bindings/auth_binding.dart';
import 'package:mrsheaf/features/auth/bindings/otp_binding.dart';
import 'package:mrsheaf/features/splash/pages/splash_screen.dart';
import 'package:mrsheaf/features/onboarding/pages/onboarding_screen.dart';
import 'package:mrsheaf/features/onboarding/pages/final_onboarding_screen.dart';
import 'package:mrsheaf/features/auth/pages/login_screen.dart';
import 'package:mrsheaf/features/auth/pages/signup_screen.dart';
import 'package:mrsheaf/features/auth/pages/new_signup_screen.dart';
import 'package:mrsheaf/features/auth/pages/otp_verification_screen.dart';
import 'package:mrsheaf/features/onboarding/pages/vendor_step1_screen.dart';
import 'package:mrsheaf/features/onboarding/pages/vendor_step2_screen.dart';
import 'package:mrsheaf/features/onboarding/pages/vendor_step3_screen.dart';
import 'package:mrsheaf/features/onboarding/pages/vendor_step4_screen.dart';
import 'package:mrsheaf/features/home/pages/main_screen.dart';
import 'package:mrsheaf/features/home/bindings/home_binding.dart';
import 'package:mrsheaf/features/product_details/pages/product_details_screen.dart';
import 'package:mrsheaf/features/product_details/bindings/product_details_binding.dart';
import 'package:mrsheaf/features/home/pages/categories_screen.dart';
import 'package:mrsheaf/features/categories/bindings/categories_binding.dart';
import 'package:mrsheaf/features/store_details/pages/store_details_screen.dart';
import 'package:mrsheaf/features/store_details/bindings/store_details_binding.dart';
import 'package:mrsheaf/features/favorites/bindings/favorites_binding.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_dashboard_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_products_screen.dart';
import 'package:mrsheaf/features/merchant/pages/add_product_screen.dart';
import 'package:mrsheaf/features/merchant/pages/product_details_screen.dart'
    as merchant_product_details;
import 'package:mrsheaf/features/merchant/pages/edit_product_screen.dart';
import 'package:mrsheaf/features/merchant/bindings/merchant_main_binding.dart';
import 'package:mrsheaf/features/merchant/bindings/merchant_products_binding.dart';
import 'package:mrsheaf/features/merchant/bindings/add_product_binding.dart';
import 'package:mrsheaf/features/merchant/bindings/edit_product_binding.dart';
import 'package:mrsheaf/features/onboarding/bindings/vendor_step1_binding.dart';
import 'package:mrsheaf/features/onboarding/bindings/vendor_step2_binding.dart';
import 'package:mrsheaf/features/onboarding/bindings/vendor_step4_binding.dart';
import 'package:mrsheaf/features/chat/pages/conversations_screen.dart';
import 'package:mrsheaf/features/chat/pages/chat_screen.dart';
import 'package:mrsheaf/features/chat/bindings/conversations_binding.dart';
import 'package:mrsheaf/features/chat/bindings/chat_binding.dart';
import 'package:mrsheaf/features/checkout/pages/checkout_screen.dart';
import 'package:mrsheaf/features/checkout/bindings/checkout_binding.dart';
import 'package:mrsheaf/features/search/pages/search_screen.dart';
import 'package:mrsheaf/features/search/bindings/search_binding.dart';
import 'package:mrsheaf/features/restaurants/pages/all_restaurants_screen.dart';
import 'package:mrsheaf/features/restaurants/bindings/all_restaurants_binding.dart';
import 'package:mrsheaf/features/products/pages/all_products_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_order_details_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_chat_screen.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_chat_controller.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_statistics_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_notifications_screen.dart';
import 'package:mrsheaf/features/notifications/pages/notifications_screen.dart';
import 'package:mrsheaf/features/profile/pages/order_details_screen.dart';
import 'package:mrsheaf/features/profile/pages/my_reviews_screen.dart';
import 'package:mrsheaf/features/profile/controllers/my_reviews_controller.dart';
import 'package:mrsheaf/features/support/controllers/support_ticket_detail_controller.dart';
import 'package:mrsheaf/features/support/controllers/support_tickets_controller.dart';
import 'package:mrsheaf/features/support/pages/support_ticket_detail_screen.dart';
import 'package:mrsheaf/features/support/pages/support_tickets_screen.dart';
import 'package:mrsheaf/features/reports/controllers/my_reports_controller.dart';
import 'package:mrsheaf/features/reports/controllers/report_detail_controller.dart';
import 'package:mrsheaf/features/reports/pages/my_reports_screen.dart';
import 'package:mrsheaf/features/reports/pages/report_detail_screen.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.FINAL_ONBOARDING,
      page: () => const FinalOnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      middlewares: [GuestMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const NewSignupScreen(),
      binding: AuthBinding(),
      middlewares: [GuestMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.OTP_VERIFICATION,
      page: () => const OtpVerificationScreen(),
      binding: OTPBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.VENDOR_STEP1,
      page: () => const VendorStep1Screen(),
      binding: VendorStep1Binding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.VENDOR_STEP2,
      page: () => const VendorStep2Screen(),
      binding: VendorStep2Binding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.VENDOR_STEP3,
      page: () => const VendorStep3Screen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.VENDOR_STEP4,
      page: () => const VendorStep4Screen(),
      binding: VendorStep4Binding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const MainScreen(),
      bindings: [ProfileBinding(), HomeBinding(), FavoritesBinding()],
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.PRODUCT_DETAILS,
      page: () => const ProductDetailsScreen(),
      binding: ProductDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.CATEGORIES,
      page: () => const CategoriesScreen(),
      binding: CategoriesBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.STORE_DETAILS,
      page: () => const StoreDetailsScreen(),
      binding: StoreDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.MERCHANT_HOME,
      page: () => const MerchantDashboardScreen(),
      binding: MerchantMainBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.MERCHANT_DASHBOARD,
      page: () => const MerchantDashboardScreen(),
      binding: MerchantMainBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.MERCHANT_PRODUCTS,
      page: () => const MerchantProductsScreen(),
      binding: MerchantProductsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.MERCHANT_PRODUCTS_ADD,
      page: () => const AddProductScreen(),
      binding: AddProductBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '${AppRoutes.MERCHANT_PRODUCTS_DETAILS}/:id',
      page: () => const merchant_product_details.ProductDetailsScreen(),
      binding: MerchantProductsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '${AppRoutes.MERCHANT_PRODUCTS_EDIT}/:id',
      page: () => const EditProductScreen(),
      binding: EditProductBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.MERCHANT_ORDER_DETAILS,
      page: () => MerchantOrderDetailsScreen(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.MERCHANT_CHAT,
      page: () => const MerchantChatScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MerchantChatController>(() => MerchantChatController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.MERCHANT_STATISTICS,
      page: () => const MerchantStatisticsScreen(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.CONVERSATIONS,
      page: () => const ConversationsScreen(),
      binding: ConversationsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.CHAT,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.CHECKOUT,
      page: () => const CheckoutScreen(),
      binding: CheckoutBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SEARCH,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ALL_RESTAURANTS,
      page: () => const AllRestaurantsScreen(),
      binding: AllRestaurantsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ALL_PRODUCTS,
      page: () => const AllProductsScreen(),
      transition: Transition.rightToLeft,
    ),
    // Merchant Notifications
    GetPage(
      name: AppRoutes.MERCHANT_NOTIFICATIONS,
      page: () => const MerchantNotificationsScreen(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    // Customer Notifications
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => const NotificationsScreen(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    
    // Customer Order Details
    GetPage(
      name: AppRoutes.ORDER_DETAILS,
      page: () => const OrderDetailsScreen(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Customer Reviews
    GetPage(
      name: AppRoutes.MY_REVIEWS,
      page: () => const MyReviewsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MyReviewsController>(() => MyReviewsController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Support
    GetPage(
      name: AppRoutes.SUPPORT_TICKETS,
      page: () => const SupportTicketsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SupportTicketsController>(() => SupportTicketsController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SUPPORT_TICKET_DETAIL,
      page: () => const SupportTicketDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SupportTicketDetailController>(() => SupportTicketDetailController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Reports
    GetPage(
      name: AppRoutes.MY_REPORTS,
      page: () => const MyReportsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MyReportsController>(() => MyReportsController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.REPORT_DETAIL,
      page: () => const ReportDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportDetailController>(() => ReportDetailController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
  ];
}
