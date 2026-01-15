import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/my_reviews_controller.dart';
import 'package:mrsheaf/features/profile/widgets/my_reviews_header.dart';
import 'package:mrsheaf/features/profile/widgets/reviews_list.dart';
import 'package:mrsheaf/features/profile/widgets/empty_reviews_widget.dart';

class MyReviewsScreen extends GetView<MyReviewsController> {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const MyReviewsHeader(),
            
            // Content
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }
                
                // Error state
                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: controller.refreshReviews,
                          icon: const Icon(Icons.refresh),
                          label: Text('retry'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: AppColors.secondaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Empty state
                if (!controller.hasReviews) {
                  return const EmptyReviewsWidget();
                }
                
                // Reviews list with pull to refresh
                return RefreshIndicator(
                  onRefresh: controller.refreshReviews,
                  color: AppColors.primaryColor,
                  child: const ReviewsList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
