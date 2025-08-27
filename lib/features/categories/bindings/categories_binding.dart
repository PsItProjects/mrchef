import 'package:get/get.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';
import '../services/category_service.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryService>(() => CategoryService(), fenix: true);
    Get.lazyPut<CategoriesController>(() => CategoriesController());
  }
}
