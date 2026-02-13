import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';
import 'package:mrsheaf/features/home/widgets/home_header.dart';
import 'package:mrsheaf/features/home/widgets/search_bar_widget.dart';
import 'package:mrsheaf/features/home/widgets/category_filter.dart';
import 'package:mrsheaf/features/home/widgets/banner_slider.dart';
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

              // Banner slider
              Obx(() {
                if (controller.isLoadingBanners.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  );
                }

                if (controller.banners.isEmpty) {
                  return const SizedBox.shrink();
                }

                return BannerSlider(
                  banners: controller.banners,
                  onBannerTap: controller.handleBannerTap,
                );
              }),

              const SizedBox(height: 24),
              
              // Kitchens section
               SectionHeader(
                title: 'restaurants'.tr,
                section: 'restaurants',
              ),
              
              const SizedBox(height: 16),
              
              // Restaurants horizontal list (filtered)
              SizedBox(
                height: 245,
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
                        if (!logoUrl.startsWith('http')) {
                          logoUrl = 'https://mr-shife-backend-main-ygodva.laravel.cloud/storage/$logoUrl';
                        }
                      }

                      // Parse cover image URL
                      String coverUrl = '';
                      if (restaurant['cover_image'] != null && restaurant['cover_image'] != 'null') {
                        coverUrl = restaurant['cover_image'].toString();
                        if (!coverUrl.startsWith('http')) {
                          coverUrl = 'https://mr-shife-backend-main-ygodva.laravel.cloud/storage/$coverUrl';
                        }
                      }

                      // Pass complete restaurant data for the professional card
                      final restaurantData = {
                        'id': restaurant['id'] ?? index,
                        'name': restaurantName,
                        'image': logoUrl, // kept for backward compat
                        'logo': logoUrl,
                        'cover_image': coverUrl,
                        'is_active': restaurant['is_active'] ?? true,
                        'is_featured': restaurant['is_featured'] ?? false,
                        'average_rating': restaurant['average_rating'] ?? 0,
                        'reviews_count': restaurant['reviews_count'] ?? 0,
                        'delivery_fee': restaurant['delivery_fee'],
                        'offers_delivery': restaurant['offers_delivery'] ?? true,
                        'categories': restaurant['categories'],
                        'products': restaurant['products'],
                        'products_count': restaurant['products_count'],
                      };

                      return KitchenCard(
                        kitchen: restaurantData,
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
                height: 260,
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
                height: 260,
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
