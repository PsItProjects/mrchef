import 'package:get/get.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
  }
}
