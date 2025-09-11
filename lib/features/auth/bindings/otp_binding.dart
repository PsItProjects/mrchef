import 'package:get/get.dart';
import 'package:mrsheaf/features/auth/controllers/otp_controller.dart';

class OTPBinding extends Bindings {
  @override
  void dependencies() {
    // Delete existing OTPController if it exists and create a new one
    if (Get.isRegistered<OTPController>()) {
      Get.delete<OTPController>();
    }
    Get.put<OTPController>(OTPController());
  }
}
