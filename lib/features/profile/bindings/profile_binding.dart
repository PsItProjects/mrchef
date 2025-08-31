import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';
import 'package:mrsheaf/features/profile/controllers/edit_profile_controller.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';
import 'package:mrsheaf/features/profile/controllers/my_reviews_controller.dart';
import 'package:mrsheaf/features/profile/controllers/settings_controller.dart';
import 'package:mrsheaf/features/profile/controllers/shipping_addresses_controller.dart';
import 'package:mrsheaf/features/profile/controllers/add_edit_address_controller.dart';
import 'package:mrsheaf/features/profile/services/profile_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<ProfileService>(() => ProfileService(), fenix: true);

    // Controllers
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true) ;
    Get.lazyPut<EditProfileController>(() => EditProfileController() , fenix: true);
    Get.lazyPut<MyOrdersController>(() => MyOrdersController() , fenix: true);
    Get.lazyPut<MyReviewsController>(() => MyReviewsController() , fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController() , fenix: true);
    Get.lazyPut<ShippingAddressesController>(() => ShippingAddressesController() , fenix: true);
    // AddEditAddressController is created dynamically when needed
  }
}
