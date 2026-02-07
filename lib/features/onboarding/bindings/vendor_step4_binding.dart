import 'package:get/get.dart';
import '../controllers/vendor_step4_controller.dart';

class VendorStep4Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorStep4Controller>(() => VendorStep4Controller());
  }
}
