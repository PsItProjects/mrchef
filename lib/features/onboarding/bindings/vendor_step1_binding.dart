import 'package:get/get.dart';
import 'package:mrsheaf/features/onboarding/controllers/vendor_step1_controller.dart';

class VendorStep1Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorStep1Controller>(() => VendorStep1Controller());
  }
}

