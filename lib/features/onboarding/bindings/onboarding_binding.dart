import 'package:get/get.dart';
import 'package:mrsheaf/features/onboarding/controllers/onboarding_controller.dart';
import 'package:mrsheaf/features/onboarding/controllers/vendor_step1_controller.dart';
import 'package:mrsheaf/features/onboarding/controllers/vendor_step2_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
    Get.lazyPut<VendorStep1Controller>(() => VendorStep1Controller());
    Get.lazyPut<VendorStep2Controller>(() => VendorStep2Controller());
  }
}
