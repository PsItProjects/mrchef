import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mrsheaf/core/network/api_client.dart';

class ProfileService extends GetxService {
  final ApiClient _apiClient = ApiClient.instance;
  
  // Cache key for customer profile
  static const String _cacheKey = 'customer_profile_cache';

  /// Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.get('/customer/profile');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Profile loaded successfully',
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      print('Error loading user profile: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  /// Update customer language preference
  Future<Map<String, dynamic>> updateLanguage(String language) async {
    try {
      final response = await _apiClient.put(
        '/customer/profile/language',
        data: {
          'preferred_language': language,
        },
      );

      if (response.data['success'] == true) {
        // Auto-refresh cache after language update
        await getProfile(forceRefresh: true);
        
        return {
          'success': true,
          'message': response.data['message'] ?? 'Language updated successfully',
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update language',
        };
      }
    } catch (e) {
      print('Error updating language: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  /// Get customer profile with caching support
  /// 
  /// If [forceRefresh] is false (default), returns cached data if available.
  /// If [forceRefresh] is true, always fetches fresh data from API and updates cache.
  Future<Map<String, dynamic>> getProfile({bool forceRefresh = false}) async {
    try {
      // Try to load from cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedData = await _getProfileFromCache();
        if (cachedData != null) {
          print('💾 CUSTOMER PROFILE SERVICE: Loaded from cache');
          return {
            'success': true,
            'data': cachedData,
          };
        }
      }

      // Load from API
      print('🌐 CUSTOMER PROFILE SERVICE: Loading from API (forceRefresh: $forceRefresh)');
      final response = await _apiClient.get('/customer/profile');

      if (response.data['success'] == true) {
        final profileData = response.data['data'];
        
        // Save to cache
        await _saveProfileToCache(profileData);
        
        return {
          'success': true,
          'data': profileData,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      print('Error getting profile: $e');
      
      // Try to return cached data on error
      final cachedData = await _getProfileFromCache();
      if (cachedData != null) {
        print('⚠️ CUSTOMER PROFILE SERVICE: API failed, using cached data');
        return {
          'success': true,
          'data': cachedData,
        };
      }
      
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }
  
  /// Save profile data to cache
  Future<void> _saveProfileToCache(Map<String, dynamic> profileData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(profileData);
      await prefs.setString(_cacheKey, jsonString);
      print('💾 CUSTOMER PROFILE SERVICE: Saved to cache');
    } catch (e) {
      print('❌ CUSTOMER PROFILE SERVICE: Failed to save cache - $e');
    }
  }
  
  /// Get profile data from cache
  Future<Map<String, dynamic>?> _getProfileFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      print('❌ CUSTOMER PROFILE SERVICE: Failed to load cache - $e');
      return null;
    }
  }
  
  /// Clear profile cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      print('🗑️ CUSTOMER PROFILE SERVICE: Cache cleared');
    } catch (e) {
      print('❌ CUSTOMER PROFILE SERVICE: Failed to clear cache - $e');
    }
  }
}
