import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/my_reviews_controller.dart';
import 'package:mrsheaf/features/profile/widgets/review_item_widget.dart';

class ReviewsList extends GetView<MyReviewsController> {
  const ReviewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: controller.reviews.length,
        itemBuilder: (context, index) {
          final review = controller.reviews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ReviewItemWidget(
              review: review,
              onEdit: () => controller.editReview(review),
              onDelete: () => controller.deleteReview(review),
              onViewProduct: () => controller.viewProductDetails(review),
            ),
          );
        },
      )),
    );
  }
}
