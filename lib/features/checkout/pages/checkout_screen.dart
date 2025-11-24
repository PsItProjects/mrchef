import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/checkout/controllers/checkout_controller.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';

class CheckoutScreen extends GetView<CheckoutController> {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title:  Text(
          'checkout'.tr,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF262626)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isCreatingOrder.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cart Summary
                      _buildSectionTitle('order_summary'.tr),
                      const SizedBox(height: 12),
                      _buildCartSummary(),
                      
                      const SizedBox(height: 24),
                      
                      // Address Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('delivery_address'.tr),
                          TextButton.icon(
                            onPressed: controller.addNewAddress,
                            icon: const Icon(Icons.add, size: 18, color: AppColors.primaryColor),
                            label:  Text(
                              'add_address'.tr,
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildAddressList(),
                    ],
                  ),
                ),
              ),
              
              // Bottom Section
              _buildBottomSection(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: Color(0xFF262626),
      ),
    );
  }

  Widget _buildCartSummary() {
    final cartController = controller.cartController;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('quantity'.tr, '${cartController.totalItemsCount}'),
          const Divider(height: 24),
          _buildSummaryRow('subtotal'.tr, '${cartController.subtotal.toStringAsFixed(2)} ${'currency'.tr}'),
          const SizedBox(height: 8),
          _buildSummaryRow('delivery_fee'.tr, '${cartController.deliveryFee.toStringAsFixed(2)} ${'currency'.tr}'),
          if (cartController.serviceFee > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('service_fee'.tr, '${cartController.serviceFee.toStringAsFixed(2)} ${'currency'.tr}'),
          ],
          const Divider(height: 24),
          _buildSummaryRow(
            'total'.tr,
            '${cartController.totalAmount.toStringAsFixed(2)} ${'currency'.tr}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? const Color(0xFF262626) : const Color(0xFF5E5E5E),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? AppColors.primaryColor : const Color(0xFF262626),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressList() {
    return Obx(() {
      if (controller.isLoadingAddresses.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.addresses.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              const Icon(Icons.location_off_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
               Text(
                'no_saved_addresses'.tr,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.addNewAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('add_new_address'.tr),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final address = controller.addresses[index];
          return Obx(() {
            final isSelected = controller.selectedAddress.value?.id == address.id;
            return InkWell(
              onTap: () => controller.selectAddress(address),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Radio<int>(
                      value: address.id!,
                      groupValue: controller.selectedAddress.value?.id,
                      onChanged: (val) => controller.selectAddress(address),
                      activeColor: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getAddressIcon(address.type),
                                size: 20,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                address.typeDisplayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (address.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child:  Text(
                                    'default_address'.tr,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address.fullAddress,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }

  IconData _getAddressIcon(AddressType? type) {
    switch (type) {
      case AddressType.home:
        return Icons.home_outlined;
      case AddressType.work:
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                 Expanded(
                  child: Text(
                    'chat_disclaimer'.tr,
                    style: TextStyle(
                      color: Color(0xFF262626),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Create Order Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: controller.createOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:  Text(
                'create_order'.tr,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
