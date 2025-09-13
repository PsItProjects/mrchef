import 'package:get/get.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_dashboard_controller.dart';

class MerchantDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantDashboardController>(
      () => MerchantDashboardController(),
    );
  }
}
