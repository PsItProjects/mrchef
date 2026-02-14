import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_coupon_controller.dart';
import 'package:mrsheaf/features/merchant/models/merchant_coupon_model.dart';
import 'package:mrsheaf/features/merchant/services/merchant_coupon_service.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_coupon_form_screen.dart';

class MerchantCouponsScreen extends StatelessWidget {
  const MerchantCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register service and controller if not already registered
    if (!Get.isRegistered<MerchantCouponService>()) {
      Get.put(MerchantCouponService());
    }
    if (!Get.isRegistered<MerchantCouponController>()) {
      Get.put(MerchantCouponController());
    }

    final controller = Get.find<MerchantCouponController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      appBar: AppBar(
        title: Text(
          'discount_codes'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textDarkColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDarkColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadCoupons,
          color: AppColors.primaryColor,
          child: Column(
            children: [
              // Stats bar
              _buildStatsBar(controller),

              // Filter chips
              _buildFilterChips(controller),

              // Coupons list
              Expanded(
                child: controller.filteredCoupons.isEmpty
                    ? _buildEmptyState(controller)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: controller.filteredCoupons.length,
                        itemBuilder: (context, index) {
                          return _buildCouponCard(
                            controller.filteredCoupons[index],
                            controller,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.to(() => const MerchantCouponFormScreen());
          if (result == true) {
            controller.loadCoupons();
          }
        },
        backgroundColor: AppColors.secondaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'add_coupon'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(MerchantCouponController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildStatItem(
            'total'.tr,
            '${controller.totalCoupons}',
            AppColors.secondaryColor,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'active'.tr,
            '${controller.activeCoupons}',
            AppColors.successColor,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'expired'.tr,
            '${controller.expiredCoupons}',
            AppColors.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 12,
              color: AppColors.textMediumColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.borderColor,
    );
  }

  Widget _buildFilterChips(MerchantCouponController controller) {
    final filters = [
      {'key': 'all', 'label': 'all'.tr},
      {'key': 'active', 'label': 'active'.tr},
      {'key': 'inactive', 'label': 'inactive'.tr},
      {'key': 'expired', 'label': 'expired'.tr},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: filters.map((f) {
                final isSelected = controller.filterType.value == f['key'];
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(f['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.secondaryColor,
                    backgroundColor: AppColors.surfaceColor,
                    labelStyle: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppColors.textMediumColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) => controller.setFilter(f['key']!),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildEmptyState(MerchantCouponController controller) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.discount_outlined,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'no_coupons_yet'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textDarkColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'no_coupons_description'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  color: AppColors.textMediumColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponCard(MerchantCouponModel coupon, MerchantCouponController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Top section with code and status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Discount badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        coupon.displayValue,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and code
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon.localizedTitle,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textDarkColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: coupon.code));
                              Get.snackbar(
                                'copied'.tr,
                                coupon.code,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppColors.secondaryColor,
                                colorText: Colors.white,
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  coupon.code,
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppColors.primaryColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy, size: 14, color: AppColors.primaryColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    _buildStatusBadge(coupon.status),
                  ],
                ),

                const SizedBox(height: 12),

                // Info row
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.category_outlined,
                      coupon.appliesTo == 'all'
                          ? 'all_products'.tr
                          : '${'specific_products'.tr} (${coupon.productsCount})',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.people_outline,
                      '${'used'.tr}: ${coupon.usageText}',
                    ),
                  ],
                ),

                if (coupon.startsAt != null || coupon.expiresAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: AppColors.textMediumColor),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateRange(coupon.startsAt, coupon.expiresAt),
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12,
                          color: AppColors.textMediumColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Bottom actions
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderColor),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Toggle switch
                Obx(() {
                  final current = controller.coupons.firstWhereOrNull((c) => c.id == coupon.id);
                  return Switch(
                    value: current?.isActive ?? coupon.isActive,
                    onChanged: (_) => controller.toggleActive(coupon.id),
                    activeColor: AppColors.successColor,
                  );
                }),

                const Spacer(),

                // Edit button
                IconButton(
                  onPressed: () async {
                    final result = await Get.to(
                      () => MerchantCouponFormScreen(couponId: coupon.id),
                    );
                    if (result == true) {
                      controller.loadCoupons();
                    }
                  },
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.secondaryColor,
                  tooltip: 'edit'.tr,
                ),

                // Delete button
                IconButton(
                  onPressed: () => _confirmDelete(coupon, controller),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.errorColor,
                  tooltip: 'delete'.tr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'active':
        bgColor = AppColors.successColor.withOpacity(0.1);
        textColor = AppColors.successColor;
        label = 'active'.tr;
        break;
      case 'inactive':
        bgColor = AppColors.textMediumColor.withOpacity(0.1);
        textColor = AppColors.textMediumColor;
        label = 'inactive'.tr;
        break;
      case 'scheduled':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        label = 'scheduled'.tr;
        break;
      case 'expired':
        bgColor = AppColors.errorColor.withOpacity(0.1);
        textColor = AppColors.errorColor;
        label = 'expired'.tr;
        break;
      case 'exhausted':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        label = 'exhausted'.tr;
        break;
      default:
        bgColor = AppColors.textMediumColor.withOpacity(0.1);
        textColor = AppColors.textMediumColor;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMediumColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 11,
              color: AppColors.textMediumColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    }
    if (start != null) {
      return '${'from'.tr} ${_formatDate(start)}';
    }
    if (end != null) {
      return '${'until'.tr} ${_formatDate(end)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(MerchantCouponModel coupon, MerchantCouponController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_coupon'.tr),
        content: Text('${'delete_coupon_confirm'.tr}\n\n${coupon.code}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(color: AppColors.textMediumColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteCoupon(coupon.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'delete'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
