import 'package:get/get.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';
import 'package:mrsheaf/features/categories/services/kitchen_service.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/services/toast_service.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/features/favorites/utils/favorites_helper.dart';
import 'package:mrsheaf/features/chat/services/chat_service.dart';

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
  final RxBool isAddingToCart = false.obs; // حماية من الضغط المتكرر
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

  // Favorite status
  final RxBool isFavorite = false.obs;
  
  @override
  void onInit() {
    super.onInit();

    // Set loading to true initially
    isLoading.value = true;

    // Get restaurant data from arguments
    final arguments = Get.arguments;
    if (arguments != null) {
      if (arguments['restaurantId'] != null) {
        storeId.value = arguments['restaurantId'].toString();
      }

      if (arguments['restaurant'] != null) {
        final KitchenModel restaurantData = arguments['restaurant'];
        _setRestaurantData(restaurantData);
        // Stop loading after setting data from arguments
        isLoading.value = false;
      } else if (arguments['restaurantData'] != null) {
        // Handle raw restaurant data from home screen
        final Map<String, dynamic> rawData = arguments['restaurantData'];
        _setRawRestaurantData(rawData);
        // Stop loading after setting data from arguments
        isLoading.value = false;
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
    
    // If no store ID, stop loading
    if (storeId.value.isEmpty) {
      isLoading.value = false;
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

    // Set logo and cover image from restaurant data
    if (restaurantData.logo != null && restaurantData.logo!.isNotEmpty) {
      storeProfileImage.value = _getImageUrl(restaurantData.logo!);
      if (kDebugMode) {
        print('🖼️ Set store logo: ${storeProfileImage.value}');
      }
    }
    if (restaurantData.coverImage != null && restaurantData.coverImage!.isNotEmpty) {
      storeImage.value = _getImageUrl(restaurantData.coverImage!);
      if (kDebugMode) {
        print('🖼️ Set store cover: ${storeImage.value}');
      }
    }

    // Products will be loaded separately
  }

  /// Helper to get full image URL from path
  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return 'https://mr-shife-backend-main-ygodva.laravel.cloud/storage/$imagePath';
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
    
    // Parse numeric values (handles both String and num from API)
    final deliveryFeeValue = rawData['delivery_fee'];
    deliveryFee.value = deliveryFeeValue is num 
        ? deliveryFeeValue.toDouble() 
        : double.tryParse(deliveryFeeValue?.toString() ?? '0') ?? 0.0;
    
    final minimumOrderValue = rawData['minimum_order'];
    minimumOrder.value = minimumOrderValue is num 
        ? minimumOrderValue.toDouble() 
        : double.tryParse(minimumOrderValue?.toString() ?? '0') ?? 0.0;
    
    preparationTime.value = int.tryParse(rawData['preparation_time']?.toString() ?? '30') ?? 30;

    // Parse address
    String address = '';
    if (rawData['address'] != null) {
      final addr = rawData['address'];
      if (addr is Map) {
        final currentLang = Get.locale?.languageCode ?? 'ar';
        address = addr[currentLang]?.toString() ??
                 addr['ar']?.toString() ??
                 addr['en']?.toString() ??
                 '';
      } else if (addr is String) {
        address = addr;
      }
    }
    storeLocation.value = address;

    // Set images
    if (rawData['cover_image'] != null && rawData['cover_image'].toString() != 'null') {
      String coverImage = rawData['cover_image'].toString();
      if (!coverImage.startsWith('http')) {
        coverImage = 'https://mr-shife-backend-main-ygodva.laravel.cloud/storage/$coverImage';
      }
      storeImage.value = coverImage;
      if (kDebugMode) {
        print('🖼️ RAW: Set store cover: $coverImage');
      }
    }
    if (rawData['logo'] != null && rawData['logo'].toString() != 'null') {
      storeProfileImage.value = _getLogoUrl(rawData['logo'].toString());
      if (kDebugMode) {
        print('🖼️ RAW: Set store logo: ${storeProfileImage.value}');
      }
    }

    // Update contact info
    contactInfo.value = {
      'phone': rawData['phone']?.toString() ?? '',
      'email': rawData['email']?.toString() ?? '',
      'whatsapp': rawData['phone']?.toString() ?? '',
      'facebook': '', // Not available in API
    };

    // Update working hours from API
    if (rawData['business_hours'] != null && rawData['business_hours'] is Map) {
      _updateWorkingHours(Map<String, dynamic>.from(rawData['business_hours']));
    }

    // Update location from API
    if (rawData['latitude'] != null && rawData['longitude'] != null) {
      locations.value = [
        {
          'address': address,
          'latitude': rawData['latitude'],
          'longitude': rawData['longitude'],
          'city': rawData['city']?.toString() ?? '',
          'area': rawData['area']?.toString() ?? '',
        }
      ];
    }

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
          final isOpen = dayData['is_open'] ?? false;
          final openTime = dayData['open']?.toString() ?? '';
          final closeTime = dayData['close']?.toString() ?? '';

          // Format times to 12-hour format with AM/PM
          final formattedOpenTime = isOpen && openTime.isNotEmpty
              ? _formatTimeTo12Hour(openTime)
              : '';
          final formattedCloseTime = isOpen && closeTime.isNotEmpty
              ? _formatTimeTo12Hour(closeTime)
              : '';

          updatedHours.add({
            'day': displayDay,
            'startTime': formattedOpenTime,
            'endTime': formattedCloseTime,
            'isOff': !isOpen || openTime.isEmpty,
          });
        }
      } else {
        // If day not found in API, mark as OFF
        updatedHours.add({
          'day': displayDay,
          'startTime': '',
          'endTime': '',
          'isOff': true,
        });
      }
    });

    if (updatedHours.isNotEmpty) {
      workingHours.value = updatedHours;

      if (kDebugMode) {
        print('📅 STORE DETAILS: Working hours updated from API');
        for (var day in updatedHours) {
          print('   ${day['day']}: ${day['isOff'] ? 'OFF' : '${day['startTime']} - ${day['endTime']}'}');
        }
      }
    }
  }

  /// Convert 24-hour time format (HH:mm) to 12-hour format (hh:mm AM/PM)
  String _formatTimeTo12Hour(String time24) {
    try {
      // Parse time string (expected format: "09:00" or "09:00:00")
      final parts = time24.split(':');
      if (parts.isEmpty) return time24;

      final hour24 = int.tryParse(parts[0]) ?? 0;
      final minute = parts.length > 1 ? parts[1] : '00';

      // Convert to 12-hour format
      final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
      final period = hour24 < 12 ? 'AM' : 'PM';

      return '$hour12:$minute $period';
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error formatting time: $time24 - $e');
      }
      return time24; // Return original if parsing fails
    }
  }

  /// Load location from API
  Future<void> loadLocation() async {
    if (storeId.value.isEmpty) {
      if (kDebugMode) {
        print('⚠️ STORE DETAILS: Cannot load location - store ID is empty');
      }
      return;
    }

    try {
      isLoading.value = true;

      if (kDebugMode) {
        print('📍 STORE DETAILS: Loading location for store ${storeId.value}...');
      }

      final response = await ApiClient.instance.get(
        ApiConstants.kitchenLocation(int.parse(storeId.value)),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        if (kDebugMode) {
          print('✅ STORE DETAILS: Location loaded successfully');
          print('   Latitude: ${data['latitude']} (${data['latitude'].runtimeType})');
          print('   Longitude: ${data['longitude']} (${data['longitude'].runtimeType})');
          print('   Address: ${data['address']}');
        }

        // Parse latitude and longitude safely (handle both String and double)
        double? latitude;
        double? longitude;

        if (data['latitude'] != null) {
          if (data['latitude'] is double) {
            latitude = data['latitude'];
          } else if (data['latitude'] is String) {
            latitude = double.tryParse(data['latitude']);
          } else if (data['latitude'] is int) {
            latitude = (data['latitude'] as int).toDouble();
          }
        }

        if (data['longitude'] != null) {
          if (data['longitude'] is double) {
            longitude = data['longitude'];
          } else if (data['longitude'] is String) {
            longitude = double.tryParse(data['longitude']);
          } else if (data['longitude'] is int) {
            longitude = (data['longitude'] as int).toDouble();
          }
        }

        // Update locations list
        locations.value = [
          {
            'address': data['address'] ?? '',
            'latitude': latitude,
            'longitude': longitude,
            'city': data['city'] ?? '',
            'area': data['area'] ?? '',
            'building': data['building'] ?? '',
            'floor': data['floor'] ?? '',
            'postal_code': data['postal_code'] ?? '',
            'location_notes': data['location_notes'] ?? '',
          }
        ];

        if (kDebugMode) {
          print('   Parsed Latitude: $latitude');
          print('   Parsed Longitude: $longitude');
        }
      } else {
        if (kDebugMode) {
          print('❌ STORE DETAILS: Failed to load location - ${response.data['message']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ STORE DETAILS: Error loading location - $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Load working hours from dedicated API endpoint
  Future<void> loadWorkingHours() async {
    if (storeId.value.isEmpty) return;

    try {
      if (kDebugMode) {
        print('🕐 STORE DETAILS: Loading working hours for restaurant ${storeId.value}');
      }

      final response = await ApiClient.instance.get(
        ApiConstants.kitchenWorkingHours(int.parse(storeId.value))
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final businessHours = data['business_hours'];

        if (businessHours != null && businessHours is Map) {
          _updateWorkingHours(Map<String, dynamic>.from(businessHours));

          if (kDebugMode) {
            print('✅ STORE DETAILS: Working hours loaded successfully');
            print('   Is open now: ${data['is_open_now']}');
          }
        }
      } else {
        if (kDebugMode) {
          print('⚠️ STORE DETAILS: Failed to load working hours - ${response.data['message']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ STORE DETAILS: Error loading working hours: $e');
      }
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
      ToastService.showError('failed_to_load_store_details'.tr);
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

        // Update working hours if available
        if (storeData['business_hours'] != null && storeData['business_hours'] is Map) {
          _updateWorkingHours(Map<String, dynamic>.from(storeData['business_hours']));
        }

        // Update location if available
        if (storeData['latitude'] != null && storeData['longitude'] != null) {
          String address = '';
          if (storeData['address'] != null) {
            final addr = storeData['address'];
            if (addr is Map) {
              final currentLang = Get.locale?.languageCode ?? 'ar';
              address = addr[currentLang]?.toString() ??
                       addr['ar']?.toString() ??
                       addr['en']?.toString() ??
                       '';
            } else if (addr is String) {
              address = addr;
            }
          }

          locations.value = [
            {
              'address': address,
              'latitude': storeData['latitude'],
              'longitude': storeData['longitude'],
              'city': storeData['city']?.toString() ?? '',
              'area': storeData['area']?.toString() ?? '',
            }
          ];

          if (kDebugMode) {
            print('📍 STORE DETAILS: Location updated - $address');
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
      if (isFavorite.value) {
        ToastService.showSuccess('added_to_favorites'.tr);
      } else {
        ToastService.showInfo('removed_from_favorites'.tr);
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ STORE DETAILS: Error toggling favorite: $e');
      }

      ToastService.showError('failed_to_update_favorites'.tr);
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
  
  /// Navigate to chat with the restaurant
  Future<void> sendMessage() async {
    try {
      // Get restaurant ID
      final restaurantId = int.tryParse(storeId.value);
      if (restaurantId == null || restaurantId == 0) {
        ToastService.showError('cannot_open_chat'.tr);
        return;
      }

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Get or create conversation with the restaurant
      final chatService = ChatService();
      final conversation = await chatService.getOrCreateRestaurantConversation(restaurantId);

      // Close loading dialog
      Get.back();

      // Navigate to chat screen
      Get.toNamed(
        '/chat',
        arguments: {
          'conversationId': conversation.id,
          'conversation_id': conversation.id, // Also pass snake_case for compatibility
          'conversation': conversation, // Pass the conversation object
        },
      );
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (kDebugMode) {
        print('Error opening chat: $e');
      }

      ToastService.showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Add product to cart with minimum required options (handled by backend)
  Future<void> addToCart(int productId) async {
    // حماية من الضغط المتكرر
    if (isAddingToCart.value) {
      ToastService.showWarning('adding_to_cart'.tr);
      return;
    }

    try {
      isAddingToCart.value = true;
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
      ToastService.showError('failed_to_add_to_cart'.tr);

      if (kDebugMode) {
        print('❌ ADD TO CART ERROR: $e');
      }
    } finally {
      isAddingToCart.value = false;
    }
  }
}
