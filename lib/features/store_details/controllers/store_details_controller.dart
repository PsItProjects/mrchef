import 'package:get/get.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';
import 'package:mrsheaf/features/categories/services/kitchen_service.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/features/favorites/utils/favorites_helper.dart';

class StoreDetailsController extends GetxController {
  final KitchenService _kitchenService = KitchenService();

  // Store information
  final RxString storeId = ''.obs;
  final RxString storeName = ''.obs;
  final RxString storeLocation = ''.obs;
  final RxString storeDescription = ''.obs;
  final RxDouble storeRating = 0.0.obs;
  final RxString storeImage = ''.obs;
  final RxString storeProfileImage = ''.obs;
  final RxString businessName = ''.obs;
  final RxString phone = ''.obs;
  final RxString email = ''.obs;
  final RxDouble deliveryFee = 0.0.obs;
  final RxDouble minimumOrder = 0.0.obs;
  final RxInt preparationTime = 0.obs;
  final RxInt reviewsCount = 0.obs;
  final RxInt totalProducts = 0.obs;
  final RxBool isLoading = false.obs;
  final Rx<KitchenModel?> restaurant = Rx<KitchenModel?>(null);
  
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
  
  // Location data from backend
  final RxList<Map<String, dynamic>> locations = <Map<String, dynamic>>[].obs;
  
  // Contact information from backend
  final RxMap<String, dynamic> contactInfo = <String, dynamic>{}.obs;
  
  // Store products from backend
  final RxList<Map<String, dynamic>> storeProducts = <Map<String, dynamic>>[].obs;
  
  // Notification settings
  final RxBool notificationsEnabled = false.obs;

  // Favorite status
  final RxBool isFavorite = false.obs;
  
  @override
  void onInit() {
    super.onInit();

    // Get restaurant data from arguments
    final arguments = Get.arguments;
    if (arguments != null) {
      if (arguments['restaurantId'] != null) {
        storeId.value = arguments['restaurantId'].toString();
      }

      if (arguments['restaurant'] != null) {
        final KitchenModel restaurantData = arguments['restaurant'];
        _setRestaurantData(restaurantData);
      } else if (arguments['restaurantData'] != null) {
        // Handle raw restaurant data from home screen
        final Map<String, dynamic> rawData = arguments['restaurantData'];
        _setRawRestaurantData(rawData);
      }
    }

    // If we have an ID but no data, load from API
    if (storeId.value.isNotEmpty && restaurant.value == null) {
      loadStoreDetails();
    }

    // Load products if we have a store ID
    if (storeId.value.isNotEmpty) {
      loadStoreProducts();
    }
  }

  void _setRestaurantData(KitchenModel restaurantData) {
    restaurant.value = restaurantData;
    storeName.value = restaurantData.displayName;
    businessName.value = restaurantData.businessName;
    storeDescription.value = restaurantData.displayDescription;
    storeLocation.value = restaurantData.displayAddress;
    storeRating.value = restaurantData.averageRating;
    phone.value = restaurantData.phone;
    email.value = restaurantData.email;
    deliveryFee.value = restaurantData.deliveryFee;
    minimumOrder.value = restaurantData.minimumOrder;
    preparationTime.value = restaurantData.preparationTime;
    reviewsCount.value = restaurantData.reviewsCount;
    totalProducts.value = restaurantData.totalProducts;

    // Products will be loaded separately
  }

  void _setRawRestaurantData(Map<String, dynamic> rawData) {
    // Parse restaurant name based on language
    String restaurantName = 'Restaurant';
    if (rawData['name'] != null) {
      final name = rawData['name'];
      if (name is Map) {
        // Get current language from controller or use Arabic as default
        final currentLang = Get.locale?.languageCode ?? 'ar';
        restaurantName = name[currentLang]?.toString() ??
                       name['ar']?.toString() ??
                       name['en']?.toString() ??
                       'Restaurant';
      } else if (name is String) {
        restaurantName = name;
      }
    } else if (rawData['business_name'] != null) {
      final businessName = rawData['business_name'];
      if (businessName is Map) {
        final currentLang = Get.locale?.languageCode ?? 'ar';
        restaurantName = businessName[currentLang]?.toString() ??
                       businessName['ar']?.toString() ??
                       businessName['en']?.toString() ??
                       'Restaurant';
      } else if (businessName is String) {
        restaurantName = businessName;
      }
    }

    // Parse description
    String description = '';
    if (rawData['description'] != null) {
      final desc = rawData['description'];
      if (desc is Map && desc['current'] != null) {
        description = desc['current'].toString();
      } else if (desc is String) {
        description = desc;
      }
    }

    // Set basic data
    storeId.value = rawData['id']?.toString() ?? '';
    storeName.value = restaurantName;
    businessName.value = restaurantName;
    storeDescription.value = description;
    storeRating.value = (rawData['average_rating'] ?? 4.5).toDouble();
    phone.value = rawData['phone']?.toString() ?? '';
    email.value = rawData['email']?.toString() ?? '';
    deliveryFee.value = (rawData['delivery_fee'] ?? 0).toDouble();
    minimumOrder.value = (rawData['minimum_order'] ?? 0).toDouble();
    preparationTime.value = int.tryParse(rawData['preparation_time']?.toString() ?? '30') ?? 30;

    // Parse address
    String address = '';
    if (rawData['address'] != null) {
      final addr = rawData['address'];
      if (addr is Map && addr['current'] != null) {
        address = addr['current'].toString();
      } else if (addr is String) {
        address = addr;
      }
    }
    storeLocation.value = address;

    // Set images
    if (rawData['cover_image'] != null) {
      String coverImage = rawData['cover_image'].toString();
      if (!coverImage.startsWith('http') && coverImage != 'null') {
        coverImage = 'https://mr-shife-backend-main-ygodva.laravel.cloud/storage/$coverImage';
      }
      storeImage.value = coverImage;
    }
    if (rawData['logo'] != null) {
      storeProfileImage.value = _getLogoUrl(rawData['logo'].toString());
    }

    // Update contact info
    contactInfo.value = {
      'phone': rawData['phone']?.toString() ?? '',
      'email': rawData['email']?.toString() ?? '',
      'whatsapp': rawData['phone']?.toString() ?? '',
      'facebook': '', // Not available in API
    };

    // Products will be loaded separately
  }

  void _updateStoreProducts(List<Map<String, dynamic>> apiProducts) {
    final List<Map<String, dynamic>> updatedProducts = [];

    for (var product in apiProducts) {
      updatedProducts.add({
        'id': product['id'],
        'name': getTranslatedText(product['name']),
        'price': double.tryParse(product['base_price']?.toString() ?? '0') ?? 0.0,
        'image': _getProductImage(product),
        'isFavorite': false,
        'restaurant_id': product['restaurant_id'],
        'base_price': product['base_price'],
        'original_name': product['name'], // Keep original for API calls
      });
    }

    storeProducts.value = updatedProducts;

    if (kDebugMode) {
      print('📦 Store products updated: ${updatedProducts.length} products');
      for (var product in updatedProducts.take(3)) {
        print('   - ${product['name']} - ${product['price']} ر.س');
      }
    }
  }

  String getTranslatedText(dynamic field) {
    if (field is Map<String, dynamic>) {
      try {
        // Try to get current language from LanguageService
        final languageService = Get.find<LanguageService>();
        final currentLang = languageService.currentLanguage;
        return field[currentLang] ?? field['ar'] ?? field['en'] ?? '';
      } catch (e) {
        // Fallback if LanguageService is not available
        return field['ar'] ?? field['en'] ?? '';
      }
    }
    return field?.toString() ?? '';
  }

  void _updateWorkingHours(Map<String, dynamic> businessHours) {
    final List<Map<String, dynamic>> updatedHours = [];

    final dayMapping = {
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
    };

    dayMapping.forEach((apiDay, displayDay) {
      if (businessHours.containsKey(apiDay)) {
        final dayData = businessHours[apiDay];
        if (dayData is Map<String, dynamic>) {
          updatedHours.add({
            'day': displayDay,
            'startTime': dayData['open'] ?? '',
            'endTime': dayData['close'] ?? '',
            'isOff': dayData['open'] == null || dayData['open'] == '',
          });
        }
      }
    });

    if (updatedHours.isNotEmpty) {
      workingHours.value = updatedHours;
    }
  }

  Future<void> loadStoreDetails() async {
    if (storeId.value.isEmpty) return;

    try {
      isLoading.value = true;
      final restaurantData = await _kitchenService.getKitchenById(int.parse(storeId.value));
      _setRestaurantData(restaurantData);

      // Check favorite status
      await _checkFavoriteStatus();

      // Products are loaded separately in onInit
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading restaurant details: $e');
      }
      Get.snackbar(
        'خطأ',
        'فشل في تحميل تفاصيل المطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStoreProducts() async {
    if (storeId.value.isEmpty) return;

    try {
      if (kDebugMode) {
        print('🏪 STORE DETAILS: Loading products for restaurant ${storeId.value}');
      }

      // Use the kitchen details endpoint to get store and products data
      final response = await ApiClient.instance.get('/customer/shopping/kitchens/${storeId.value}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final storeData = response.data['data'];
        final List<dynamic> productsData = storeData['products'] ?? [];

        if (kDebugMode) {
          print('📦 RAW PRODUCTS DATA: ${productsData.length} products found');
          if (productsData.isNotEmpty) {
            print('📸 FIRST PRODUCT: ${productsData[0]['name']} - Image: ${productsData[0]['primary_image']}');
          }
        }

        // Convert products to the format expected by ProductCard using real data from API
        final List<Map<String, dynamic>> convertedProducts = productsData.map((product) {
          return {
            'id': product['id'],
            'name': _getTranslatedName(product['name']),
            'description': _getTranslatedName(product['description']),
            'price': double.tryParse((product['base_price'] ?? 0).toString()) ?? 0.0,
            'originalPrice': null,
            'primary_image': product['primary_image'] ?? '',
            'images': product['images'] ?? [],
            'rating': product['average_rating'] != null
                ? double.tryParse(product['average_rating'].toString()) ?? 4.5
                : 4.5,
            'reviewCount': 0,
            'productCode': product['sku'] ?? 'PRD-${product['id']}',
            'isFavorite': false,
          };
        }).toList();

        storeProducts.value = convertedProducts;

        if (kDebugMode) {
          print('✅ STORE DETAILS: Products loaded successfully');
          print('📦 PRODUCTS COUNT: ${storeProducts.length}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ STORE DETAILS ERROR: Failed to load products: $e');
      }
    }
  }

  String _getTranslatedName(dynamic nameData) {
    if (nameData == null) return '';

    if (nameData is Map) {
      // Get current language from LanguageService
      try {
        final languageService = Get.find<LanguageService>();
        final currentLang = languageService.currentLanguage;

        // Try current language first, then fallback to available languages
        return nameData[currentLang]?.toString() ??
               nameData['ar']?.toString() ??
               nameData['en']?.toString() ??
               '';
      } catch (e) {
        // Fallback if LanguageService is not available
        return nameData['ar']?.toString() ??
               nameData['en']?.toString() ??
               '';
      }
    }

    return nameData.toString();
  }

  String _getLogoUrl(String? logoPath) {
    if (logoPath == null || logoPath.isEmpty) {
      return 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=100&h=100&fit=crop';
    }

    if (logoPath.startsWith('http')) {
      return logoPath;
    }

    // Use the main domain URL for logos
    return 'https://mr-shife-backend-main-ygodva.laravel.cloud/storage/$logoPath';
  }



  String _getProductImage(Map<String, dynamic> product) {
    // Generate different default images based on product ID
    final List<String> defaultImages = [
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop', // Pizza
      'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400&h=300&fit=crop', // Burger
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=300&fit=crop', // Pasta
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop', // Food
      'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400&h=300&fit=crop', // Salad
      'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&h=300&fit=crop', // Sandwich
    ];

    final productId = product['id'] ?? 0;
    final defaultImage = defaultImages[productId % defaultImages.length];

    // Get product image from API or use default
    if (product['primary_image'] != null && product['primary_image'].toString().isNotEmpty) {
      String productImage = product['primary_image'].toString();
      if (!productImage.startsWith('http')) {
        productImage = 'https://mr-shife-backend-main-ygodva.laravel.cloud/storage/$productImage';
      }
      return productImage;
    }

    return defaultImage;
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
  
  /// Check favorite status from server
  Future<void> _checkFavoriteStatus() async {
    try {
      final merchantId = int.tryParse(storeId.value);
      if (merchantId == null) return;

      // Ensure favorites controller is initialized
      FavoritesHelper.ensureInitialized();

      // Check if merchant is favorited from server
      final isFavorited = await FavoritesHelper.checkMerchantFavoriteFromServer(merchantId);
      isFavorite.value = isFavorited;

      if (kDebugMode) {
        print('🤍 STORE DETAILS: Favorite status checked from server - Merchant $merchantId is ${isFavorited ? 'favorited' : 'not favorited'}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ STORE DETAILS: Error checking favorite status: $e');
      }
      // Default to false on error
      isFavorite.value = false;
    }
  }

  /// Toggle store favorite status
  Future<void> toggleFavorite() async {
    try {
      if (kDebugMode) {
        print('🤍 STORE DETAILS: Toggling favorite for merchant ${storeId.value}');
      }

      final merchantId = int.tryParse(storeId.value);
      if (merchantId == null) {
        if (kDebugMode) {
          print('❌ STORE DETAILS: Merchant ID is null, cannot toggle favorite');
        }
        return;
      }

      // Ensure favorites controller is initialized
      FavoritesHelper.ensureInitialized();

      // Toggle favorite using the helper
      await FavoritesHelper.toggleMerchantFavorite(merchantId);

      // Check the new state from server to ensure consistency
      final newFavoriteState = await FavoritesHelper.checkMerchantFavoriteFromServer(merchantId);
      isFavorite.value = newFavoriteState;

      if (kDebugMode) {
        print('✅ STORE DETAILS: Favorite toggled successfully. New state: ${isFavorite.value}');
      }

      // Show success message
      Get.snackbar(
        isFavorite.value ? 'تمت الإضافة' : 'تمت الإزالة',
        isFavorite.value ? 'تم إضافة المطعم إلى المفضلة' : 'تم إزالة المطعم من المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isFavorite.value ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ STORE DETAILS: Error toggling favorite: $e');
      }

      Get.snackbar(
        'خطأ',
        'فشل في تحديث المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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

  /// Add product to cart with minimum required options (handled by backend)
  Future<void> addToCart(int productId) async {
    try {
      // Create a minimal ProductModel for the cart controller
      final product = ProductModel(
        id: productId,
        name: 'Product $productId',
        description: '',
        price: 0.0,
        image: '',
        rating: 0.0,
        reviewCount: 0,
        productCode: '',
        sizes: [],
        rawSizes: [],
        additionalOptions: [],
        images: [],
      );

      final cartController = Get.find<CartController>();

      // Use existing addToCart method with empty options
      // Backend will automatically select minimum required options
      await cartController.addToCart(
        product: product,
        size: '', // Empty - backend will choose minimum
        quantity: 1,
        additionalOptions: [], // Empty - backend will choose minimum required
      );

    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة المنتج إلى السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      if (kDebugMode) {
        print('❌ ADD TO CART ERROR: $e');
      }
    }
  }
}
