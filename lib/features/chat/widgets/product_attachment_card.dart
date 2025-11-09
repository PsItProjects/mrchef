import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    final orderId = attachments['order_id']; // For approved orders
    final requestNumber = attachments['request_number']; // For pending requests

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Simple and clean
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        isArabic ? 'تفاصيل الطلب' : 'Order Details',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF262626),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($itemCount ${isArabic ? (itemCount == 1 ? 'منتج' : 'منتجات') : (itemCount == 1 ? 'item' : 'items')})',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Show order ID or request number - smaller and subtle
                if (orderId != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#$orderId',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ] else if (requestNumber != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#$requestNumber',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Items list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...items.map((item) => _buildProductItem(item, isArabic)).toList(),
              ],
            ),
          ),

          // Total section - clean and simple
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(11),
                bottomRight: Radius.circular(11),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isArabic ? 'المجموع الكلي' : 'Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$totalAmount ${isArabic ? 'ر.س' : 'SAR'}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item, bool isArabic) {
    final productName = item['product_name'] ?? '';
    final productImage = item['product_image'];
    final quantity = item['quantity'] ?? 1;
    final totalPrice = item['total_price'] ?? 0;
    final unitPrice = item['unit_price'] ?? 0;
    final size = item['size'];
    final selectedOptions = item['selected_options'] as List<dynamic>? ?? [];
    final specialInstructions = item['special_instructions'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: productImage != null && productImage.toString().isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: productImage,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.restaurant,
                            size: 28,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.restaurant,
                          size: 28,
                          color: Colors.grey[400],
                        ),
                      ),
              ),

              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF262626),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Quantity and Unit Price in one row
                    Row(
                      children: [
                        // Quantity badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${isArabic ? 'الكمية' : 'Qty'}: $quantity',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Unit price
                        Text(
                          '$unitPrice ${isArabic ? 'ر.س' : 'SAR'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' ${isArabic ? '/ وحدة' : '/ unit'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Additional details below image and name
          const SizedBox(height: 10),

          // Size, Options, Notes in a clean list
          if (size != null) ...[
            _buildDetailRow(
              icon: Icons.straighten,
              label: isArabic ? 'الحجم' : 'Size',
              value: size,
              isArabic: isArabic,
            ),
          ],

          if (selectedOptions.isNotEmpty) ...[
            _buildDetailRow(
              icon: Icons.add_circle_outline,
              label: isArabic ? 'الإضافات' : 'Options',
              value: selectedOptions.map((opt) => opt['name'] ?? opt['option_name']).join(', '),
              isArabic: isArabic,
            ),
          ],

          if (specialInstructions != null && specialInstructions.toString().isNotEmpty) ...[
            _buildDetailRow(
              icon: Icons.note_outlined,
              label: isArabic ? 'ملاحظات' : 'Notes',
              value: specialInstructions,
              isArabic: isArabic,
              isItalic: true,
            ),
          ],

          // Total price - prominent at bottom
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'الإجمالي' : 'Total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '$totalPrice ${isArabic ? 'ر.س' : 'SAR'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isArabic,
    bool isItalic = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

