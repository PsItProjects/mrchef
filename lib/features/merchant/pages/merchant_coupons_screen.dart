import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_coupon_controller.dart';
import 'package:mrsheaf/features/merchant/models/merchant_coupon_model.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_coupon_form_screen.dart';
import 'package:mrsheaf/features/merchant/services/merchant_coupon_service.dart';

class MerchantCouponsScreen extends StatelessWidget {
  const MerchantCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MerchantCouponService>()) {
      Get.put(MerchantCouponService());
    }
    if (!Get.isRegistered<MerchantCouponController>()) {
      Get.put(MerchantCouponController());
    }

    final controller = Get.find<MerchantCouponController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(controller)),
              SliverToBoxAdapter(child: _buildFilterChips(controller)),
              if (controller.filteredCoupons.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(controller),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCouponCard(
                        coupon: controller.filteredCoupons[index],
                        controller: controller,
                      ),
                      childCount: controller.filteredCoupons.length,
                    ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'add_coupon'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(MerchantCouponController controller) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryColor,
            Color(0xFF4A2B8A),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'discount_codes'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildStatCard(
                    icon: Icons.confirmation_number_outlined,
                    value: '${controller.totalCoupons}',
                    label: 'total'.tr,
                    valueColor: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    icon: Icons.check_circle_outline,
                    value: '${controller.activeCoupons}',
                    label: 'active'.tr,
                    valueColor: const Color(0xFF7CFFB3),
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    icon: Icons.timer_off_outlined,
                    value: '${controller.expiredCoupons}',
                    label: 'expired'.tr,
                    valueColor: const Color(0xFFFFB3B3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 11,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(MerchantCouponController controller) {
    final filters = [
      {'key': 'all', 'label': 'all'.tr, 'icon': Icons.grid_view_rounded},
      {'key': 'active', 'label': 'active'.tr, 'icon': Icons.check_circle_outline},
      {'key': 'inactive', 'label': 'inactive'.tr, 'icon': Icons.pause_circle_outline},
      {'key': 'expired', 'label': 'expired'.tr, 'icon': Icons.history_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: filters.map((filter) {
              final key = filter['key'] as String;
              final isSelected = controller.filterType.value == key;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: GestureDetector(
                  onTap: () => controller.setFilter(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.secondaryColor : AppColors.borderColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : AppColors.textMediumColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filter['label'] as String,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textMediumColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(MerchantCouponController controller) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 48,
              color: AppColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'no_coupons_yet'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 19,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'no_coupons_description'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              color: AppColors.textMediumColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Get.to(() => const MerchantCouponFormScreen());
                if (result == true) {
                  controller.loadCoupons();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'add_coupon'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard({
    required MerchantCouponModel coupon,
    required MerchantCouponController controller,
  }) {
    final status = _statusMeta(coupon.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [status.color, status.color.withOpacity(0.4)],
                ),
              ),
            ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDiscountSide(coupon),
                  Container(width: 1, color: AppColors.borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                coupon.localizedTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textDarkColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 7),
                        _buildCodeChip(coupon.code),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildInfoChip(
                              icon: coupon.appliesTo == 'all'
                                  ? Icons.storefront_outlined
                                  : Icons.category_outlined,
                              text: coupon.appliesTo == 'all'
                                  ? 'all_products'.tr
                                  : '${'specific_products'.tr} (${coupon.productsCount})',
                            ),
                            _buildInfoChip(
                              icon: Icons.people_alt_outlined,
                              text: '${'used'.tr}: ${coupon.usageText}',
                            ),
                          ],
                        ),
                        if (coupon.startsAt != null || coupon.expiresAt != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 13, color: AppColors.textMediumColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _formatDateRange(coupon.startsAt, coupon.expiresAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 11,
                                    color: AppColors.textMediumColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if ((coupon.maxUsesTotal ?? 0) > 0) ...[
                          const SizedBox(height: 8),
                          _buildUsageProgress(coupon),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor.withOpacity(0.5),
                border: Border(
                  top: BorderSide(color: AppColors.borderColor.withOpacity(0.7)),
                ),
              ),
              child: Row(
                children: [
                  Obx(() {
                    final current = controller.coupons.firstWhereOrNull((c) => c.id == coupon.id);
                    final isActive = current?.isActive ?? coupon.isActive;
                    return Row(
                      children: [
                        SizedBox(
                          height: 26,
                          child: FittedBox(
                            child: Switch(
                              value: isActive,
                              onChanged: (_) => controller.toggleActive(coupon.id),
                              activeColor: AppColors.successColor,
                            ),
                          ),
                        ),
                        Text(
                          isActive ? 'active'.tr : 'inactive'.tr,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: isActive ? AppColors.successColor : AppColors.textMediumColor,
                          ),
                        ),
                      ],
                    );
                  }),
                  const Spacer(),
                  _actionButton(
                    icon: Icons.edit_outlined,
                    color: AppColors.secondaryColor,
                    tooltip: 'edit'.tr,
                    onTap: () async {
                      final result = await Get.to(() => MerchantCouponFormScreen(couponId: coupon.id));
                      if (result == true) {
                        controller.loadCoupons();
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.errorColor,
                    tooltip: 'delete'.tr,
                    onTap: () => _confirmDelete(coupon, controller),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSide(MerchantCouponModel coupon) {
    final isPercentage = coupon.type == 'percentage';
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      color: AppColors.secondaryColor.withOpacity(0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            coupon.value.toStringAsFixed(0),
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: AppColors.secondaryColor,
              height: 1,
            ),
          ),
          Text(
            isPercentage ? '%' : 'SAR',
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: AppColors.secondaryColor,
            ),
          ),
          Text(
            'discount_off'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: AppColors.textMediumColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeChip(String code) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        Get.snackbar(
          'copied'.tr,
          code,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.secondaryColor,
          colorText: Colors.white,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.6,
                color: AppColors.secondaryColor,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.copy_rounded, size: 13, color: AppColors.secondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMediumColor),
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

  Widget _buildUsageProgress(MerchantCouponModel coupon) {
    final total = coupon.maxUsesTotal ?? 1;
    final used = coupon.usedCount;
    final progress = (used / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'used'.tr}: $used / $total',
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 10,
            color: AppColors.textMediumColor,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.85 ? AppColors.errorColor : AppColors.secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(_StatusMeta status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 3),
          Text(
            status.label,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  _StatusMeta _statusMeta(String status) {
    switch (status) {
      case 'active':
        return _StatusMeta(AppColors.successColor, Icons.check_circle_rounded, 'active'.tr);
      case 'inactive':
        return _StatusMeta(AppColors.textMediumColor, Icons.pause_circle_rounded, 'inactive'.tr);
      case 'scheduled':
        return _StatusMeta(Colors.blue, Icons.schedule_rounded, 'scheduled'.tr);
      case 'expired':
        return _StatusMeta(AppColors.errorColor, Icons.cancel_rounded, 'expired'.tr);
      case 'exhausted':
        return _StatusMeta(Colors.orange, Icons.do_not_disturb_on_rounded, 'exhausted'.tr);
      default:
        return _StatusMeta(AppColors.textMediumColor, Icons.info_outline_rounded, status);
    }
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

class _StatusMeta {
  final Color color;
  final IconData icon;
  final String label;

  _StatusMeta(this.color, this.icon, this.label);
}
