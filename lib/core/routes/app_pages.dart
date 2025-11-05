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
import 'package:mrsheaf/features/merchant/pages/product_details_screen.dart' as merchant_product_details;
import 'package:mrsheaf/features/merchant/pages/edit_product_screen.dart';
import 'package:mrsheaf/features/merchant/bindings/merchant_main_binding.dart';
import 'package:mrsheaf/features/merchant/bindings/merchant_products_binding.dart';
import 'package:mrsheaf/features/merchant/bindings/add_product_binding.dart';
import 'package:mrsheaf/features/merchant/bindings/edit_product_binding.dart';
import 'package:mrsheaf/features/onboarding/bindings/vendor_step1_binding.dart';
import 'package:mrsheaf/features/onboarding/bindings/vendor_step2_binding.dart';

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
  ];
}
