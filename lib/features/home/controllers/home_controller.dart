import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import '../../categories/services/category_service.dart';
import '../../categories/models/category_model.dart';

class HomeController extends GetxController {
  // Services
  final CategoryService _categoryService = Get.find<CategoryService>();

  // Observable variables for home screen state
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt currentBannerIndex = 0.obs;
  final RxBool isLoadingCategories = false.obs;

  // Categories for the filter section
  final RxList<String> categories = <String>[
    'Popular',
    'Vegan',
    'Natural',
    'Dermatologically'
  ].obs;

  // Backend categories
  final RxList<BackendCategoryModel> backendCategories = <BackendCategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadHomeCategories();
  }

  // Load categories for home screen filter
  Future<void> _loadHomeCategories() async {
    try {
      isLoadingCategories.value = true;

      final response = await _categoryService.getHomeCategories();

      if (response.isSuccess && response.data != null) {
        backendCategories.value = response.data!;

        // Update categories list for filter
        final categoryNames = response.data!
            .where((cat) => cat.isActive)
            .map((cat) => cat.name)
            .toList();

        if (categoryNames.isNotEmpty) {
          categories.assignAll(categoryNames);
        }
      }
    } catch (e) {
      print('Error loading home categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Kitchen data
  final RxList<Map<String, dynamic>> kitchens = <Map<String, dynamic>>[
    {
      'id': 1,
      'name': 'Master chef',
      'image': 'assets/kitchen_1.png',
      'isActive': true,
    },
    {
      'id': 2,
      'name': 'Master chef',
      'image': 'assets/kitchen_2.png',
      'isActive': true,
    },
    {
      'id': 3,
      'name': 'Master chef',
      'image': 'assets/kitchen_3.png',
      'isActive': true,
    },
  ].obs;
  
  // Best seller products
  final RxList<Map<String, dynamic>> bestSellerProducts = <Map<String, dynamic>>[
    {
      'id': 1,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
    {
      'id': 2,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
    {
      'id': 3,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
  ].obs;
  
  // Back again products (same structure as best seller for now)
  final RxList<Map<String, dynamic>> backAgainProducts = <Map<String, dynamic>>[
    {
      'id': 4,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
    {
      'id': 5,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
    {
      'id': 6,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
  ].obs;
  
  // Methods
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }
  
  void updateBannerIndex(int index) {
    currentBannerIndex.value = index;
  }
  
  void toggleFavorite(int productId, String section) {
    if (section == 'bestSeller') {
      final index = bestSellerProducts.indexWhere((product) => product['id'] == productId);
      if (index != -1) {
        bestSellerProducts[index]['isFavorite'] = !bestSellerProducts[index]['isFavorite'];
        bestSellerProducts.refresh();
      }
    } else if (section == 'backAgain') {
      final index = backAgainProducts.indexWhere((product) => product['id'] == productId);
      if (index != -1) {
        backAgainProducts[index]['isFavorite'] = !backAgainProducts[index]['isFavorite'];
        backAgainProducts.refresh();
      }
    }
  }
  
  void addToCart(int productId) {
    final cartController = Get.find<CartController>();

    // Find the product from either bestSeller or backAgain lists
    Map<String, dynamic>? productData;

    // Check in best seller products
    final bestSellerIndex = bestSellerProducts.indexWhere((product) => product['id'] == productId);
    if (bestSellerIndex != -1) {
      productData = bestSellerProducts[bestSellerIndex];
    } else {
      // Check in back again products
      final backAgainIndex = backAgainProducts.indexWhere((product) => product['id'] == productId);
      if (backAgainIndex != -1) {
        productData = backAgainProducts[backAgainIndex];
      }
    }

    if (productData != null) {
      // Convert to ProductModel
      final product = ProductModel(
        id: productData['id'],
        name: productData['name'],
        description: productData['description'] ?? '',
        price: productData['price'].toDouble(),
        originalPrice: productData['originalPrice']?.toDouble(),
        image: productData['image'],
        rating: productData['rating']?.toDouble() ?? 0.0,
        reviewCount: productData['reviewCount'] ?? 0,
        productCode: '#${productData['id'].toString().padLeft(8, '0')}',
        sizes: ['L', 'M', 'S'],
        images: [productData['image']],
        additionalOptions: [],
      );

      cartController.addToCart(
        product: product,
        size: 'M', // Default size
        quantity: 1, // Default quantity
        additionalOptions: [],
      );
    }
  }
  
  void onSearchTap() {
    // TODO: Navigate to search screen
    Get.snackbar(
      'Search',
      'Search functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void onNotificationTap() {
    // TODO: Navigate to notifications screen
    Get.snackbar(
      'Notifications',
      'Notifications screen coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void onChatTap() {
    // TODO: Navigate to chat screen
    Get.snackbar(
      'Chat',
      'Chat functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void onSeeAllTap(String section) {
    // TODO: Navigate to respective section screen
    Get.snackbar(
      'See All',
      '$section - See all functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToProductDetails() {
    Get.toNamed(AppRoutes.PRODUCT_DETAILS);
  }
}
