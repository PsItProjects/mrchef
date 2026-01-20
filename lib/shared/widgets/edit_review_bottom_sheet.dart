import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/review_model.dart';
import 'package:mrsheaf/shared/widgets/star_rating_widget.dart';

/// Controller for Edit Review Bottom Sheet
class EditReviewController extends GetxController {
  final ReviewModel review;
  final Future<bool> Function(int reviewId, int rating, String comment, List<String>? images) onUpdate;

  EditReviewController({
    required this.review,
    required this.onUpdate,
  });

  // State
  late final RxDouble rating;
  late final RxString comment;
  final RxList<File> selectedImages = <File>[].obs;
  final RxList<String> existingImages = <String>[].obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Text controller
  final TextEditingController commentController = TextEditingController();

  // Max images allowed
  static const int maxImages = 5;

  @override
  void onInit() {
    super.onInit();
    // Initialize with existing review data
    rating = review.rating.toDouble().obs;
    comment = review.reviewText.obs;
    commentController.text = review.reviewText;
    existingImages.value = List<String>.from(review.images);
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  /// Update rating
  void setRating(double value) {
    rating.value = value;
    errorMessage.value = '';
  }

  /// Update comment
  void setComment(String value) {
    comment.value = value;
  }

  /// Get total images count
  int get totalImagesCount => existingImages.length + selectedImages.length;

  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      if (totalImagesCount >= maxImages) {
        ToastService.showWarning('max_images_message'.tr.replaceAll('@count', maxImages.toString()));
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImages.add(File(image.path));
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      ToastService.showError('failed_to_pick_image'.tr);
    }
  }

  /// Take photo with camera
  Future<void> takePhoto() async {
    try {
      if (totalImagesCount >= maxImages) {
        ToastService.showWarning('max_images_message'.tr.replaceAll('@count', maxImages.toString()));
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        selectedImages.add(File(photo.path));
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      ToastService.showError('failed_to_take_photo'.tr);
    }
  }

  /// Remove selected image
  void removeSelectedImage(int index) {
    selectedImages.removeAt(index);
    HapticFeedback.lightImpact();
  }

  /// Remove existing image
  void removeExistingImage(int index) {
    existingImages.removeAt(index);
    HapticFeedback.lightImpact();
  }

  /// Show image source picker
  void showImageSourcePicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryColor),
                title: Text('choose_from_gallery'.tr),
                onTap: () {
                  Get.back();
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryColor),
                title: Text('take_photo'.tr),
                onTap: () {
                  Get.back();
                  takePhoto();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isDismissible: true,
    );
  }

  /// Submit updated review
  Future<void> submitReview() async {
    // Validate rating
    if (rating.value == 0) {
      errorMessage.value = 'please_select_rating'.tr;
      HapticFeedback.mediumImpact();
      return;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      // Combine existing and new images
      List<String>? allImages;
      if (existingImages.isNotEmpty || selectedImages.isNotEmpty) {
        allImages = [
          ...existingImages,
          ...selectedImages.map((file) => file.path),
        ];
      }

      final success = await onUpdate(
        review.id,
        rating.value.round(),
        comment.value.trim(),
        allImages,
      );

      if (success) {
        HapticFeedback.heavyImpact();
        Get.back(result: true);
        ToastService.showSuccess('review_updated_successfully'.tr);
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      HapticFeedback.mediumImpact();
    } finally {
      isSubmitting.value = false;
    }
  }
}



/// Bottom sheet for editing product reviews
class EditReviewBottomSheet extends StatelessWidget {
  final ReviewModel review;
  final Future<bool> Function(int reviewId, int rating, String comment, List<String>? images) onUpdate;

  const EditReviewBottomSheet({
    super.key,
    required this.review,
    required this.onUpdate,
  });

  /// Show the bottom sheet
  static Future<bool?> show({
    required ReviewModel review,
    required Future<bool> Function(int reviewId, int rating, String comment, List<String>? images) onUpdate,
  }) {
    return Get.bottomSheet<bool>(
      EditReviewBottomSheet(
        review: review,
        onUpdate: onUpdate,
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      EditReviewController(
        review: review,
        onUpdate: onUpdate,
      ),
      tag: 'edit_review_${review.id}',
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with product info
                  _buildHeader(controller),

                  const SizedBox(height: 24),

                  // Star rating section
                  _buildRatingSection(controller),

                  const SizedBox(height: 24),

                  // Comment input
                  _buildCommentSection(controller),

                  const SizedBox(height: 20),

                  // Photos section
                  _buildPhotosSection(controller),

                  const SizedBox(height: 16),

                  // Error message
                  _buildErrorMessage(controller),

                  const SizedBox(height: 24),

                  // Submit button
                  _buildSubmitButton(controller),

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(EditReviewController controller) {
    return Row(
      children: [
        // Product image
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF7F7FB),
          ),
          clipBehavior: Clip.antiAlias,
          child: review.productImage != null
              ? Image.network(
                  review.productImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.restaurant_menu_rounded,
                      color: Color(0xFFCCCCCC),
                      size: 32,
                    );
                  },
                )
              : const Icon(
                  Icons.restaurant_menu_rounded,
                  color: Color(0xFFCCCCCC),
                  size: 32,
                ),
        ),

        const SizedBox(width: 16),

        // Product name and instruction
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.productName,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF262626),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'edit_your_review'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),

        // Close button
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close_rounded),
          color: const Color(0xFF999999),
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _buildRatingSection(EditReviewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'your_rating'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),

        const SizedBox(height: 12),

        // Star rating
        Obx(() => StarRatingWidget(
          rating: controller.rating.value,
          onRatingChanged: controller.setRating,
          starSize: 40,
          isReadOnly: false,
        )),
      ],
    );
  }

  Widget _buildCommentSection(EditReviewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'your_comment'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),

        const SizedBox(height: 12),

        // Comment text field
        TextField(
          controller: controller.commentController,
          onChanged: controller.setComment,
          maxLines: 5,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: 'share_your_experience'.tr,
            hintStyle: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              color: Color(0xFFCCCCCC),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F7FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 15,
            color: Color(0xFF262626),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection(EditReviewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'add_photos'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),

        const SizedBox(height: 12),

        // Images grid
        Obx(() => SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add photo button
              if (controller.totalImagesCount < EditReviewController.maxImages)
                GestureDetector(
                  onTap: controller.showImageSourcePicker,
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          color: AppColors.primaryColor,
                          size: 28,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Existing images
              ...controller.existingImages.asMap().entries.map((entry) {
                final index = entry.key;
                final imageUrl = entry.value;
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF7F7FB),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image_rounded,
                            color: Color(0xFFCCCCCC),
                          );
                        },
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeExistingImage(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              // Selected new images
              ...controller.selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF7F7FB),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        file,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeSelectedImage(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildErrorMessage(EditReviewController controller) {
    return Obx(() {
      if (controller.errorMessage.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.errorColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  color: AppColors.errorColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubmitButton(EditReviewController controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.isSubmitting.value || controller.rating.value == 0
            ? null
            : controller.submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.secondaryColor,
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          disabledForegroundColor: const Color(0xFF999999),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: controller.isSubmitting.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                ),
              )
            : Text(
                'update_review'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
      ),
    ));
  }
}
