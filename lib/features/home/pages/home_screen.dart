import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              const SectionHeader(
                title: 'Kitchens',
                section: 'kitchens',
              ),
              
              const SizedBox(height: 16),
              
              // Kitchens horizontal list
              SizedBox(
                height: 223,
                child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: controller.kitchens.length,
                  itemBuilder: (context, index) {
                    return KitchenCard(
                      kitchen: controller.kitchens[index],
                    );
                  },
                )),
              ),
              
              const SizedBox(height: 24),
              
              // Best seller section
              const SectionHeader(
                title: 'Best seller',
                section: 'bestSeller',
              ),
              
              const SizedBox(height: 16),
              
              // Best seller horizontal list
              SizedBox(
                height: 240,
                child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: controller.bestSellerProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: controller.bestSellerProducts[index],
                      section: 'bestSeller',
                    );
                  },
                )),
              ),
              
              const SizedBox(height: 24),
              
              // Back again section
              const SectionHeader(
                title: 'Back again',
                section: 'backAgain',
              ),
              
              const SizedBox(height: 16),
              
              // Back again horizontal list
              SizedBox(
                height: 240,
                child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: controller.backAgainProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: controller.backAgainProducts[index],
                      section: 'backAgain',
                    );
                  },
                )),
              ),
              
              const SizedBox(height: 100), // Extra space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}
