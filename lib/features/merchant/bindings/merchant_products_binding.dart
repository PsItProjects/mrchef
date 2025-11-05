import 'package:get/get.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_products_controller.dart';
import 'package:mrsheaf/features/merchant/services/merchant_products_service.dart';

/// Binding for Merchant Products feature
class MerchantProductsBinding extends Bindings {
  @override
  void dependencies() {
    // Register service
    Get.lazyPut<MerchantProductsService>(() => MerchantProductsService());

    // Register controller
    Get.lazyPut<MerchantProductsController>(() => MerchantProductsController());
  }
}

