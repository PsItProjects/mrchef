import 'package:flutter/material.dart';
import 'package:mrsheaf/features/cart/models/cart_item_model.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';

class CartItemWidget extends StatelessWidget {
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
    return Container(
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
              child: Image.asset(
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
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Quantity controls
                Row(
                  children: [
                    // Decrease button
                    GestureDetector(
                      onTap: () {
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
                      onTap: () {
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
            onTap: onRemove,
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
    );
  }
}
