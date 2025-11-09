import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_colors.dart';

class ProductAttachmentCard extends StatelessWidget {
  final Map<String, dynamic> attachments;

  const ProductAttachmentCard({
    super.key,
    required this.attachments,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final items = attachments['items'] as List<dynamic>? ?? [];
    final totalAmount = attachments['total_amount'] ?? 0;
    final itemCount = attachments['item_count'] ?? items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 20,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'تفاصيل الطلب' : 'Order Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Items list
          ...items.map((item) => _buildProductItem(item, isArabic)).toList(),

          const SizedBox(height: 12),

          // Divider
          Divider(
            color: Colors.grey[300],
            height: 1,
          ),

          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'المجموع' : 'Total',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF262626),
                ),
              ),
              Text(
                '$totalAmount ${isArabic ? 'ر.س' : 'SAR'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),

          // Item count
          const SizedBox(height: 4),
          Text(
            isArabic
                ? '$itemCount ${itemCount == 1 ? 'منتج' : 'منتجات'}'
                : '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item, bool isArabic) {
    final productName = item['product_name'] ?? '';
    final quantity = item['quantity'] ?? 1;
    final totalPrice = item['total_price'] ?? 0;
    final size = item['size'];
    final selectedOptions = item['selected_options'] as List<dynamic>? ?? [];
    final specialInstructions = item['special_instructions'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quantity badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${quantity}x',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Product name
              Expanded(
                child: Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF262626),
                  ),
                ),
              ),

              // Price
              Text(
                '$totalPrice ${isArabic ? 'ر.س' : 'SAR'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF262626),
                ),
              ),
            ],
          ),

          // Size
          if (size != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                '${isArabic ? 'الحجم' : 'Size'}: $size',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],

          // Selected options
          if (selectedOptions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                '${isArabic ? 'الإضافات' : 'Options'}: ${selectedOptions.map((opt) => opt['name'] ?? opt['option_name']).join(', ')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],

          // Special instructions
          if (specialInstructions != null && specialInstructions.toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                '${isArabic ? 'ملاحظات' : 'Notes'}: $specialInstructions',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

