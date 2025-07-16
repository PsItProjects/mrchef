import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/models/review_model.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class ReviewItem extends GetView<ProductDetailsController> {
  final ReviewModel review;

  const ReviewItem({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF2F2F2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(review.userAvatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Review content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name and rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF262626),
                      ),
                    ),
                    
                    // Star rating
                    Row(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: SvgPicture.asset(
                            'assets/icons/star_icon.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              index < review.rating 
                                ? AppColors.primaryColor 
                                : const Color(0xFFE0E0E0),
                              BlendMode.srcIn,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Review images (if any)
                if (review.images.isNotEmpty) ...[
                  Row(
                    children: review.images.take(3).map((image) {
                      return Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                ],
                
                // Review comment
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF999999),
                    height: 1.35,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Action buttons (like, dislike, reply)
                Row(
                  children: [
                    // Like button
                    GestureDetector(
                      onTap: () => controller.toggleReviewLike(review.id),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/like_icon.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              review.isLiked 
                                ? AppColors.primaryColor 
                                : const Color(0xFF999999),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            review.likes.toString(),
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Dislike button
                    GestureDetector(
                      onTap: () => controller.toggleReviewDislike(review.id),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/dislike_icon.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              review.isDisliked 
                                ? const Color(0xFFEB5757) 
                                : const Color(0xFF999999),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            review.dislikes.toString(),
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Reply button
                    GestureDetector(
                      onTap: () => controller.replyToReview(review.id),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/chat_reply_icon.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF999999),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${review.replies} Replay',
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
