import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/review_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/review_model.dart';

class MyReviewsController extends GetxController {
  // All reviews
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Error state
  final RxString errorMessage = ''.obs;
  
  // Review service
  late final ReviewService _reviewService;

  @override
  void onInit() {
    super.onInit();
    _reviewService = ReviewService();
    fetchMyReviews();
  }
  
  /// Fetch user's reviews from API
  Future<void> fetchMyReviews() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      if (kDebugMode) {
        print('📝 MY_REVIEWS: Fetching user reviews...');
      }
      
      reviews.value = await _reviewService.getMyReviews();
      
      if (kDebugMode) {
        print('✅ MY_REVIEWS: Fetched ${reviews.length} reviews');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ MY_REVIEWS: Error fetching reviews - $e');
      }
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
      // If 404 or no reviews, just clear the list
      if (e.toString().contains('404') || e.toString().contains('No reviews')) {
        reviews.clear();
        errorMessage.value = '';
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Refresh reviews
  Future<void> refreshReviews() async {
    await fetchMyReviews();
  }

  // Review actions
  void editReview(ReviewModel review) {
    Get.snackbar(
      'Edit Review',
      'Editing review for ${review.productName}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to edit review screen
  }

  void deleteReview(ReviewModel review) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Review',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        content: Text(
          'Are you sure you want to delete your review for ${review.productName}?',
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF5E5E5E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performDeleteReview(review);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFFEB5757),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performDeleteReview(ReviewModel review) {
    reviews.removeWhere((r) => r.id == review.id);
    Get.snackbar(
      'Review Deleted',
      'Your review has been deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void viewProductDetails(ReviewModel review) {
    Get.snackbar(
      'Product Details',
      'Viewing details for ${review.productName}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to product details screen
  }

  // Add sample data for testing
  void addSampleData() {
    // TODO: Initialize sample data if needed for testing
  }

  // Clear all reviews for testing empty state
  void clearAllReviews() {
    reviews.clear();
  }

  // Getters for UI
  bool get hasReviews => reviews.isNotEmpty;
  
  int get totalReviews => reviews.length;
  
  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }
}
