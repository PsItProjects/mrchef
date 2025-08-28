import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/features/product_details/models/review_model.dart';
import 'package:mrsheaf/features/product_details/widgets/reviews_bottom_sheet.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/product_details/services/product_details_service.dart';

class ProductDetailsController extends GetxController {
  // Services
  final ProductDetailsService _productDetailsService = ProductDetailsService();

  // Observable variables
  final RxInt quantity = 1.obs;
  final RxString selectedSize = 'S'.obs;
  final RxBool isFavorite = false.obs;
  final RxInt currentImageIndex = 0.obs;
  final RxList<AdditionalOption> additionalOptions = <AdditionalOption>[].obs;
  final RxString comment = ''.obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

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
    productId = Get.arguments?['productId'] ?? 1;
    _loadProductDetails();
  }
  
  /// Load product details from API
  Future<void> _loadProductDetails() async {
    try {
      isLoadingProduct.value = true;

      final productData = await _productDetailsService.getProductDetails(productId);
      product.value = productData;

      // Initialize reactive variables
      selectedSize.value = productData.sizes.isNotEmpty ? productData.sizes.first : 'S';
      additionalOptions.value = productData.additionalOptions;

      // Load reviews
      await _loadProductReviews();

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
  }
  
  void decreaseQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }
  
  void selectSize(String size) {
    selectedSize.value = size;
  }
  
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
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
    }
  }
  
  void addToCart() {
    if (product.value == null) return;

    try {
      final cartController = Get.find<CartController>();

      cartController.addToCart(
        product: product.value!,
        size: selectedSize.value,
        quantity: quantity.value,
        additionalOptions: additionalOptions.where((option) => option.isSelected).toList(),
      );

      // Show success message
      Get.snackbar(
        'تم بنجاح',
        'تم إضافة ${product.value!.name} إلى السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );

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
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة المنتج إلى السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );

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
    Get.snackbar(
      'Go to Store',
      'Navigating to store page...',
      snackPosition: SnackPosition.BOTTOM,
    );
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
