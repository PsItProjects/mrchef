import 'package:get/get.dart';
import 'package:mrsheaf/features/merchant/controllers/edit_product_controller.dart';

class EditProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProductController>(() => EditProductController());
  }
}

