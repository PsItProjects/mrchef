import 'package:get/get.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/core/network/api_client.dart';

class KitchenService extends GetxService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get all kitchens/restaurants
  Future<List<KitchenModel>> getKitchens() async {
    try {
      final response = await _apiClient.get(ApiConstants.kitchens);

      if (response.data['success'] == true) {
        final List<dynamic> kitchensData = response.data['data'];
        return kitchensData
            .map((kitchen) => KitchenModel.fromJson(kitchen))
            .toList();
      } else {
        throw Exception('Failed to load kitchens: ${response.data['message']}');
      }
    } catch (e) {
      print('Error loading kitchens: $e');
      throw Exception('Error loading kitchens: $e');
    }
  }

  /// Get kitchen details by ID
  Future<KitchenModel> getKitchenById(int kitchenId) async {
    try {
      final response = await _apiClient.get(ApiConstants.kitchenDetails(kitchenId));

      if (response.data['success'] == true) {
        return KitchenModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load kitchen: ${response.data['message']}');
      }
    } catch (e) {
      print('Error loading kitchen: $e');
      throw Exception('Error loading kitchen: $e');
    }
  }

  /// Add kitchen to favorites
  Future<Map<String, dynamic>> addToFavorites(int kitchenId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addKitchenToFavorites(kitchenId),
      );

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'Operation completed',
      };
    } catch (e) {
      print('Error adding kitchen to favorites: $e');
      return {
        'success': false,
        'message': 'Failed to add to favorites',
      };
    }
  }

  /// Remove kitchen from favorites
  Future<Map<String, dynamic>> removeFromFavorites(int kitchenId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.removeKitchenFromFavorites(kitchenId),
      );

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'Operation completed',
      };
    } catch (e) {
      print('Error removing kitchen from favorites: $e');
      return {
        'success': false,
        'message': 'Failed to remove from favorites',
      };
    }
  }
}
