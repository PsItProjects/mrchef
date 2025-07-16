import 'package:get/get.dart';
import 'package:mrsheaf/features/auth/controllers/login_controller.dart';
import 'package:mrsheaf/features/auth/controllers/signup_controller.dart';
import 'package:mrsheaf/features/auth/controllers/new_signup_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<SignupController>(() => SignupController());
    Get.lazyPut<NewSignupController>(() => NewSignupController());
  }
}
