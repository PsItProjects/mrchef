import 'package:get/get.dart';
import 'package:mrsheaf/core/services/language_service.dart';

class LocalizationBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize language service as singleton
    Get.put<LanguageService>(LanguageService.instance, permanent: true);
  }
}
