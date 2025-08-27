import 'package:get/get.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';
import 'package:mrsheaf/features/home/controllers/main_controller.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';
import '../../categories/services/category_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<CategoryService>(() => CategoryService(), fenix: true);

    // Controllers
    Get.lazyPut<MainController>(() => MainController() , fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<CategoriesController>(() => CategoriesController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<FavoritesController>(() => FavoritesController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
