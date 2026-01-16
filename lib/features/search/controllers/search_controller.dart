import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/search/services/search_service.dart';
import 'package:mrsheaf/features/search/models/search_filter_model.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';

class SearchController extends GetxController {
  final SearchService _searchService = SearchService();
  final ApiClient _apiClient = ApiClient.instance;

  // Text editing controller for search input
  final TextEditingController searchTextController = TextEditingController();

  // Debounce timer for auto-search
  Timer? _debounceTimer;

  // Observable variables
  final RxString searchQuery = ''.obs;
  final RxString searchType = 'products'.obs; // 'products' or 'restaurants'
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxList<String> suggestions = <String>[].obs;

  // Filters
  final Rx<SearchFilterModel> filters = SearchFilterModel().obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalResults = 0.obs;
  final RxBool hasMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    _loadRecentSearches();
    _loadSuggestions();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  /// Load categories for filtering
  Future<void> _loadCategories() async {
    try {
      isLoadingCategories.value = true;
      
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}${ApiConstants.categoriesWithProducts}',
      );

      if (response.data['success'] == true) {
        final Map<String, dynamic> responseData = response.data['data'] ?? {};
        final List<dynamic> categoriesData = responseData['categories'] ?? [];
        
        categories.value = categoriesData
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error loading categories - $e');
      }
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Load recent searches
  Future<void> _loadRecentSearches() async {
    final recent = await _searchService.getRecentSearches();
    recentSearches.value = recent;
  }

  /// Load search suggestions
  Future<void> _loadSuggestions() async {
    final sug = await _searchService.getSearchSuggestions();
    suggestions.value = sug;
  }

  /// Set search type (products or restaurants)
  void setSearchType(String type) {
    searchType.value = type;
    // Re-search if there's a query or active filters
    if (searchQuery.value.isNotEmpty || filters.value.hasActiveFilters) {
      search();
    }
  }

  /// Perform search
  Future<void> search({bool loadMore = false}) async {
    final query = searchQuery.value.trim();

    // Allow search with filters even if query is empty
    if (query.isEmpty && !filters.value.hasActiveFilters) {
      searchResults.clear();
      return;
    }

    try {
      if (loadMore) {
        currentPage.value++;
      } else {
        isLoading.value = true;
        isSearching.value = true;
        currentPage.value = 1;
        searchResults.clear();
      }

      // Search based on type
      if (searchType.value == 'restaurants') {
        await _searchRestaurants(query, loadMore);
      } else {
        await _searchProducts(query, loadMore);
      }

      // Save to recent searches
      if (!loadMore && query.isNotEmpty) {
        await _searchService.saveRecentSearch(query);
        await _loadRecentSearches();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH ERROR: $e');
      }
    } finally {
      isLoading.value = false;
      isSearching.value = false;
    }
  }

  /// Search for products
  Future<void> _searchProducts(String query, bool loadMore) async {
    final result = await _searchService.searchProducts(
      query: query,
      filters: filters.value,
      page: currentPage.value,
      perPage: 20,
    );

    if (result['success'] == true) {
      final List<dynamic> products = result['products'] ?? [];

      if (loadMore) {
        searchResults.addAll(products.cast<Map<String, dynamic>>());
      } else {
        searchResults.value = products.cast<Map<String, dynamic>>();
      }

      // Update pagination info
      final pagination = result['pagination'] ?? {};
      totalPages.value = pagination['last_page'] ?? 1;
      totalResults.value = pagination['total'] ?? 0;
      hasMore.value = pagination['has_more'] ?? false;
    }
  }

  /// Search for restaurants
  Future<void> _searchRestaurants(String query, bool loadMore) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': currentPage.value,
        'per_page': 20,
      };

      if (query.isNotEmpty) {
        queryParams['search'] = query;
      }

      // Add filters
      if (filters.value.categoryId != null) {
        queryParams['category_id'] = filters.value.categoryId;
      }
      if (filters.value.minRating != null) {
        queryParams['min_rating'] = filters.value.minRating;
      }
      if (filters.value.sortBy != null) {
        queryParams['sort_by'] = filters.value.sortBy;
        queryParams['sort_order'] = filters.value.sortOrder ?? 'desc';
      }

      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}${ApiConstants.kitchens}',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> restaurants = response.data['data'] ?? [];

        if (loadMore) {
          searchResults.addAll(restaurants.cast<Map<String, dynamic>>());
        } else {
          searchResults.value = restaurants.cast<Map<String, dynamic>>();
        }

        // Update pagination info
        totalResults.value = restaurants.length;
        hasMore.value = false; // Adjust based on API response
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error - $e');
      }
    } finally {
      isLoading.value = false;
      isSearching.value = false;
    }
  }

  /// Update search query with auto-search debounce
  void updateSearchQuery(String query) {
    searchQuery.value = query;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // If query is empty but filters are active, keep results
    if (query.trim().isEmpty && !filters.value.hasActiveFilters) {
      searchResults.clear();
      return;
    }

    // Start new timer for auto-search after 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      search();
    });
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchTextController.clear();
    searchResults.clear();
    currentPage.value = 1;
  }

  /// Apply filters
  void applyFilters(SearchFilterModel newFilters) {
    filters.value = newFilters;
    // Always search when filters are applied, even if query is empty
    search();
  }

  /// Clear filters
  void clearFilters() {
    filters.value = SearchFilterModel();
    // Clear results if no search query
    if (searchQuery.value.isEmpty) {
      searchResults.clear();
    } else {
      search();
    }
  }

  /// Update specific filter
  void updateFilter({
    int? categoryId,
    int? restaurantId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? isVegetarian,
    bool? isSpicy,
    bool? isFeatured,
    String? sortBy,
    String? sortOrder,
  }) {
    filters.value = filters.value.copyWith(
      categoryId: categoryId,
      restaurantId: restaurantId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      isVegetarian: isVegetarian,
      isSpicy: isSpicy,
      isFeatured: isFeatured,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Select recent search
  void selectRecentSearch(String query) {
    searchQuery.value = query;
    searchTextController.text = query;
    search();
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    await _searchService.clearRecentSearches();
    recentSearches.clear();
  }
}
