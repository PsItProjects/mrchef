import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/cart/models/cart_item_model.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';

class CartItemWidget extends GetView<CartController> {
  final CartItemModel cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isItemLoading(cartItem.id);

      return Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image — rounded card
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: const Color(0xFFF5F5F5),
                    child: cartItem.image.startsWith('http')
                        ? Image.network(
                            cartItem.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFF5F5F5),
                                child: Icon(Icons.restaurant_rounded, size: 32, color: Colors.grey[300]),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            cartItem.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.restaurant_rounded, size: 32, color: Colors.grey[300]);
                            },
                          ),
                  ),
                ),

                const SizedBox(width: 12),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + remove button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              cartItem.name,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF1A1A2E),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: isLoading ? null : onRemove,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFE53935)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Price
                      Text(
                        CurrencyHelper.formatPrice(cartItem.price),
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),

                      // Meta info (size + options)
                      if (cartItem.size.isNotEmpty || cartItem.additionalOptions.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (cartItem.size.isNotEmpty)
                              _buildTag('size_label'.tr, cartItem.size),
                            if (cartItem.additionalOptions.isNotEmpty)
                              _buildTag('additions_label'.tr, cartItem.additionalOptionsText),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Bottom row: details button + quantity controls
                      Row(
                        children: [
                          // Details button
                          if (cartItem.additionalOptions.isNotEmpty ||
                              (cartItem.specialInstructions?.isNotEmpty ?? false))
                            GestureDetector(
                              onTap: () => _showItemDetails(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFF6B6B80)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'order_details'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11,
                                        color: Color(0xFF6B6B80),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const Spacer(),

                          // Quantity controls — pill style
                          Container(
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Decrease
                                GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                          if (cartItem.quantity > 1) {
                                            HapticFeedback.lightImpact();
                                            onQuantityChanged(cartItem.quantity - 1);
                                          }
                                        },
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: cartItem.quantity > 1 ? Colors.white : Colors.transparent,
                                      shape: BoxShape.circle,
                                      boxShadow: cartItem.quantity > 1
                                          ? [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)]
                                          : null,
                                    ),
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: 18,
                                      color: cartItem.quantity > 1
                                          ? const Color(0xFF1A1A2E)
                                          : const Color(0xFFCCCCCC),
                                    ),
                                  ),
                                ),

                                // Quantity
                                SizedBox(
                                  width: 32,
                                  child: Center(
                                    child: Text(
                                      '${cartItem.quantity}',
                                      style: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ),
                                ),

                                // Increase
                                GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          onQuantityChanged(cartItem.quantity + 1);
                                        },
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                      color: Color(0xFF1A1A2E),
                                    ),
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
          ),

          // Loading overlay
          if (isLoading)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          fontSize: 11,
          color: Color(0xFF6B6B80),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showItemDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'order_details'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF6B6B80)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product name
            Text(
              cartItem.name,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            // Size
            if (cartItem.size.isNotEmpty)
              _buildDetailRow('size_label'.tr, cartItem.size),

            // Additional options
            if (cartItem.additionalOptions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'additions_label'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF6B6B80),
                ),
              ),
              const SizedBox(height: 6),
              ...cartItem.additionalOptions
                  .where((option) => option.isSelected)
                  .map((option) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '  •  ${option.name}',
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              CurrencyHelper.formatPrice(option.price),
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xFF6B6B80),
                              ),
                            ),
                          ],
                        ),
                      )),
            ],

            // Special instructions
            if (cartItem.specialInstructions?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              _buildDetailRow('special_notes'.tr, cartItem.specialInstructions!),
            ],

            // Total
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'item_total'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    CurrencyHelper.formatPrice(cartItem.totalPrice),
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF6B6B80),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
