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

  // Debounce timers
  Timer? _searchDebounceTimer;
  Timer? _autocompleteDebounceTimer;

  // Observable variables
  final RxString searchQuery = ''.obs;
  final RxString searchType = 'products'.obs; // 'products' or 'restaurants'
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxList<String> recentSearches = <String>[].obs;

  // Autocomplete
  final RxList<Map<String, dynamic>> autocompleteSuggestions = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingAutocomplete = false.obs;
  final RxBool showAutocomplete = false.obs;

  // Filters
  final Rx<SearchFilterModel> filters = SearchFilterModel().obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;

  // Lookup data for filters
  final RxList<Map<String, dynamic>> foodNationalities = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> governorates = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingLookups = false.obs;

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
    _loadLookups();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    _autocompleteDebounceTimer?.cancel();
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

  /// Load food nationalities and governorates for filters
  Future<void> _loadLookups() async {
    try {
      isLoadingLookups.value = true;

      final results = await Future.wait([
        _searchService.getFoodNationalities(),
        _searchService.getGovernorates(),
      ]);

      foodNationalities.value = results[0];
      governorates.value = results[1];
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Error loading lookups - $e');
      }
    } finally {
      isLoadingLookups.value = false;
    }
  }

  /// Load recent searches
  Future<void> _loadRecentSearches() async {
    final recent = await _searchService.getRecentSearches();
    recentSearches.value = recent;
  }

  /// Set search type (products or restaurants)
  void setSearchType(String type) {
    searchType.value = type;
    if (searchQuery.value.isNotEmpty || filters.value.hasActiveFilters) {
      search();
    }
  }

  /// Perform search
  Future<void> search({bool loadMore = false}) async {
    final query = searchQuery.value.trim();

    if (query.isEmpty && !filters.value.hasActiveFilters) {
      searchResults.clear();
      return;
    }

    // Hide autocomplete when searching
    showAutocomplete.value = false;

    try {
      if (loadMore) {
        currentPage.value++;
      } else {
        isLoading.value = true;
        isSearching.value = true;
        currentPage.value = 1;
        searchResults.clear();
      }

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

      if (filters.value.categoryId != null) {
        queryParams['category_id'] = filters.value.categoryId;
      }
      if (filters.value.minRating != null) {
        queryParams['min_rating'] = filters.value.minRating;
      }
      if (filters.value.governorateId != null) {
        queryParams['governorate_id'] = filters.value.governorateId;
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

        totalResults.value = restaurants.length;
        hasMore.value = false;
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

  /// Update search query with autocomplete + debounced search
  void updateSearchQuery(String query) {
    searchQuery.value = query;

    // Cancel previous timers
    _searchDebounceTimer?.cancel();
    _autocompleteDebounceTimer?.cancel();

    if (query.trim().isEmpty) {
      autocompleteSuggestions.clear();
      showAutocomplete.value = false;
      if (!filters.value.hasActiveFilters) {
        searchResults.clear();
      }
      return;
    }

    // Fetch autocomplete quickly (300ms)
    _autocompleteDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchAutocomplete(query);
    });

    // Do NOT auto-search while typing — user must press search button,
    // submit from keyboard, or select a suggestion. This keeps autocomplete visible.
  }

  /// Fetch autocomplete suggestions
  Future<void> _fetchAutocomplete(String query) async {
    if (query.trim().isEmpty) return;

    try {
      isLoadingAutocomplete.value = true;
      showAutocomplete.value = true;

      final suggestions = await _searchService.getAutocompleteSuggestions(query);
      autocompleteSuggestions.value = suggestions;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SEARCH: Autocomplete error - $e');
      }
    } finally {
      isLoadingAutocomplete.value = false;
    }
  }

  /// Select an autocomplete suggestion
  void selectSuggestion(Map<String, dynamic> suggestion) {
    final text = (suggestion['text'] ?? suggestion['name'] ?? '') as String;
    searchQuery.value = text;
    searchTextController.text = text;
    searchTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    showAutocomplete.value = false;
    autocompleteSuggestions.clear();
    search();
  }

  /// Hide autocomplete overlay
  void hideAutocomplete() {
    showAutocomplete.value = false;
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchTextController.clear();
    searchResults.clear();
    autocompleteSuggestions.clear();
    showAutocomplete.value = false;
    currentPage.value = 1;
  }

  /// Apply filters
  void applyFilters(SearchFilterModel newFilters) {
    filters.value = newFilters;
    search();
  }

  /// Clear filters
  void clearFilters() {
    filters.value = SearchFilterModel();
    if (searchQuery.value.isEmpty) {
      searchResults.clear();
    } else {
      search();
    }
  }

  /// Select recent search
  void selectRecentSearch(String query) {
    searchQuery.value = query;
    searchTextController.text = query;
    showAutocomplete.value = false;
    search();
  }

  /// Remove single recent search
  Future<void> removeRecentSearch(String query) async {
    await _searchService.removeRecentSearch(query);
    await _loadRecentSearches();
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    await _searchService.clearRecentSearches();
    recentSearches.clear();
  }

  /// Get display name for a food nationality by id
  String getFoodNationalityName(int id) {
    final item = foodNationalities.firstWhereOrNull(
      (n) => n['id'] == id,
    );
    if (item == null) return '';
    final name = item['name'];
    if (name is Map) return name['current'] ?? name['en'] ?? '';
    return name?.toString() ?? '';
  }

  /// Get display name for a governorate by id
  String getGovernorateName(int id) {
    final item = governorates.firstWhereOrNull(
      (g) => g['id'] == id,
    );
    if (item == null) return '';
    final name = item['name'];
    if (name is Map) return name['current'] ?? name['en'] ?? '';
    return name?.toString() ?? '';
  }
}
