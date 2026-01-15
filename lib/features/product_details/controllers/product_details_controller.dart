import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/features/product_details/models/review_model.dart';
import 'package:mrsheaf/features/product_details/widgets/reviews_bottom_sheet.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/favorites/utils/favorites_helper.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/features/product_details/services/product_details_service.dart';

import '../../../core/routes/app_routes.dart';

class ProductDetailsController extends GetxController {
  // Services
  final ProductDetailsService _productDetailsService = ProductDetailsService();

  // Observable variables
  final RxInt quantity = 1.obs;
  final RxString selectedSize = ''.obs;
  final RxInt selectedSizeId = 0.obs;
  final RxList<Map<String, dynamic>> rawSizes = <Map<String, dynamic>>[].obs;
  final RxBool isFavorite = false.obs;
  final RxInt currentImageIndex = 0.obs;
  final RxList<AdditionalOption> additionalOptions = <AdditionalOption>[].obs;
  final RxString comment = ''.obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  // Price calculation
  final RxDouble calculatedTotalPrice = 0.0.obs;
  final RxBool isCalculatingPrice = false.obs;
  final RxMap<String, dynamic> priceBreakdown = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> selectedSizeDetail = <String, dynamic>{}.obs;

  // Loading states
  final RxBool isLoadingProduct = true.obs;
  final RxBool isLoadingReviews = false.obs;
  final RxBool isAddingReview = false.obs;

  // Product data
  final Rx<ProductModel?> product = Rx<ProductModel?>(null);

  // Product ID (passed from navigation)
  late int productId;
  
  @override
  void onInit() {
    super.onInit();
    // Get product ID from arguments
    final receivedId = Get.arguments?['productId'];
    
    if (receivedId == null) {
      Get.snackbar(
        'خطأ',
        'معرف المنتج غير صحيح. يرجى المحاولة مرة أخرى.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      Future.delayed(const Duration(seconds: 2), () => Get.back());
      return;
    }
    
    productId = receivedId;
    _loadProductDetails();
    _setupLanguageListener();
  }

  /// Setup language change listener
  void _setupLanguageListener() {
    final languageService = LanguageService.instance;
    // Listen to language changes and reload product details
    ever(languageService.currentLanguageRx, (String language) {
      print('🌐 PRODUCT DETAILS: Language changed to $language, reloading product...');
      _loadProductDetails();
    });
  }
  
  /// Load product details from API
  Future<void> _loadProductDetails() async {
    try {
      isLoadingProduct.value = true;

      if (kDebugMode) {
        print('🔍 PRODUCT DETAILS: Loading product with ID: $productId');
      }

      final productData = await _productDetailsService.getProductDetails(productId);
      product.value = productData;

      // Get raw sizes data from service
      rawSizes.value = _productDetailsService.rawSizes;



      // Initialize reactive variables from rawSizes if available
      if (rawSizes.isNotEmpty) {
        final firstSizeObj = rawSizes.first;
        final displayName = LanguageService.instance.getLocalizedText(firstSizeObj['name']);
        selectedSize.value = displayName;
        selectedSizeId.value = firstSizeObj['id'] ?? 0;
      } else if (productData.sizes.isNotEmpty) {
        final firstSize = productData.sizes.first;
        selectedSize.value = firstSize;
        selectedSizeId.value = _extractSizeId(firstSize);
      }
      additionalOptions.value = productData.additionalOptions;

      if (kDebugMode) {
        print('📏 SIZES: ${productData.sizes}');
        print('🔧 ADDITIONAL OPTIONS: ${productData.additionalOptions.length}');

        // Group options by group name for debugging
        Map<String, List<dynamic>> groupedOptions = {};
        for (var option in productData.additionalOptions) {
          String groupKey = option.groupName ?? 'other';
          if (!groupedOptions.containsKey(groupKey)) {
            groupedOptions[groupKey] = [];
          }
          groupedOptions[groupKey]!.add(option);
        }

        groupedOptions.forEach((groupName, options) {
          print('📦 GROUP: $groupName (${options.length} options)');
          for (var option in options) {
            print('   - ${option.name}: ${option.price} ر.س (Required: ${option.isRequired})');
          }
        });
      }

      // Check favorite status
      await _checkFavoriteStatus();

      // Load reviews
      await _loadProductReviews();

      // Calculate initial price
      await _calculatePrice();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load product details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProduct.value = false;
    }
  }

  /// Check favorite status from server
  Future<void> _checkFavoriteStatus() async {
    try {
      final productId = product.value?.id;
      if (productId == null) return;

      // Ensure favorites controller is initialized
      FavoritesHelper.ensureInitialized();

      // Check if product is favorited from server
      final isFavorited = await FavoritesHelper.checkProductFavoriteFromServer(productId);
      isFavorite.value = isFavorited;

      if (kDebugMode) {
        print('🤍 PRODUCT DETAILS: Favorite status checked from server - Product $productId is ${isFavorited ? 'favorited' : 'not favorited'}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ PRODUCT DETAILS: Error checking favorite status: $e');
      }
      // Default to false on error
      isFavorite.value = false;
    }
  }

  /// Load product reviews from API
  Future<void> _loadProductReviews() async {
    try {
      isLoadingReviews.value = true;

      final reviewsData = await _productDetailsService.getProductReviews(productId);
      reviews.value = reviewsData;

    } catch (e) {
      print('Failed to load reviews: $e');
      // Keep empty reviews list on error
      reviews.value = [];
    } finally {
      isLoadingReviews.value = false;
    }
  }
  
  // Methods
  void increaseQuantity() {
    quantity.value++;
    _calculatePrice(); // Recalculate price when quantity changes
  }

  void decreaseQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
      _calculatePrice(); // Recalculate price when quantity changes
    }
  }
  
  void selectSize(String size) {
    selectedSize.value = size;
    selectedSizeId.value = _extractSizeId(size);
    _calculatePrice(); // Recalculate price when size changes
  }

  /// Extract size ID from size string or object
  int _extractSizeId(dynamic size) {
    if (size is Map && size.containsKey('id')) {
      return size['id'] as int;
    }

    final targetName = size is String ? size : size.toString();
    final languageService = LanguageService.instance;

    // Match against localized names in rawSizes
    for (var sizeObj in rawSizes) {
      final localized = languageService.getLocalizedText(sizeObj['name']);
      if (localized == targetName) {
        return (sizeObj['id'] as int?) ?? 0;
      }
    }

    return 0;
  }
  
  Future<void> toggleFavorite() async {
    try {
      if (kDebugMode) {
        print('🤍 PRODUCT DETAILS: Toggling favorite for product ${product.value?.id}');
      }

      final productId = product.value?.id;
      if (productId == null) {
        if (kDebugMode) {
          print('❌ PRODUCT DETAILS: Product ID is null, cannot toggle favorite');
        }
        return;
      }

      // Ensure favorites controller is initialized
      FavoritesHelper.ensureInitialized();

      // Toggle favorite using the helper and get the new state
      final newFavoriteState = await FavoritesHelper.toggleProductFavorite(productId);

      // Update local state to reflect the change
      isFavorite.value = newFavoriteState;

      if (kDebugMode) {
        print('✅ PRODUCT DETAILS: Favorite toggled successfully. New state: ${isFavorite.value}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ PRODUCT DETAILS: Error toggling favorite: $e');
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
  
  void changeImage(int index) {
    currentImageIndex.value = index;
  }
  
  void toggleAdditionalOption(int optionId) {
    final index = additionalOptions.indexWhere((option) => option.id == optionId);
    if (index != -1) {
      additionalOptions[index] = additionalOptions[index].copyWith(
        isSelected: !additionalOptions[index].isSelected,
      );
      additionalOptions.refresh();

      // Recalculate price when options change
      _calculatePrice();
    }
  }

  /// Calculate total price with selected options using API
  Future<void> _calculatePrice() async {
    if (product.value == null) return;

    try {
      isCalculatingPrice.value = true;

      final selectedOptionIds = additionalOptions
          .where((option) => option.isSelected)
          .map((option) => option.id)
          .toList();

      // Add selected size ID if available
      if (selectedSizeId.value > 0) {
        selectedOptionIds.add(selectedSizeId.value);
      }

      final priceData = await _productDetailsService.calculateProductPrice(
        product.value!.id,
        quantity: quantity.value,
        selectedOptionIds: selectedOptionIds.isNotEmpty ? selectedOptionIds : null,
      );

      calculatedTotalPrice.value = priceData['total_price']?.toDouble() ?? 0.0;
      priceBreakdown.value = priceData['price_breakdown'] ?? {};
      if (priceData['selected_size'] != null) {
        selectedSizeDetail.value = Map<String, dynamic>.from(priceData['selected_size']);
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ PRICE CALCULATION ERROR: $e');
      }
      // Fallback to local calculation
      calculatedTotalPrice.value = totalPrice;
    } finally {
      isCalculatingPrice.value = false;
    }
  }
  
  /// Add product to cart via server
  Future<void> addToCart() async {
    if (product.value == null) return;

    try {
      final cartController = Get.find<CartController>();

      await cartController.addToCart(
        product: product.value!,
        size: selectedSize.value,
        quantity: quantity.value,
        additionalOptions: additionalOptions.where((option) => option.isSelected).toList(),
        specialInstructions: comment.value.isNotEmpty ? comment.value : null,
      );

      // Success message is handled in CartController

      if (kDebugMode) {
        print('✅ ADDED TO CART: ${product.value!.name}');
        print('   - Size: ${selectedSize.value}');
        print('   - Quantity: ${quantity.value}');
        print('   - Total Price: ${totalPrice.toStringAsFixed(2)} ر.س');
        final selectedOptions = additionalOptions.where((option) => option.isSelected).toList();
        if (selectedOptions.isNotEmpty) {
          print('   - Additional Options:');
          for (var option in selectedOptions) {
            print('     * ${option.name}: ${option.price?.toStringAsFixed(1)} ر.س');
          }
        }
        if (comment.value.isNotEmpty) {
          print('   - Special Instructions: ${comment.value}');
        }
      }

    } catch (e) {
      // Error handling is done in CartController
      if (kDebugMode) {
        print('❌ ADD TO CART ERROR: $e');
      }
    }
  }
  
  void messageStore() {
    Get.snackbar(
      'Message Store',
      'Opening chat with store...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void shareWithFriend() {
    Get.snackbar(
      'Share',
      'Sharing ${product.value?.name ?? 'product'} with friend...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void goBack() {
    Get.back();
  }

  void goToStore() {
    // Get restaurant ID from product
    final restaurantId = product.value?.restaurantId;

    if (restaurantId != null) {
      if (kDebugMode) {
        print('🏪 PRODUCT DETAILS: Navigating to restaurant ID: $restaurantId');
      }

      Get.toNamed(
        AppRoutes.STORE_DETAILS,
        arguments: {
          'restaurantId': restaurantId.toString(),
        },
      );
    } else {
      if (kDebugMode) {
        print('❌ PRODUCT DETAILS: Restaurant ID not found in product');
      }

      Get.snackbar(
        'خطأ',
        'لم يتم العثور على معلومات المطعم',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateComment(String value) {
    comment.value = value;
  }

  void showReviews() {
    Get.bottomSheet(
      const ReviewsBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> toggleReviewLike(int reviewId) async {
    try {
      final result = await _productDetailsService.likeReview(reviewId);

      // Update local review data
      final index = reviews.indexWhere((review) => review.id == reviewId);
      if (index != -1) {
        final review = reviews[index];
        reviews[index] = review.copyWith(
          likes: result['likes_count']!,
          dislikes: result['dislikes_count']!,
          isLiked: !review.isLiked,
          isDisliked: false,
        );
        reviews.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> toggleReviewDislike(int reviewId) async {
    try {
      final result = await _productDetailsService.dislikeReview(reviewId);

      // Update local review data
      final index = reviews.indexWhere((review) => review.id == reviewId);
      if (index != -1) {
        final review = reviews[index];
        reviews[index] = review.copyWith(
          likes: result['likes_count']!,
          dislikes: result['dislikes_count']!,
          isLiked: false,
          isDisliked: !review.isDisliked,
        );
        reviews.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void replyToReview(int reviewId) {
    Get.snackbar(
      'Reply',
      'Reply functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> addReview(int rating, String comment, {List<String>? images}) async {
    if (product.value == null) return;

    try {
      isAddingReview.value = true;

      final success = await _productDetailsService.addProductReview(
        product.value!.id,
        rating: rating,
        comment: comment,
        images: images,
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Review added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Reload reviews
        await _loadProductReviews();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isAddingReview.value = false;
    }
  }
  
  // Getters
  double get totalPrice {
    // Use calculated price from API if available, otherwise fallback to local calculation
    if (calculatedTotalPrice.value > 0) {
      return calculatedTotalPrice.value;
    }

    // Fallback to local calculation
    if (product.value == null) return 0.0;

    double total = product.value!.price * quantity.value;

    for (var option in additionalOptions) {
      if (option.isSelected && option.price != null) {
        total += option.price! * quantity.value;
      }
    }

    return total;
  }

  String get formattedRating => product.value?.rating.toString() ?? '0.0';
  String get formattedReviewCount => '(${product.value?.reviewCount ?? 0} Reviews)';
}
