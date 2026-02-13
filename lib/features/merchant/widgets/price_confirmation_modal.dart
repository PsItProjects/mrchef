import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';

class PriceConfirmationModal {
  static void show({
    required BuildContext context,
    required String orderNumber,
    required double defaultPrice,
    required Function(double?, double?) onConfirm,
    String deliveryFeeType = 'negotiable',
  }) {
    final TextEditingController priceController = TextEditingController();
    final TextEditingController deliveryFeeController = TextEditingController();
    final bool showDeliveryFeeInput = deliveryFeeType == 'negotiable';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'confirm_order'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
              const SizedBox(height: 8),

              // Order number
              Text(
                '${TranslationHelper.isArabic ? 'طلب' : 'Order'} $orderNumber',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Price info text
              Text(
                'agreed_price_info'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),

              // Price input field
              TextField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'agreed_price'.tr,
                  hintText: defaultPrice.toStringAsFixed(2),
                  suffixText: TranslationHelper.isArabic ? 'ر.س' : 'SAR',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),

              // Default price hint
              Text(
                '${TranslationHelper.isArabic ? 'السعر الافتراضي:' : 'Default price:'} ${defaultPrice.toStringAsFixed(2)} ${TranslationHelper.isArabic ? 'ر.س' : 'SAR'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),

              // ── Delivery fee input (only for negotiable type) ──
              if (showDeliveryFeeInput) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delivery_dining_rounded,
                          size: 18,
                          color:
                              AppColors.secondaryColor.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          TranslationHelper.isArabic
                              ? 'رسوم التوصيل بالاتفاق — حدد المبلغ المتفق عليه'
                              : 'Delivery fee is negotiable — enter the agreed amount',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                AppColors.secondaryColor.withOpacity(0.65),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: deliveryFeeController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'agreed_delivery_fee'.tr,
                    hintText: '0.00',
                    suffixText:
                        TranslationHelper.isArabic ? 'ر.س' : 'SAR',
                    prefixIcon: const Icon(
                        Icons.delivery_dining_rounded,
                        color: AppColors.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ],

              // ── Info for free / fixed delivery ──
              if (deliveryFeeType == 'free') ...[
                const SizedBox(height: 16),
                _deliveryTypeInfoChip(
                  icon: Icons.card_giftcard_rounded,
                  text: TranslationHelper.isArabic
                      ? 'التوصيل مجاني لهذا الطلب'
                      : 'Free delivery for this order',
                  color: Colors.green,
                ),
              ],
              if (deliveryFeeType == 'fixed') ...[
                const SizedBox(height: 16),
                _deliveryTypeInfoChip(
                  icon: Icons.price_check_rounded,
                  text: TranslationHelper.isArabic
                      ? 'رسوم التوصيل ثابتة حسب إعداداتك'
                      : 'Fixed delivery fee per your settings',
                  color: AppColors.secondaryColor,
                ),
              ],

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final enteredPrice =
                            double.tryParse(priceController.text);
                        final enteredDeliveryFee =
                            double.tryParse(deliveryFeeController.text);
                        onConfirm(enteredPrice, enteredDeliveryFee);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'confirm'.tr,
                        style: const TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _deliveryTypeInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

