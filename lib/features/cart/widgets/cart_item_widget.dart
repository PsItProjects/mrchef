import 'package:flutter/material.dart';
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
            margin: const EdgeInsets.only(bottom: 1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE3E3E3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Product image
                Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFC4C4C4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: cartItem.image.startsWith('http')
                  ? Image.network(
                      cartItem.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFC4C4C4),
                          child: const Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFC4C4C4),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      cartItem.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFC4C4C4),
                          child: const Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name and price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.name,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF262626),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      CurrencyHelper.formatPrice(cartItem.price),
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF5E5E5E),
                      ),
                    ),

                    // Size information
                    if (cartItem.size.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'الحجم: ${cartItem.size}',
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],

                    // Additional options
                    if (cartItem.additionalOptions.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'إضافات: ${cartItem.additionalOptionsText}',
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),

                // Details button (if has additional options or special instructions)
                if (cartItem.additionalOptions.isNotEmpty ||
                    (cartItem.specialInstructions?.isNotEmpty ?? false)) ...[
                  GestureDetector(
                    onTap: () => _showItemDetails(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Color(0xFF666666),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'تفاصيل الطلب',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Quantity controls
                Row(
                  children: [
                    // Decrease button
                    GestureDetector(
                      onTap: isLoading ? null : () {
                        if (cartItem.quantity > 1) {
                          onQuantityChanged(cartItem.quantity - 1);
                        }
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.remove_circle_outline,
                          size: 20,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 15),
                    
                    // Quantity text
                    Text(
                      cartItem.quantity.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF262626),
                      ),
                    ),
                    
                    const SizedBox(width: 15),
                    
                    // Increase button
                    GestureDetector(
                      onTap: isLoading ? null : () {
                        onQuantityChanged(cartItem.quantity + 1);
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Remove button
          GestureDetector(
            onTap: isLoading ? null : onRemove,
            child: Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.close,
                size: 20,
                color: Color(0xFF000000),
              ),
            ),
          ),
        ],
      ),
    ),

    // Loading overlay
    if (isLoading)
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            border: const Border(
              bottom: BorderSide(
                color: Color(0xFFE3E3E3),
                width: 1,
              ),
            ),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
              ),
            ),
          ),
        ),
      ),
        ],
      );
    });
  }

  void _showItemDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تفاصيل الطلب',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF262626),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF666666),
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
                color: Color(0xFF262626),
              ),
            ),

            const SizedBox(height: 12),

            // Size
            if (cartItem.size.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'الحجم: ',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Text(
                    cartItem.size,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF262626),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Additional options
            if (cartItem.additionalOptions.isNotEmpty) ...[
              const Text(
                'الإضافات المختارة:',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),
              ...cartItem.additionalOptions
                  .where((option) => option.isSelected)
                  .map((option) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '• ${option.name}',
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF262626),
                              ),
                            ),
                            Text(
                              CurrencyHelper.formatPrice(option.price),
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      )),
              const SizedBox(height: 12),
            ],

            // Special instructions
            if (cartItem.specialInstructions?.isNotEmpty ?? false) ...[
              const Text(
                'ملاحظات خاصة:',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cartItem.specialInstructions!,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF262626),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Total price
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إجمالي هذا العنصر:',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF262626),
                    ),
                  ),
                  Text(
                    CurrencyHelper.formatPrice(cartItem.totalPrice),
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF262626),
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
}
