import 'package:get/get.dart';
import '../controllers/vendor_step2_controller.dart';

class VendorStep2Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorStep2Controller>(() => VendorStep2Controller());
  }
}
