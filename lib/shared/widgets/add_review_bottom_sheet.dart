import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/shared/widgets/star_rating_widget.dart';

/// Controller for Add Review Bottom Sheet
class AddReviewController extends GetxController {
  final int productId;
  final String productName;
  final String? productImage;
  final Future<bool> Function(int rating, String comment, List<String>? images) onSubmit;

  AddReviewController({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.onSubmit,
  });

  // State
  final RxDouble rating = 0.0.obs;
  final RxString comment = ''.obs;
  final RxList<File> selectedImages = <File>[].obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Text controller
  final TextEditingController commentController = TextEditingController();

  // Max images allowed
  static const int maxImages = 5;

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

  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    if (selectedImages.length >= maxImages) {
      ToastService.showError('max_images_message'.trParams({'count': maxImages.toString()}));
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImages.add(File(image.path));
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  /// Pick image from camera
  Future<void> pickImageFromCamera() async {
    if (selectedImages.length >= maxImages) {
      ToastService.showError('max_images_message'.trParams({'count': maxImages.toString()}));
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImages.add(File(image.path));
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }

  /// Remove image at index
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      HapticFeedback.lightImpact();
    }
  }

  /// Validate and submit review
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

      // Convert images to base64 or URLs (for now, just paths)
      List<String>? imagePaths;
      if (selectedImages.isNotEmpty) {
        imagePaths = selectedImages.map((file) => file.path).toList();
      }

      final success = await onSubmit(
        rating.value.round(),
        comment.value.trim(),
        imagePaths,
      );

      if (success) {
        HapticFeedback.heavyImpact();
        Get.back(result: true);
        ToastService.showSuccess('review_submitted'.tr);
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      HapticFeedback.mediumImpact();
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Show image source picker
  void showImageSourcePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'add_photos'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF262626),
                ),
              ),
              const SizedBox(height: 24),
              
              // Camera option
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryColor,
                  ),
                ),
                title: Text(
                  'take_photo'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF262626),
                  ),
                ),
                onTap: () {
                  Get.back();
                  pickImageFromCamera();
                },
              ),
              
              const SizedBox(height: 8),
              
              // Gallery option
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.secondaryColor,
                  ),
                ),
                title: Text(
                  'choose_from_gallery'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF262626),
                  ),
                ),
                onTap: () {
                  Get.back();
                  pickImageFromGallery();
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}

/// Bottom sheet for adding product reviews
class AddReviewBottomSheet extends StatelessWidget {
  final int productId;
  final String productName;
  final String? productImage;
  final Future<bool> Function(int rating, String comment, List<String>? images) onSubmit;

  const AddReviewBottomSheet({
    super.key,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.onSubmit,
  });

  /// Show the bottom sheet
  static Future<bool?> show({
    required int productId,
    required String productName,
    String? productImage,
    required Future<bool> Function(int rating, String comment, List<String>? images) onSubmit,
  }) {
    return Get.bottomSheet<bool>(
      AddReviewBottomSheet(
        productId: productId,
        productName: productName,
        productImage: productImage,
        onSubmit: onSubmit,
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
      AddReviewController(
        productId: productId,
        productName: productName,
        productImage: productImage,
        onSubmit: onSubmit,
      ),
      tag: 'review_$productId',
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
          // Handle bar
          _buildHandleBar(),
          
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

  Widget _buildHandleBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AddReviewController controller) {
    return Row(
      children: [
        // Product image
        if (productImage != null)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF5F5F5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              productImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF5F5F5),
                child: const Icon(
                  Icons.fastfood_rounded,
                  color: Color(0xFFBDBDBD),
                  size: 30,
                ),
              ),
            ),
          )
        else
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF5F5F5),
            ),
            child: const Icon(
              Icons.fastfood_rounded,
              color: Color(0xFFBDBDBD),
              size: 30,
            ),
          ),
        
        const SizedBox(width: 16),
        
        // Product name and instruction
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
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
                'rate_this_item'.tr,
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

  Widget _buildRatingSection(AddReviewController controller) {
    return Center(
      child: Column(
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
          const SizedBox(height: 16),
          Obx(() => AnimatedStarRating(
            rating: controller.rating.value,
            onRatingChanged: controller.setRating,
            starSize: 48,
            showLabel: true,
          )),
        ],
      ),
    );
  }

  Widget _buildCommentSection(AddReviewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'review_text'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF262626),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${'optional'.tr})',
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.commentController,
          onChanged: controller.setComment,
          maxLines: 4,
          maxLength: 500,
          textInputAction: TextInputAction.done,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
            color: Color(0xFF262626),
          ),
          decoration: InputDecoration(
            hintText: 'share_your_experience'.tr,
            hintStyle: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              color: Color(0xFF999999),
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
            counterStyle: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection(AddReviewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                const SizedBox(width: 4),
                Text(
                  '(${'optional'.tr})',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
            Obx(() => Text(
              '${controller.selectedImages.length}/${AddReviewController.maxImages}',
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            )),
          ],
        ),
        const SizedBox(height: 12),
        
        // Images grid
        Obx(() => SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add photo button
              if (controller.selectedImages.length < AddReviewController.maxImages)
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
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'add'.tr,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Selected images
              ...controller.selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      // Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // Remove button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
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

  Widget _buildErrorMessage(AddReviewController controller) {
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

  Widget _buildSubmitButton(AddReviewController controller) {
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.secondaryColor,
                  ),
                ),
              )
            : Text(
                'submit'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
      ),
    ));
  }
}
