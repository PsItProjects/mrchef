import 'package:get/get.dart';
import 'package:mrsheaf/features/auth/controllers/login_controller.dart';
import 'package:mrsheaf/features/auth/controllers/signup_controller.dart';
import 'package:mrsheaf/features/auth/controllers/new_signup_controller.dart';
import 'package:mrsheaf/features/auth/controllers/otp_controller.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<LoginController>(LoginController());
    Get.put<SignupController>(SignupController());
    Get.put<NewSignupController>(NewSignupController());

    // Delete existing OTPController if it exists and create a new one
    if (Get.isRegistered<OTPController>()) {
      Get.delete<OTPController>();
    }
    Get.put<OTPController>(OTPController());
  }
}
