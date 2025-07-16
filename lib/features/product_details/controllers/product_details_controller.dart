import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/features/product_details/models/review_model.dart';
import 'package:mrsheaf/features/product_details/widgets/reviews_bottom_sheet.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';

class ProductDetailsController extends GetxController {
  // Observable variables
  final RxInt quantity = 1.obs;
  final RxString selectedSize = 'S'.obs;
  final RxBool isFavorite = false.obs;
  final RxInt currentImageIndex = 0.obs;
  final RxList<AdditionalOption> additionalOptions = <AdditionalOption>[].obs;
  final RxString comment = ''.obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  
  // Product data
  late ProductModel product;
  
  @override
  void onInit() {
    super.onInit();
    _initializeProduct();
    _initializeReviews();
  }
  
  void _initializeProduct() {
    // Initialize with sample data based on Figma design
    product = ProductModel(
      id: 1,
      name: 'Vegetable pizza',
      description: 'Tomato sauce, mozzarella cheese and a mix of fresh vegetables, perfect for a light and delicious meal.',
      price: 39.99,
      originalPrice: 70.00,
      image: 'assets/images/pizza_main.png',
      rating: 4.8,
      reviewCount: 205,
      productCode: '#G7432642',
      sizes: ['L', 'M', 'S'],
      images: [
        'assets/images/pizza_main.png',
        'assets/images/pizza_main.png',
        'assets/images/pizza_main.png',
      ],
      additionalOptions: [
        AdditionalOption(
          id: 1,
          name: 'Coca Cola 330 ml',
          icon: 'salad',
          isSelected: true,
        ),
        AdditionalOption(
          id: 2,
          name: 'Potato meal',
          icon: 'salad',
          isSelected: false,
        ),
        AdditionalOption(
          id: 3,
          name: 'cheese',
          price: 3.0,
          icon: 'salad',
          isSelected: false,
        ),
      ],
    );
    
    // Initialize reactive variables
    selectedSize.value = 'S';
    additionalOptions.value = product.additionalOptions;
  }

  void _initializeReviews() {
    // Initialize with sample reviews data
    reviews.value = [
      ReviewModel(
        id: 1,
        userName: 'Jenny Wilson',
        userAvatar: 'assets/images/pizza_main.png',
        rating: 5.0,
        comment: 'La pizza a très bon goût et a l\'air délicieuse, tout comme les photos',
        date: DateTime.now().subtract(const Duration(days: 2)),
        images: [
          'assets/images/pizza_main.png',
          'assets/images/pizza_main.png',
          'assets/images/pizza_main.png',
        ],
        likes: 0,
        dislikes: 0,
        replies: 1,
      ),
      ReviewModel(
        id: 2,
        userName: 'Jenny Wilson',
        userAvatar: 'assets/images/pizza_main.png',
        rating: 5.0,
        comment: 'Amet minim mollit non deserunt ullamco est sit aliqua dolor do.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        images: [],
        likes: 0,
        dislikes: 0,
        replies: 1,
      ),
      ReviewModel(
        id: 3,
        userName: 'Jenny Wilson',
        userAvatar: 'assets/images/pizza_main.png',
        rating: 5.0,
        comment: 'Amet minim mollit non deserunt ullamco est sit aliqua dolor do.',
        date: DateTime.now().subtract(const Duration(days: 7)),
        images: [],
        likes: 0,
        dislikes: 0,
        replies: 1,
      ),
    ];
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
    final cartController = Get.find<CartController>();

    cartController.addToCart(
      product: product,
      size: selectedSize.value,
      quantity: quantity.value,
      additionalOptions: additionalOptions.toList(),
    );
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
      'Sharing ${product.name} with friend...',
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

  void toggleReviewLike(int reviewId) {
    final index = reviews.indexWhere((review) => review.id == reviewId);
    if (index != -1) {
      final review = reviews[index];
      if (review.isLiked) {
        // Unlike
        reviews[index] = review.copyWith(
          isLiked: false,
          likes: review.likes - 1,
        );
      } else {
        // Like (and remove dislike if exists)
        reviews[index] = review.copyWith(
          isLiked: true,
          likes: review.likes + 1,
          isDisliked: false,
          dislikes: review.isDisliked ? review.dislikes - 1 : review.dislikes,
        );
      }
      reviews.refresh();
    }
  }

  void toggleReviewDislike(int reviewId) {
    final index = reviews.indexWhere((review) => review.id == reviewId);
    if (index != -1) {
      final review = reviews[index];
      if (review.isDisliked) {
        // Remove dislike
        reviews[index] = review.copyWith(
          isDisliked: false,
          dislikes: review.dislikes - 1,
        );
      } else {
        // Dislike (and remove like if exists)
        reviews[index] = review.copyWith(
          isDisliked: true,
          dislikes: review.dislikes + 1,
          isLiked: false,
          likes: review.isLiked ? review.likes - 1 : review.likes,
        );
      }
      reviews.refresh();
    }
  }

  void replyToReview(int reviewId) {
    Get.snackbar(
      'Reply',
      'Reply functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addReview() {
    Get.snackbar(
      'Add Review',
      'Add review functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // Getters
  double get totalPrice {
    double total = product.price * quantity.value;
    
    for (var option in additionalOptions) {
      if (option.isSelected && option.price != null) {
        total += option.price! * quantity.value;
      }
    }
    
    return total;
  }
  
  String get formattedRating => product.rating.toString();
  String get formattedReviewCount => '(${product.reviewCount} Reviews)';
}
