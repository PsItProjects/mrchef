import 'package:get/get.dart';

class StoreDetailsController extends GetxController {
  // Store information
  final RxString storeId = ''.obs;
  final RxString storeName = 'Master Chef'.obs;
  final RxString storeLocation = 'Lagos, Nigeria'.obs;
  final RxString storeDescription = 
      '"Discover the flavors of culinary perfection at Master Chef 🍴✨ Indulge in our chef-crafted dishes, where every bite tells a story of passion and fresh, locally sourced ingredients.'.obs;
  final RxDouble storeRating = 4.8.obs;
  final RxString storeImage = 'assets/images/store_image.jpg'.obs;
  final RxString storeProfileImage = 'assets/images/store_profile.jpg'.obs;
  
  // Bottom sheet state
  final RxBool isBottomSheetVisible = false.obs;
  
  // Working hours data
  final RxList<Map<String, dynamic>> workingHours = <Map<String, dynamic>>[
    {
      'day': 'Saturday',
      'startTime': '09:00 AM',
      'endTime': '09:00 PM',
      'isOff': false,
    },
    {
      'day': 'Sunday',
      'startTime': '09:00 AM',
      'endTime': '09:00 PM',
      'isOff': false,
    },
    {
      'day': 'Monday',
      'startTime': '09:00 AM',
      'endTime': '09:00 PM',
      'isOff': false,
    },
    {
      'day': 'Tuesday',
      'startTime': '09:00 AM',
      'endTime': '09:00 PM',
      'isOff': false,
    },
    {
      'day': 'Wednesday',
      'startTime': '09:00 AM',
      'endTime': '09:00 PM',
      'isOff': false,
    },
    {
      'day': 'Thursday',
      'startTime': '09:00 AM',
      'endTime': '09:00 PM',
      'isOff': false,
    },
    {
      'day': 'Friday',
      'startTime': '',
      'endTime': '',
      'isOff': true,
    },
  ].obs;
  
  // Location data
  final RxList<Map<String, dynamic>> locations = <Map<String, dynamic>>[
    {
      'address': '25 rue Robert Latouche, Nice, 06200, Côte D\'azur, France',
      'latitude': 43.7102,
      'longitude': 7.2620,
    },
    {
      'address': '25 rue Robert Latouche, Nice, 06200, Côte D\'azur, France',
      'latitude': 43.7102,
      'longitude': 7.2620,
    },
  ].obs;
  
  // Contact information
  final RxMap<String, dynamic> contactInfo = <String, dynamic>{
    'phone': '+971 764 6553',
    'email': 'jolly@mail.com',
    'whatsapp': '+971 764 6553',
    'facebook': 'facebook.com/jolly',
  }.obs;
  
  // Store products
  final RxList<Map<String, dynamic>> storeProducts = <Map<String, dynamic>>[
    {
      'id': 1,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/images/burger.png',
      'isFavorite': false,
    },
    {
      'id': 2,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/images/burger.png',
      'isFavorite': false,
    },
    {
      'id': 3,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/images/burger.png',
      'isFavorite': false,
    },
    {
      'id': 4,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/images/burger.png',
      'isFavorite': false,
    },
    {
      'id': 5,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/images/burger.png',
      'isFavorite': false,
    },
    {
      'id': 6,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/images/burger.png',
      'isFavorite': false,
    },
  ].obs;
  
  // Notification settings
  final RxBool notificationsEnabled = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Get store ID from route parameters if available
    if (Get.parameters['storeId'] != null) {
      storeId.value = Get.parameters['storeId']!;
      loadStoreDetails();
    }
  }
  
  void loadStoreDetails() {
    // TODO: Implement API call to load store details
    // For now, using mock data
  }
  
  void showStoreInfoBottomSheet() {
    isBottomSheetVisible.value = true;
  }
  
  void hideStoreInfoBottomSheet() {
    isBottomSheetVisible.value = false;
  }
  
  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    // TODO: Implement API call to update notification settings
  }
  
  void toggleProductFavorite(int productId) {
    final productIndex = storeProducts.indexWhere((product) => product['id'] == productId);
    if (productIndex != -1) {
      storeProducts[productIndex]['isFavorite'] = !storeProducts[productIndex]['isFavorite'];
      storeProducts.refresh();
    }
  }
  
  void navigateToProduct(int productId) {
    Get.toNamed('/product-details', parameters: {'productId': productId.toString()});
  }
  
  void callStore() {
    // TODO: Implement phone call functionality
    print('Calling store: ${contactInfo['phone']}');
  }
  
  void emailStore() {
    // TODO: Implement email functionality
    print('Emailing store: ${contactInfo['email']}');
  }
  
  void openWhatsApp() {
    // TODO: Implement WhatsApp functionality
    print('Opening WhatsApp: ${contactInfo['whatsapp']}');
  }
  
  void openFacebook() {
    // TODO: Implement Facebook functionality
    print('Opening Facebook: ${contactInfo['facebook']}');
  }
  
  void openLocation(Map<String, dynamic> location) {
    // TODO: Implement map navigation functionality
    print('Opening location: ${location['address']}');
  }
  
  void sendMessage() {
    // TODO: Implement messaging functionality
    print('Sending message to store');
  }
}
