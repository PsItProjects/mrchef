import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/features/categories/widgets/filters_bottom_sheet.dart';

class CategoriesController extends GetxController with GetSingleTickerProviderStateMixin {
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
  
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });
    _initializeData();
  }
  
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
  
  void _initializeData() {
    // Initialize category chips (horizontal filter)
    categoryChips.value = [
      CategoryModel(id: 1, name: 'Popular', icon: 'popular', itemCount: 29, isSelected: true),
      CategoryModel(id: 2, name: 'Dessert', icon: 'dessert', itemCount: 9),
      CategoryModel(id: 3, name: 'Pastries', icon: 'pastries', itemCount: 11),
      CategoryModel(id: 4, name: 'Drink', icon: 'drink', itemCount: 5),
      CategoryModel(id: 5, name: 'Pickles', icon: 'pickles', itemCount: 12),
      CategoryModel(id: 6, name: 'Pizza', icon: 'pizza', itemCount: 8),
    ];

    // Initialize products
    products.value = [
      ProductModel(
        id: 1,
        name: 'Vegetable pizza',
        description: 'Tomato sauce, mozzarella cheese and a mix of fresh vegetables',
        price: 39.99,
        originalPrice: 70.00,
        image: 'assets/images/pizza_main.png',
        rating: 4.8,
        reviewCount: 205,
        productCode: '#G7432642',
        sizes: ['L', 'M', 'S'],
        images: ['assets/images/pizza_main.png'],
        additionalOptions: [],
      ),
      ProductModel(
        id: 2,
        name: 'Beef Burger',
        description: 'Juicy beef patty with fresh vegetables and special sauce',
        price: 25.99,
        originalPrice: 35.00,
        image: 'assets/images/burger.png',
        rating: 4.6,
        reviewCount: 150,
        productCode: '#B7432643',
        sizes: ['L', 'M', 'S'],
        images: ['assets/images/burger.png'],
        additionalOptions: [],
      ),
      ProductModel(
        id: 3,
        name: 'Chicken Sandwich',
        description: 'Grilled chicken with fresh lettuce and tomatoes',
        price: 18.99,
        originalPrice: 25.00,
        image: 'assets/images/pizza_main.png',
        rating: 4.5,
        reviewCount: 89,
        productCode: '#C7432644',
        sizes: ['L', 'M', 'S'],
        images: ['assets/images/pizza_main.png'],
        additionalOptions: [],
      ),
      ProductModel(
        id: 4,
        name: 'Caesar Salad',
        description: 'Fresh romaine lettuce with caesar dressing and croutons',
        price: 15.99,
        originalPrice: 22.00,
        image: 'assets/images/pizza_main.png',
        rating: 4.7,
        reviewCount: 120,
        productCode: '#S7432645',
        sizes: ['L', 'M', 'S'],
        images: ['assets/images/pizza_main.png'],
        additionalOptions: [],
      ),
      ProductModel(
        id: 5,
        name: 'Chocolate Cake',
        description: 'Rich chocolate cake with chocolate frosting',
        price: 12.99,
        originalPrice: 18.00,
        image: 'assets/images/pizza_main.png',
        rating: 4.9,
        reviewCount: 200,
        productCode: '#D7432646',
        sizes: ['L', 'M', 'S'],
        images: ['assets/images/pizza_main.png'],
        additionalOptions: [],
      ),
      ProductModel(
        id: 6,
        name: 'Fresh Juice',
        description: 'Freshly squeezed orange juice',
        price: 8.99,
        originalPrice: 12.00,
        image: 'assets/images/pizza_main.png',
        rating: 4.4,
        reviewCount: 75,
        productCode: '#J7432647',
        sizes: ['L', 'M', 'S'],
        images: ['assets/images/pizza_main.png'],
        additionalOptions: [],
      ),
    ];
    
    // Initialize kitchens
    kitchens.value = [
      KitchenModel(
        id: 1,
        name: 'Master chef',
        image: 'assets/images/kitchen_food.png',
        rating: 4.8,
        reviewCount: 205,
        description: 'Authentic Mediterranean cuisine',
        specialties: ['Pizza', 'Pasta', 'Salads'],
      ),
      KitchenModel(
        id: 2,
        name: 'Master chef',
        image: 'assets/images/kitchen_food.png',
        rating: 4.6,
        reviewCount: 150,
        description: 'Traditional Italian kitchen',
        specialties: ['Burgers', 'Fries', 'Shakes'],
      ),
      KitchenModel(
        id: 3,
        name: 'Master chef',
        image: 'assets/images/kitchen_food.png',
        rating: 4.9,
        reviewCount: 320,
        description: 'Asian fusion cuisine',
        specialties: ['Sushi', 'Ramen', 'Tempura'],
      ),
      KitchenModel(
        id: 4,
        name: 'Master chef',
        image: 'assets/images/kitchen_food.png',
        rating: 4.7,
        reviewCount: 180,
        description: 'Mexican street food',
        specialties: ['Tacos', 'Burritos', 'Quesadillas'],
      ),
      KitchenModel(
        id: 5,
        name: 'Master chef',
        image: 'assets/images/kitchen_food.png',
        rating: 4.5,
        reviewCount: 95,
        description: 'French bistro classics',
        specialties: ['Croissants', 'Soups', 'Wine'],
      ),
      KitchenModel(
        id: 6,
        name: 'Master chef',
        image: 'assets/images/kitchen_food.png',
        rating: 4.8,
        reviewCount: 240,
        description: 'Indian spice house',
        specialties: ['Curry', 'Naan', 'Biryani'],
      ),
    ];
    
    // Initialize filters
    _initializeFilters();
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
          FilterOption(id: 9, name: 'Less 50\$', count: 29, isSelected: true),
          FilterOption(id: 10, name: '\$50 - \$100', count: 9),
          FilterOption(id: 11, name: '\$100 - \$250', count: 11),
          FilterOption(id: 12, name: '\$250 - \$500', count: 5),
          FilterOption(id: 13, name: 'More than \$500', count: 12),
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

    Get.back(); // Close bottom sheet
    Get.snackbar(
      'Filters Applied',
      '${appliedFilters.length} filters applied',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void selectCategoryChip(int index) {
    // Deselect all chips
    for (int i = 0; i < categoryChips.length; i++) {
      categoryChips[i] = categoryChips[i].copyWith(isSelected: false);
    }
    // Select the tapped chip
    categoryChips[index] = categoryChips[index].copyWith(isSelected: true);
    categoryChips.refresh();
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
    // For now, return all products. In a real app, this would filter based on
    // selected category chip and applied filters
    return products;
  }
}
