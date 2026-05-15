import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/navigation/app_navigator.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/features/categories/widgets/filters_bottom_sheet.dart';
import 'package:mrsheaf/features/categories/services/category_service.dart';
import 'package:mrsheaf/features/categories/services/kitchen_service.dart';
import 'package:mrsheaf/core/services/language_service.dart';


class CategoriesController extends GetxController with GetSingleTickerProviderStateMixin {
  // Services
  final CategoryService _categoryService = CategoryService();
  final KitchenService _kitchenService = KitchenService();

  // Tab controller for Meals/Kitchens tabs
  late TabController tabController;

  // Observable variables
  final RxInt currentTabIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxList<CategoryModel> categoryChips = <CategoryModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<KitchenModel> kitchens = <KitchenModel>[].obs;
  final RxList<FilterModel> filters = <FilterModel>[].obs;
  final RxList<String> appliedFilters = <String>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingKitchens = false.obs;
  final RxInt selectedCategoryId = 1.obs; // معرف التصنيف المحدد حالياً
  
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });
    _loadCategoriesPageData();
    _initializeFilters(); // Only initialize filters, not products (already loaded in _loadCategoriesPageData)
    _setupLanguageListener();
  }

  /// Setup language change listener
  void _setupLanguageListener() {
    final languageService = LanguageService.instance;
    // Listen to language changes and reload data
    ever(languageService.currentLanguageRx, (String language) {
      if (kDebugMode) {
        print('🌐 CATEGORIES: Language changed to $language, reloading data...');
      }
      _loadCategoriesPageData();
    });
  }
  
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  /// Load categories page data from API
  Future<void> _loadCategoriesPageData() async {
    try {
      isLoadingCategories.value = true;
      isLoadingKitchens.value = true;

      if (kDebugMode) {
        print('🚀 STARTING TO LOAD CATEGORIES PAGE DATA...');
      }

      // Use the new combined endpoint
      final pageData = await _categoryService.getCategoriesWithProducts();

      // Load categories
      if (pageData['categories'] != null) {
        final List<CategoryModel> categories = pageData['categories'];
        if (kDebugMode) {
          print('🔍 PARSED CATEGORIES: ${categories.length} categories');
          for (var cat in categories) {
            print('   - ${cat.name} (ID: ${cat.id})');
          }
        }

        // تحديد التصنيف الأول كمحدد افتراضياً
        if (categories.isNotEmpty) {
          selectedCategoryId.value = categories.first.id;
          categories[0] = categories[0].copyWith(isSelected: true);
        }

        categoryChips.value = categories;
        if (kDebugMode) {
          print('✅ CATEGORY CHIPS UPDATED: ${categoryChips.length} chips');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ NO CATEGORIES DATA IN RESPONSE');
        }
      }

      // Load products
      if (pageData['products'] != null) {
        final List<ProductModel> productsList = pageData['products'];
        products.value = productsList;
        if (kDebugMode) {
          print('✅ PRODUCTS LOADED: ${products.length} products');
          for (var product in productsList.take(3)) {
            print('   - ${product.name} (CategoryID: ${product.categoryId})');
          }
        }
      } else {
        if (kDebugMode) {
          print('⚠️ NO PRODUCTS DATA IN RESPONSE');
        }
      }

      // Load kitchens (fallback to separate API if needed)
      await _loadKitchens();

      // Force UI update
      update();

      if (kDebugMode) {
        print('🎉 CATEGORIES PAGE DATA LOADED SUCCESSFULLY!');
        print('📊 Final State: ${categoryChips.length} categories, ${products.length} products, ${kitchens.length} kitchens');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading categories page data: $e');
        print('⚠️ NO FALLBACK DATA - App requires backend connection');
      }
      // NO FALLBACK DATA - App must work with backend only
    } finally {
      isLoadingCategories.value = false;
      isLoadingKitchens.value = false;
    }
  }

  /// Load categories from API
  Future<void> _loadCategories() async {
    try {
      isLoadingCategories.value = true;
      if (kDebugMode) {
        print('🎯 CATEGORIES CONTROLLER: Starting to load categories...');
      }

      final categories = await _categoryService.getCategories();
      if (kDebugMode) {
        print('🎯 CATEGORIES CONTROLLER: Received ${categories.length} categories');
      }

      // Set first category as selected by default
      if (categories.isNotEmpty) {
        categories[0] = categories[0].copyWith(isSelected: true);
        selectedCategoryId.value = categories[0].id; // تحديد معرف التصنيف المحدد
        if (kDebugMode) {
          print('🎯 CATEGORIES CONTROLLER: Selected first category: ${categories[0].name}');
        }
      }

      categoryChips.value = categories;
      if (kDebugMode) {
        print('🎯 CATEGORIES CONTROLLER: Categories loaded successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CATEGORIES CONTROLLER ERROR: $e');
        print('⚠️ NO FALLBACK DATA - App requires backend connection');
      }
      // NO FALLBACK DATA - App must work with backend only
    } finally {
      isLoadingCategories.value = false;
      if (kDebugMode) {
        print('🎯 CATEGORIES CONTROLLER: Loading finished. isLoading: ${isLoadingCategories.value}');
      }
    }
  }



  /// Load kitchens from API
  Future<void> _loadKitchens() async {
    try {
      isLoadingKitchens.value = true;
      final kitchensData = await _kitchenService.getKitchens();
      kitchens.value = kitchensData;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading kitchens: $e');
      }
      // NO FALLBACK DATA - App must work with backend only
    } finally {
      isLoadingKitchens.value = false;
    }
  }








  
  void _initializeFilters() {
    filters.value = [
      FilterModel(
        title: 'Category',
        options: [
          FilterOption(id: 1, name: 'Main Dishes', count: 29, isSelected: true),
          FilterOption(id: 2, name: 'Desserts', count: 9),
          FilterOption(id: 3, name: 'Beverages', count: 11),
          FilterOption(id: 4, name: 'Appetizers', count: 5),
          FilterOption(id: 5, name: 'Special Offers', count: 12),
        ],
      ),
      FilterModel(
        title: 'Sub-Category',
        options: [
          FilterOption(id: 6, name: 'Beef Burger', count: 29, isSelected: true),
          FilterOption(id: 7, name: 'Chicken Burger', count: 9),
          FilterOption(id: 8, name: 'Vegetarian Burger', count: 11),
        ],
      ),
      FilterModel(
        title: 'Price Range',
        options: [
          FilterOption(id: 9, name: 'أقل من 50 ر.س', count: 29, isSelected: true),
          FilterOption(id: 10, name: '50 - 100 ر.س', count: 9),
          FilterOption(id: 11, name: '100 - 250 ر.س', count: 11),
          FilterOption(id: 12, name: '250 - 500 ر.س', count: 5),
          FilterOption(id: 13, name: 'أكثر من 500 ر.س', count: 12),
        ],
      ),
      FilterModel(
        title: 'Features',
        options: [
          FilterOption(id: 14, name: 'Vegetarian', count: 29, isSelected: true),
          FilterOption(id: 15, name: 'Gluten Free', count: 15),
          FilterOption(id: 16, name: 'Organic', count: 8),
          FilterOption(id: 17, name: 'Vegan', count: 12),
        ],
      ),
      FilterModel(
        title: 'Rating',
        options: [
          FilterOption(id: 18, name: '5 Stars', count: 29, rating: 5.0, isSelected: true),
          FilterOption(id: 19, name: '4+ Stars', count: 45, rating: 4.0),
        ],
      ),
      FilterModel(
        title: 'Preparation Time',
        options: [
          FilterOption(id: 20, name: 'Less 15 min', count: 29, isSelected: true),
          FilterOption(id: 21, name: '15 min - 30 min', count: 9),
          FilterOption(id: 22, name: '30 min - 45 min', count: 11),
          FilterOption(id: 23, name: 'More than 45 min', count: 12),
        ],
      ),
      FilterModel(
        title: 'Special Offers',
        options: [
          FilterOption(id: 24, name: 'Main Dishes', count: 29, isSelected: true),
          FilterOption(id: 25, name: 'Desserts', count: 9),
          FilterOption(id: 26, name: 'Beverages', count: 11),
          FilterOption(id: 27, name: 'Appetizers', count: 5),
          FilterOption(id: 28, name: 'Special Offers', count: 12),
        ],
      ),
    ];
  }
  
  // Methods
  void changeTab(int index) {
    tabController.animateTo(index);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void onSearchTap() {
    Get.toNamed(AppRoutes.SEARCH);
  }



  /// Apply local filtering based on selected category
  void _applyLocalCategoryFilter(int categoryId) {
    if (kDebugMode) {
      print('🔍 APPLYING LOCAL FILTER: Category $categoryId');
    }

    // Store the selected category ID for filtering
    selectedCategoryId.value = categoryId;

    // Trigger the filteredProducts getter to update
    products.refresh();
  }

  /// Refresh categories from API
  Future<void> refreshCategories() async {
    try {
      await _loadCategories();
      if (kDebugMode) {
        print('✅ Categories refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing categories: $e');
      }
    }
  }

  /// Refresh kitchens from API
  Future<void> refreshKitchens() async {
    try {
      await _loadKitchens();
      if (kDebugMode) {
        print('✅ Kitchens refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing kitchens: $e');
      }
    }
  }

  /// Refresh categories page data from API
  Future<void> refreshCategoriesPageData() async {
    try {
      await _loadCategoriesPageData();
      if (kDebugMode) {
        print('✅ Categories page data refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing categories page data: $e');
      }
    }
  }
  
  void showFilters() {
    Get.bottomSheet(
      const FiltersBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
  
  void toggleFilterExpansion(int filterIndex) {
    final filter = filters[filterIndex];
    filters[filterIndex] = filter.copyWith(isExpanded: !filter.isExpanded);
    filters.refresh();
  }
  
  void toggleFilterOption(int filterIndex, int optionIndex) {
    final filter = filters[filterIndex];
    final option = filter.options[optionIndex];
    filter.options[optionIndex] = option.copyWith(isSelected: !option.isSelected);
    filters.refresh();
  }
  
  void clearFilters() {
    for (int i = 0; i < filters.length; i++) {
      final filter = filters[i];
      for (int j = 0; j < filter.options.length; j++) {
        filter.options[j] = filter.options[j].copyWith(isSelected: false);
      }
    }
    filters.refresh();
  }
  
  void applyFilters() {
    // Collect selected filters
    appliedFilters.clear();
    for (var filter in filters) {
      for (var option in filter.options) {
        if (option.isSelected) {
          appliedFilters.add(option.name);
        }
      }
    }

    AppNavigator.back(); // Close bottom sheet
    ToastService.showSuccess('${appliedFilters.length} filters applied');
  }

  void selectCategoryChip(int index) {
    // Deselect all chips
    for (int i = 0; i < categoryChips.length; i++) {
      categoryChips[i] = categoryChips[i].copyWith(isSelected: false);
    }
    // Select the tapped chip
    categoryChips[index] = categoryChips[index].copyWith(isSelected: true);
    categoryChips.refresh();

    // Apply local filtering for selected category
    final selectedCategory = categoryChips[index];
    _applyLocalCategoryFilter(selectedCategory.id);
  }

  void removeFilter(String filterName) {
    appliedFilters.remove(filterName);

    // Also update the filter options
    for (var filter in filters) {
      for (var option in filter.options) {
        if (option.name == filterName) {
          option = option.copyWith(isSelected: false);
        }
      }
    }
    filters.refresh();
  }

  // Getter for filtered products based on selected category and filters
  List<ProductModel> get filteredProducts {
    List<ProductModel> filtered = products.toList();

    if (kDebugMode) {
      print('🔍 FILTERING: ${products.length} total products for category ${selectedCategoryId.value}');
      for (var product in products.take(3)) {
        print('   - ${product.name} (CategoryID: ${product.categoryId})');
      }
    }

    // فلترة حسب التصنيف المحدد
    if (selectedCategoryId.value > 0) {
      filtered = filtered.where((product) =>
        product.categoryId == selectedCategoryId.value
      ).toList();
    }

    // يمكن إضافة فلاتر أخرى هنا لاحقاً
    // مثل السعر، التقييم، إلخ

    if (kDebugMode) {
      print('🔍 FILTERED PRODUCTS: ${filtered.length} products for category ${selectedCategoryId.value}');
      for (var product in filtered.take(3)) {
        print('🔍 PRODUCT: ${product.name} - Image: ${product.image}');
      }
    }

    return filtered;
  }
}
