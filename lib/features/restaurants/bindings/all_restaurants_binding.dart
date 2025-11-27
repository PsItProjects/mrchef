import 'package:get/get.dart';
import 'package:mrsheaf/features/restaurants/controllers/all_restaurants_controller.dart';

class AllRestaurantsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllRestaurantsController>(() => AllRestaurantsController());
  }
}

