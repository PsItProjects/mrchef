import 'package:get/get.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_main_controller.dart';
import 'package:mrsheaf/core/services/merchant_language_service.dart';
import 'package:mrsheaf/features/merchant/services/merchant_settings_service.dart';
import 'package:mrsheaf/features/merchant/services/merchant_profile_service.dart';

class MerchantMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantMainController>(() => MerchantMainController());
    Get.lazyPut<MerchantLanguageService>(() => MerchantLanguageService());
    Get.lazyPut<MerchantSettingsService>(() => MerchantSettingsService());
    Get.lazyPut<MerchantProfileService>(() => MerchantProfileService());
  }
}
