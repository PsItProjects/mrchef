import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/home/models/banner_model.dart';

class BannerService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get all active banners
  Future<List<BannerModel>> getBanners() async {
    try {
      if (kDebugMode) {
        print('🎨 BANNER SERVICE: Getting banners...');
      }

      final response = await _apiClient.get('/customer/banners');

      if (response.data['success'] == true) {
        if (kDebugMode) {
          print('✅ BANNER SERVICE: Banners retrieved successfully');
        }

        final List<dynamic> bannersData = response.data['data'] ?? [];
        
        if (kDebugMode) {
          print('🎨 BANNERS COUNT: ${bannersData.length}');
        }

        return bannersData.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get banners');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ BANNER SERVICE ERROR: $e');
      }
      rethrow;
    }
  }
}

