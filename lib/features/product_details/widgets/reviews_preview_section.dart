import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';
import 'package:mrsheaf/features/product_details/models/review_model.dart';

class ReviewsPreviewSection extends GetView<ProductDetailsController> {
  const ReviewsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final product = controller.product.value;
      if (product == null) return const SizedBox.shrink();

      final rating = product.rating;
      final reviewCount = product.reviewCount;
      final hasReviews = controller.hasReviews;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'reviews'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$reviewCount',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Color(0xFF6B6B80),
                    ),
                  ),
                ),
                const Spacer(),
                if (hasReviews)
                  GestureDetector(
                    onTap: controller.showReviews,
                    child: Row(
                      children: [
                        Text(
                          'see_all'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Get.locale == const Locale('ar')
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          color: AppColors.primaryColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Rating overview card (only show if has reviews)
            if (hasReviews)
              _buildRatingOverview(rating, reviewCount),

            // Recent reviews preview (max 2)
            if (controller.reviews.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...controller.reviews.take(2).map((review) {
                return _buildReviewPreviewCard(review);
              }),
            ],

            // Empty state — "New" product, no reviews yet
            if (!hasReviews)
              _buildEmptyReviewsState(),
          ],
        ),
      );
    });
  }

  Widget _buildRatingOverview(double rating, int reviewCount) {
    // Use real breakdown from API
    final breakdown = controller.realStarsBreakdown;
    final totalReviews = breakdown.values.fold<int>(0, (sum, v) => sum + v);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Big rating number
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                  color: Color(0xFF1A1A2E),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              // Star row
              Row(
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  if (starValue <= rating.floor()) {
                    return const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB800),
                      size: 16,
                    );
                  } else if (starValue - 0.5 <= rating) {
                    return const Icon(
                      Icons.star_half_rounded,
                      color: Color(0xFFFFB800),
                      size: 16,
                    );
                  } else {
                    return Icon(
                      Icons.star_outline_rounded,
                      color: Colors.grey[300],
                      size: 16,
                    );
                  }
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$reviewCount ${'reviews'.tr}',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // Rating distribution bars — from real backend data
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final starLevel = 5 - index;
                final count = breakdown[starLevel] ?? 0;
                final percentage = totalReviews > 0
                    ? count / totalReviews
                    : 0.0;
                return _buildRatingBar(starLevel, percentage);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int starLevel, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$starLevel',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 12),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation<Color>(
                  starLevel >= 4
                      ? const Color(0xFFFFB800)
                      : starLevel >= 3
                          ? const Color(0xFFFFC947)
                          : const Color(0xFFCCCCCC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPreviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF0F0F0),
                  image: review.userAvatar.isNotEmpty
                      ? DecorationImage(
                          image: review.userAvatar.startsWith('http')
                              ? NetworkImage(review.userAvatar)
                              : AssetImage(review.userAvatar) as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: review.userAvatar.isEmpty
                    ? const Icon(Icons.person_rounded, size: 20, color: Color(0xFFBBBBBB))
                    : null,
              ),
              const SizedBox(width: 10),

              // Name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      _formatDate(review.date),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              // Stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < review.rating
                        ? const Color(0xFFFFB800)
                        : const Color(0xFFE8E8E8),
                    size: 14,
                  );
                }),
              ),
            ],
          ),

          // Comment
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Color(0xFF6B6B80),
                height: 1.5,
              ),
            ),
          ],

          // Review images
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length > 4 ? 4 : review.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF0F0F0),
                      image: DecorationImage(
                        image: review.images[index].startsWith('http')
                            ? NetworkImage(review.images[index])
                            : AssetImage(review.images[index]) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Like count
          if (review.likes > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.thumb_up_alt_rounded, size: 13, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '${review.likes}',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyReviewsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.rate_review_outlined, size: 30, color: Colors.grey[350]),
          ),
          const SizedBox(height: 12),
          Text(
            'no_reviews_yet'.tr,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'order_to_review'.tr,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today'.tr;
    } else if (diff.inDays == 1) {
      return 'yesterday'.tr;
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ${'days_ago'.tr}';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks ${'weeks_ago'.tr}';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months ${'months_ago'.tr}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
