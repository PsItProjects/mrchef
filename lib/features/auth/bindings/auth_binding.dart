import 'package:get/get.dart';
import 'package:mrsheaf/features/auth/controllers/login_controller.dart';
import 'package:mrsheaf/features/auth/controllers/signup_controller.dart';
import 'package:mrsheaf/features/auth/controllers/new_signup_controller.dart';

import 'package:mrsheaf/features/auth/services/auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    // Make controllers permanent to prevent disposal on language change
    if (!Get.isRegistered<LoginController>()) {
      Get.put<LoginController>(LoginController(), permanent: true);
    }
    if (!Get.isRegistered<SignupController>()) {
      Get.put<SignupController>(SignupController(), permanent: true);
    }
    if (!Get.isRegistered<NewSignupController>()) {
      Get.put<NewSignupController>(NewSignupController(), permanent: true);
    }
  }
}
