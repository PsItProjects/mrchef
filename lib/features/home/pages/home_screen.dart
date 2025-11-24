import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';
import 'package:mrsheaf/features/home/widgets/home_header.dart';
import 'package:mrsheaf/features/home/widgets/search_bar_widget.dart';
import 'package:mrsheaf/features/home/widgets/category_filter.dart';
import 'package:mrsheaf/features/home/widgets/featured_banner.dart';
import 'package:mrsheaf/features/home/widgets/section_header.dart';
import 'package:mrsheaf/features/home/widgets/kitchen_card.dart';
import 'package:mrsheaf/features/home/widgets/product_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Background color from Figma
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Header
              const HomeHeader(),
              
              const SizedBox(height: 24),
              
              // Search bar
              const SearchBarWidget(),
              
              const SizedBox(height: 24),
              
              // Category filter
              const CategoryFilter(),
              
              const SizedBox(height: 24),
              
              // Featured banner
              const FeaturedBanner(),
              
              const SizedBox(height: 24),
              
              // Kitchens section
               SectionHeader(
                title: 'restaurants'.tr,
                section: 'restaurants',
              ),
              
              const SizedBox(height: 16),
              
              // Restaurants horizontal list (filtered)
              SizedBox(
                height: 223,
                child: Obx(() {
                  // Use filtered restaurants if available, otherwise fallback to original data
                  final restaurantsToShow = controller.filteredRestaurants.isNotEmpty
                      ? controller.filteredRestaurants
                      : (controller.homeRestaurants.isNotEmpty
                          ? controller.homeRestaurants
                          : controller.kitchens);

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: restaurantsToShow.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurantsToShow[index];

                      // Parse restaurant name based on language
                      String restaurantName = 'Restaurant';
                      if (restaurant['name'] != null) {
                        final name = restaurant['name'];
                        if (name is Map) {
                          // Get current language from controller or use Arabic as default
                          final currentLang = Get.locale?.languageCode ?? 'ar';
                          restaurantName = name[currentLang]?.toString() ??
                                         name['ar']?.toString() ??
                                         name['en']?.toString() ??
                                         'Restaurant';
                        } else if (name is String) {
                          restaurantName = name;
                        }
                      } else if (restaurant['business_name'] != null) {
                        final businessName = restaurant['business_name'];
                        if (businessName is Map) {
                          final currentLang = Get.locale?.languageCode ?? 'ar';
                          restaurantName = businessName[currentLang]?.toString() ??
                                         businessName['ar']?.toString() ??
                                         businessName['en']?.toString() ??
                                         'Restaurant';
                        } else if (businessName is String) {
                          restaurantName = businessName;
                        }
                      }

                      // Parse logo URL
                      String logoUrl = '';
                      if (restaurant['logo'] != null && restaurant['logo'] != 'null') {
                        logoUrl = restaurant['logo'].toString();
                        // Convert relative path to full URL
                        if (!logoUrl.startsWith('http')) {
                          logoUrl = 'https://mr-shife-backend-main-ygodva.laravel.cloud/storage/$logoUrl';
                        }
                      }

                      // Create restaurant data in kitchen format
                      final restaurantAsKitchen = {
                        'id': restaurant['id'] ?? index,
                        'name': restaurantName,
                        'image': logoUrl.isNotEmpty ? logoUrl : 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
                        'isActive': true,
                      };

                      return KitchenCard(
                        kitchen: restaurantAsKitchen,
                      );
                    },
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Best seller section
              const SectionHeader(
                title: 'Best seller',
                section: 'bestSeller',
              ),
              
              const SizedBox(height: 16),
              
              // Best seller horizontal list (filtered)
              SizedBox(
                height: 240,
                child: Obx(() {
                  // When category is selected, show best rated products from that category
                  // When "Popular" is selected, show best seller products
                  final productsToShow = controller.selectedCategoryId.value != 0
                      ? controller.filteredProductsByRating.toList() // Show products sorted by rating
                      : controller.bestSellerProducts;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: productsToShow.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: productsToShow[index],
                        section: 'bestSeller',
                      );
                    },
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Back again section
              const SectionHeader(
                title: 'Back again',
                section: 'backAgain',
              ),
              
              const SizedBox(height: 16),
              
              // Back again horizontal list (filtered)
              SizedBox(
                height: 240,
                child: Obx(() {
                  // When category is selected, show latest products from that category
                  // When "Popular" is selected, show back again products
                  final productsToShow = controller.selectedCategoryId.value != 0
                      ? controller.filteredProducts.toList() // Show all filtered products (already sorted by latest)
                      : controller.backAgainProducts;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: productsToShow.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: productsToShow[index],
                        section: 'backAgain',
                      );
                    },
                  );
                }),
              ),
              
              const SizedBox(height: 100), // Extra space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}
