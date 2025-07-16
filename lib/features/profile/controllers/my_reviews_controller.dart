import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/review_model.dart';

class MyReviewsController extends GetxController {
  // All reviews
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // _initializeSampleData(); // Temporarily disabled to test empty state
  }

  void _initializeSampleData() {
    // Add sample reviews
    reviews.addAll([
      ReviewModel(
        id: 1,
        productName: 'Caesar salad',
        productPrice: 50.00,
        productImage: 'assets/images/pizza_main.png',
        rating: 5,
        reviewDate: DateTime(2020, 3, 20),
        reviewText: 'It tasted amazing, and it\'s definitely worth a try! Every bite was enjoyable.',
      ),
      ReviewModel(
        id: 2,
        productName: 'Caesar salad',
        productPrice: 50.00,
        productImage: 'assets/images/pizza_main.png',
        rating: 5,
        reviewDate: DateTime(2020, 3, 20),
        reviewText: 'The food was excellent, the taste was fresh and gave a feeling of comfort.',
      ),
      ReviewModel(
        id: 3,
        productName: 'Caesar salad',
        productPrice: 50.00,
        productImage: 'assets/images/pizza_main.png',
        rating: 5,
        reviewDate: DateTime(2020, 3, 20),
        reviewText: 'It tasted amazing, and it\'s definitely worth a try! Every bite was enjoyable.',
      ),
    ]);
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
    _initializeSampleData();
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
