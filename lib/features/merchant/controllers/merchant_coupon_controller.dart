import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/merchant/models/merchant_coupon_model.dart';
import 'package:mrsheaf/features/merchant/services/merchant_coupon_service.dart';
import '../../../core/services/toast_service.dart';

/// Controller for managing merchant coupons
class MerchantCouponController extends GetxController {
  final MerchantCouponService _couponService = Get.find<MerchantCouponService>();

  // Observable lists
  final RxList<MerchantCouponModel> coupons = <MerchantCouponModel>[].obs;
  final RxList<MerchantCouponModel> filteredCoupons = <MerchantCouponModel>[].obs;

  // Products for picker
  final RxList<CouponProductModel> availableProducts = <CouponProductModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingProducts = false.obs;

  // Filter
  final RxString filterType = 'all'.obs; // all, active, inactive, expired

  // Stats
  int get totalCoupons => coupons.length;
  int get activeCoupons => coupons.where((c) => c.status == 'active').length;
  int get expiredCoupons => coupons.where((c) => c.status == 'expired').length;

  @override
  void onInit() {
    super.onInit();
    loadCoupons();
  }

  /// Load all coupons
  Future<void> loadCoupons() async {
    try {
      isLoading.value = true;
      final loaded = await _couponService.getCoupons();
      coupons.value = loaded;
      _applyFilter();
    } catch (e) {
      if (kDebugMode) print('❌ loadCoupons error: $e');
      ToastService.showError('error_loading_coupons'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Load available products for product picker
  Future<void> loadProducts() async {
    if (availableProducts.isNotEmpty) return; // Cache
    try {
      isLoadingProducts.value = true;
      final products = await _couponService.getProducts();
      availableProducts.value = products;
    } catch (e) {
      if (kDebugMode) print('❌ loadProducts error: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Create a new coupon
  Future<bool> createCoupon(Map<String, dynamic> data) async {
    try {
      isSubmitting.value = true;
      final coupon = await _couponService.createCoupon(data);
      if (coupon != null) {
        coupons.insert(0, coupon);
        _applyFilter();
        ToastService.showSuccess('coupon_created_successfully'.tr);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ createCoupon error: $e');
      final message = e.toString().replaceAll('Exception: ', '');
      ToastService.showError(message);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update an existing coupon
  Future<bool> updateCoupon(int id, Map<String, dynamic> data) async {
    try {
      isSubmitting.value = true;
      final updated = await _couponService.updateCoupon(id, data);
      if (updated != null) {
        final index = coupons.indexWhere((c) => c.id == id);
        if (index != -1) {
          coupons[index] = updated;
          _applyFilter();
        }
        ToastService.showSuccess('coupon_updated_successfully'.tr);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ updateCoupon error: $e');
      final message = e.toString().replaceAll('Exception: ', '');
      ToastService.showError(message);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete a coupon
  Future<bool> deleteCoupon(int id) async {
    try {
      final success = await _couponService.deleteCoupon(id);
      if (success) {
        coupons.removeWhere((c) => c.id == id);
        _applyFilter();
        ToastService.showSuccess('coupon_deleted_successfully'.tr);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ deleteCoupon error: $e');
      ToastService.showError('error_deleting_coupon'.tr);
      return false;
    }
  }

  /// Toggle coupon active/inactive
  Future<void> toggleActive(int id) async {
    try {
      final success = await _couponService.toggleActive(id);
      if (success) {
        final index = coupons.indexWhere((c) => c.id == id);
        if (index != -1) {
          final coupon = coupons[index];
          coupons[index] = coupon.copyWith(
            isActive: !coupon.isActive,
            status: !coupon.isActive ? 'active' : 'inactive',
          );
          _applyFilter();
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ toggleActive error: $e');
      ToastService.showError('error_toggling_coupon'.tr);
    }
  }

  /// Set filter type
  void setFilter(String type) {
    filterType.value = type;
    _applyFilter();
  }

  void _applyFilter() {
    switch (filterType.value) {
      case 'active':
        filteredCoupons.value = coupons.where((c) => c.status == 'active').toList();
        break;
      case 'inactive':
        filteredCoupons.value = coupons.where((c) => !c.isActive).toList();
        break;
      case 'expired':
        filteredCoupons.value = coupons.where((c) => c.status == 'expired' || c.status == 'exhausted').toList();
        break;
      default:
        filteredCoupons.value = List.from(coupons);
    }
  }
}
