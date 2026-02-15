import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/features/merchant/models/merchant_coupon_model.dart';

/// Service for managing merchant coupons/discount codes
class MerchantCouponService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  String get _basePath => '${ApiConstants.baseUrl}/merchant/coupons';

  /// Get all coupons for the merchant
  Future<List<MerchantCouponModel>> getCoupons({
    bool? isActive,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'paginated': false,
      };
      if (isActive != null) queryParams['is_active'] = isActive;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.get(
        _basePath,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => MerchantCouponModel.fromJson(e)).toList();
        }
        if (data is Map && data.containsKey('items')) {
          return (data['items'] as List).map((e) => MerchantCouponModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ MerchantCouponService.getCoupons error: $e');
      rethrow;
    }
  }

  /// Get a single coupon detail with products
  Future<MerchantCouponModel?> getCoupon(int id) async {
    try {
      final response = await _apiClient.get('$_basePath/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return MerchantCouponModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ MerchantCouponService.getCoupon error: $e');
      rethrow;
    }
  }

  /// Create a new coupon
  Future<MerchantCouponModel?> createCoupon(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(_basePath, data: data);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return MerchantCouponModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to create coupon');
    } on dio.DioException catch (e) {
      if (kDebugMode) print('❌ MerchantCouponService.createCoupon error: $e');
      final message = e.response?.data?['message'] ?? 'Failed to create coupon';
      throw Exception(message);
    } catch (e) {
      if (kDebugMode) print('❌ MerchantCouponService.createCoupon error: $e');
      rethrow;
    }
  }

  /// Update an existing coupon
  Future<MerchantCouponModel?> updateCoupon(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('$_basePath/$id', data: data);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return MerchantCouponModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to update coupon');
    } on dio.DioException catch (e) {
      if (kDebugMode) print('❌ MerchantCouponService.updateCoupon error: $e');
      final message = e.response?.data?['message'] ?? 'Failed to update coupon';
      throw Exception(message);
    } catch (e) {
      if (kDebugMode) print('❌ MerchantCouponService.updateCoupon error: $e');
      rethrow;
    }
  }

  /// Delete a coupon
  Future<bool> deleteCoupon(int id) async {
    try {
      final response = await _apiClient.delete('$_basePath/$id');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      if (kDebugMode) print('❌ MerchantCouponService.deleteCoupon error: $e');
      rethrow;
    }
  }

  /// Toggle coupon active status
  Future<bool> toggleActive(int id) async {
    try {
      final response = await _apiClient.patch('$_basePath/$id/toggle');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      if (kDebugMode) print('❌ MerchantCouponService.toggleActive error: $e');
      rethrow;
    }
  }

  /// Get merchant's products for the product picker
  Future<List<CouponProductModel>> getProducts() async {
    try {
      final response = await _apiClient.get('$_basePath/products');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => CouponProductModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ MerchantCouponService.getProducts error: $e');
      rethrow;
    }
  }
}
