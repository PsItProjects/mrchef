import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mrsheaf/features/categories/models/category_model.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';

class KitchenService {
  /// Get all kitchens/restaurants
  Future<List<KitchenModel>> getKitchens() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.kitchens}'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> kitchensData = jsonResponse['data'];
          return kitchensData
              .map((kitchen) => KitchenModel.fromJson(kitchen))
              .toList();
        } else {
          throw Exception('Failed to load kitchens: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load kitchens: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading kitchens: $e');
    }
  }

  /// Get kitchen details by ID
  Future<KitchenModel> getKitchenById(int kitchenId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.kitchens}/$kitchenId'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          return KitchenModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception('Failed to load kitchen: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load kitchen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading kitchen: $e');
    }
  }
}
