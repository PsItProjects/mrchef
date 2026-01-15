import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/review_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/review_model.dart';
import 'package:mrsheaf/shared/widgets/edit_review_bottom_sheet.dart';

class MyReviewsController extends GetxController {
  // All reviews (original list)
  final RxList<ReviewModel> _allReviews = <ReviewModel>[].obs;

  // Filtered reviews (displayed list)
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  // Search query
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

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

    // Listen to search query changes
    debounce(
      searchQuery,
      (_) => _filterReviews(),
      time: const Duration(milliseconds: 300),
    );
  }
  
  /// Fetch user's reviews from API
  Future<void> fetchMyReviews() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (kDebugMode) {
        print('📝 MY_REVIEWS: Fetching user reviews...');
      }

      final fetchedReviews = await _reviewService.getMyReviews();
      _allReviews.value = fetchedReviews;

      // Apply current filter
      _filterReviews();

      if (kDebugMode) {
        print('✅ MY_REVIEWS: Fetched ${_allReviews.length} reviews');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ MY_REVIEWS: Error fetching reviews - $e');
      }
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      // If 404 or no reviews, just clear the list
      if (e.toString().contains('404') || e.toString().contains('No reviews')) {
        _allReviews.clear();
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

  /// Filter reviews based on search query
  void _filterReviews() {
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      // Show all reviews
      reviews.value = List.from(_allReviews);
    } else {
      // Filter by product name or review text
      reviews.value = _allReviews.where((review) {
        final productName = review.productName.toLowerCase();
        final reviewText = review.reviewText.toLowerCase();
        return productName.contains(query) || reviewText.contains(query);
      }).toList();
    }

    if (kDebugMode) {
      print('🔍 MY_REVIEWS: Filtered ${reviews.length} reviews from ${_allReviews.length} (query: "$query")');
    }
  }

  /// Toggle search mode
  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      // Clear search when closing
      clearSearch();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  // Review actions
  Future<void> editReview(ReviewModel review) async {
    if (kDebugMode) {
      print('✏️ MY_REVIEWS: Opening edit review for #${review.id}');
    }

    final result = await EditReviewBottomSheet.show(
      review: review,
      onUpdate: (reviewId, rating, comment, images) async {
        return await _performUpdateReview(reviewId, rating, comment, images);
      },
    );

    if (result == true) {
      // Refresh reviews after successful update
      await refreshReviews();
    }
  }

  /// Perform review update
  Future<bool> _performUpdateReview(
    int reviewId,
    int rating,
    String comment,
    List<String>? images,
  ) async {
    try {
      if (kDebugMode) {
        print('📝 MY_REVIEWS: Updating review #$reviewId...');
        print('   Rating: $rating');
        print('   Comment: $comment');
        print('   Images: ${images?.length ?? 0}');
      }

      // Convert image paths to File objects (only for new images, not URLs)
      List<File>? imageFiles;
      if (images != null && images.isNotEmpty) {
        imageFiles = images
            .where((path) => !path.startsWith('http')) // Filter out existing URLs
            .map((path) => File(path))
            .toList();
      }

      await _reviewService.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
        images: imageFiles,
      );

      if (kDebugMode) {
        print('✅ MY_REVIEWS: Review updated successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ MY_REVIEWS: Error updating review: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteReview(ReviewModel review) async {
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warningColor,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'delete_review_confirmation'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF262626),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'delete_review_warning'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF5E5E5E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.hintTextColor,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'delete'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      await _performDeleteReview(review);
    }
  }

  Future<void> _performDeleteReview(ReviewModel review) async {
    try {
      if (kDebugMode) {
        print('🗑️ MY_REVIEWS: Deleting review #${review.id}...');
      }

      await _reviewService.deleteReview(review.id);

      // Remove from list
      reviews.removeWhere((r) => r.id == review.id);

      if (kDebugMode) {
        print('✅ MY_REVIEWS: Review deleted successfully');
      }

      // Show success dialog
      await Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.successColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'review_deleted_successfully'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF262626),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ok'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ MY_REVIEWS: Error deleting review: $e');
      }

      Get.snackbar(
        'error'.tr,
        'failed_to_delete_review'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
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
