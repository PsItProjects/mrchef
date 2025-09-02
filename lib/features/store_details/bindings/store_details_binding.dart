import 'package:get/get.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class StoreDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreDetailsController>(
      () => StoreDetailsController(),
    );
  }
}
