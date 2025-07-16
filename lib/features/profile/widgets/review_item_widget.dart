import 'package:flutter/material.dart';
import 'package:mrsheaf/features/profile/models/review_model.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class ReviewItemWidget extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewProduct;

  const ReviewItemWidget({
    super.key,
    required this.review,
    required this.onEdit,
    required this.onDelete,
    required this.onViewProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3E3E3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Product info section
            Row(
              children: [
                // Product image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFFC4C4C4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      review.productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFC4C4C4),
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.productName,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF5E5E5E),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        review.formattedPrice,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Rating and date section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Star rating
                Row(
                  children: List.generate(5, (index) {
                    return Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.star,
                        size: 16,
                        color: review.starRatings[index] 
                            ? AppColors.primaryColor 
                            : const Color(0xFFE3E3E3),
                      ),
                    );
                  }),
                ),
                
                // Review date
                Text(
                  review.formattedDate,
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Review text
            Text(
              review.reviewText,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF1C1C1C),
                height: 1.4,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
