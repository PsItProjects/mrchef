import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/features/search/models/search_filter_model.dart';

class SearchService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Search products with filters
  Future<Map<String, dynamic>> searchProducts({
    required String query,
    SearchFilterModel? filters,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 SEARCH: Searching for "$query" with filters: ${filters?.toJson()}');
      }

      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'search': query,
        'page': page,
        'per_page': perPage,
      };

      // Add filters if provided
      if (filters != null) {
        queryParams.addAll(filters.toJson());
      }

      // Use the filtered-products endpoint
      final response = await _apiClient.get(
        ApiConstants.filteredProducts,
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        print('🔍 SEARCH: Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        
        if (kDebugMode) {
          print('✅ SEARCH: Found ${data['pagination']['total']} products');
        }

        return {
          'success': true,
          'products': data['products'] ?? [],
          'pagination': data['pagination'] ?? {},
          'filters_applied': data['filters_applied'] ?? {},
        };
      } else {
        if (kDebugMode) {
          print('⚠️ SEARCH: Failed - ${response.data['message']}');
        }
        return {
          'success': false,
          'products': [],
          'pagination': {},
          'message': response.data['message'] ?? 'Search failed',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error - $e');
      }
      return {
        'success': false,
        'products': [],
        'pagination': {},
        'message': 'An error occurred while searching',
      };
    }
  }

  /// Get search suggestions (popular searches, categories, etc.)
  Future<List<String>> getSearchSuggestions() async {
    try {
      // TODO: Implement API call for search suggestions
      // For now, return empty list
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error getting suggestions - $e');
      }
      return [];
    }
  }

  /// Get recent searches from local storage
  Future<List<String>> getRecentSearches() async {
    try {
      // TODO: Implement local storage for recent searches
      // For now, return empty list
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error getting recent searches - $e');
      }
      return [];
    }
  }

  /// Save search to recent searches
  Future<void> saveRecentSearch(String query) async {
    try {
      // TODO: Implement local storage for recent searches
      if (kDebugMode) {
        print('💾 SEARCH: Saving recent search: $query');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error saving recent search - $e');
      }
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      // TODO: Implement local storage clear
      if (kDebugMode) {
        print('🗑️ SEARCH: Clearing recent searches');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error clearing recent searches - $e');
      }
    }
  }
}

