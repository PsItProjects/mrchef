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
                if (!controller.hasReviews) {
                  return const EmptyReviewsWidget();
                } else {
                  return const ReviewsList();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
