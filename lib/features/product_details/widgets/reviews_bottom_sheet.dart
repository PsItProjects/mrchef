import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';
import 'package:mrsheaf/features/product_details/widgets/review_item.dart';

class ReviewsBottomSheet extends GetView<ProductDetailsController> {
  const ReviewsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 562,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 428,
            height: 562,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                // White overlay container
                Container(
                  width: 428,
                  height: 562,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 16,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header section
                      Container(
                        padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE3E3E3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Reviews count
                            const Text(
                              '205 Reviews',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Color(0xFF262626),
                                letterSpacing: 1.5,
                              ),
                            ),
                            
                            // Rating display
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/star_icon.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '4.8',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Color(0xFF262626),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Reviews list
                      Expanded(
                        child: Obx(() => ListView.builder(
                          itemCount: controller.reviews.length,
                          itemBuilder: (context, index) {
                            return ReviewItem(
                              review: controller.reviews[index],
                            );
                          },
                        )),
                      ),
                      
                      // Add review button
                      Container(
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        child: GestureDetector(
                          onTap: controller.addReview,
                          child: Container(
                            width: 380,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Add your review',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: AppColors.primaryColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
