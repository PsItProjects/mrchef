import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/features/search/models/search_filter_model.dart';

class SearchService {
  final ApiClient _apiClient = ApiClient.instance;
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 15;

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

      final Map<String, dynamic> queryParams = {
        'search': query,
        'page': page,
        'per_page': perPage,
      };

      if (filters != null) {
        queryParams.addAll(filters.toJson());
      }

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

  /// Get autocomplete suggestions from backend
  Future<List<Map<String, dynamic>>> getAutocompleteSuggestions(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final response = await _apiClient.get(
        ApiConstants.searchSuggestions,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dynamic rawData = response.data['data'];
        // API may return {suggestions: [...]} or directly [...]
        List<dynamic> suggestions;
        if (rawData is Map) {
          suggestions = rawData['suggestions'] ?? [];
        } else if (rawData is List) {
          suggestions = rawData;
        } else {
          suggestions = [];
        }
        return suggestions
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error getting autocomplete - $e');
      }
      return [];
    }
  }

  /// Get food nationalities from lookup API
  Future<List<Map<String, dynamic>>> getFoodNationalities() async {
    try {
      final response = await _apiClient.get(ApiConstants.foodNationalities);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error getting food nationalities - $e');
      }
      return [];
    }
  }

  /// Get governorates from lookup API
  Future<List<Map<String, dynamic>>> getGovernorates() async {
    try {
      final response = await _apiClient.get(ApiConstants.governorates);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error getting governorates - $e');
      }
      return [];
    }
  }

  /// Get recent searches from SharedPreferences
  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentSearchesKey) ?? [];
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
      if (query.trim().isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];

      // Remove if already exists (to move to top)
      searches.remove(query.trim());
      // Insert at beginning
      searches.insert(0, query.trim());
      // Keep only max items
      if (searches.length > _maxRecentSearches) {
        searches.removeRange(_maxRecentSearches, searches.length);
      }

      await prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error saving recent search - $e');
      }
    }
  }

  /// Remove a single recent search
  Future<void> removeRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      searches.remove(query);
      await prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error removing recent search - $e');
      }
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error clearing recent searches - $e');
      }
    }
  }
}

