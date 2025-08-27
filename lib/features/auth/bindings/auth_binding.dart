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
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<SignupController>(() => SignupController());
    Get.lazyPut<NewSignupController>(() => NewSignupController());
    Get.lazyPut<OTPController>(() => OTPController());
  }
}
