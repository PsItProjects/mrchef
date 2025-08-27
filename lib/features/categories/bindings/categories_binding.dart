import 'package:get/get.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';
import 'package:mrsheaf/features/categories/services/category_service.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    // Register CategoryService first
    Get.lazyPut<CategoryService>(() => CategoryService(), fenix: true);

    // Register CategoriesController
    Get.lazyPut<CategoriesController>(() => CategoriesController());
  }
}
