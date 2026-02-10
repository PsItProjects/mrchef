import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
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
              // Avatar — handles network URLs, assets, and empty
              _buildAvatar(),
              const SizedBox(width: 12),

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
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
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

              // Star rating — Material icons
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < review.rating
                        ? const Color(0xFFFFB800)
                        : const Color(0xFFE8E8E8),
                    size: 16,
                  );
                }),
              ),
            ],
          ),

          // Review comment
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
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
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length > 4 ? 4 : review.images.length,
                itemBuilder: (context, index) {
                  final img = review.images[index];
                  return Container(
                    width: 64,
                    height: 64,
                    margin: EdgeInsets.only(right: index < review.images.length - 1 ? 8 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF0F0F0),
                      image: DecorationImage(
                        image: _resolveImage(img),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Like / Dislike row (no replies)
          const SizedBox(height: 10),
          Row(
            children: [
              // Like
              GestureDetector(
                onTap: () => controller.toggleReviewLike(review.id),
                child: Row(
                  children: [
                    Icon(
                      review.isLiked
                          ? Icons.thumb_up_alt_rounded
                          : Icons.thumb_up_alt_outlined,
                      size: 15,
                      color: review.isLiked
                          ? AppColors.primaryColor
                          : Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.likes}',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: review.isLiked
                            ? AppColors.primaryColor
                            : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Dislike
              GestureDetector(
                onTap: () => controller.toggleReviewDislike(review.id),
                child: Row(
                  children: [
                    Icon(
                      review.isDisliked
                          ? Icons.thumb_down_alt_rounded
                          : Icons.thumb_down_alt_outlined,
                      size: 15,
                      color: review.isDisliked
                          ? const Color(0xFFEB5757)
                          : Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.dislikes}',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: review.isDisliked
                            ? const Color(0xFFEB5757)
                            : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build avatar — handles network URLs, asset paths, and empty/missing
  Widget _buildAvatar() {
    final avatar = review.userAvatar;
    final hasAvatar = avatar.isNotEmpty;
    final isNetwork = hasAvatar && avatar.startsWith('http');

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF0F0F0),
        image: hasAvatar
            ? DecorationImage(
                image: isNetwork
                    ? NetworkImage(avatar)
                    : AssetImage(avatar) as ImageProvider,
                fit: BoxFit.cover,
                onError: (_, __) {},
              )
            : null,
      ),
      child: !hasAvatar
          ? const Icon(Icons.person_rounded, size: 22, color: Color(0xFFBBBBBB))
          : null,
    );
  }

  /// Resolve image provider — network or asset
  ImageProvider _resolveImage(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
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
