import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/models/banner_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerSlider extends StatefulWidget {
  final List<BannerModel> banners;
  final Function(BannerModel) onBannerTap;

  const BannerSlider({
    super.key,
    required this.banners,
    required this.onBannerTap,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.banners.length <= 1) return;

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final languageCode = Get.locale?.languageCode ?? 'en';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Banner slider
          Container(
            width: double.infinity,
            height: 220,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // PageView for banners
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = widget.banners[index];
                    return _buildBannerItem(banner, languageCode);
                  },
                ),

                // Dot indicator positioned at the bottom center
                if (widget.banners.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: widget.banners.length,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: AppColors.primaryColor,
                          dotColor: Colors.white,
                          dotHeight: 10,
                          dotWidth: 10,
                          spacing: 8.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(BannerModel banner, String languageCode) {
    return GestureDetector(
      onTap: () {
        // Only trigger tap for interactive banner types
        if (banner.type != 'image_only') {
          widget.onBannerTap(banner);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Banner image
          if (banner.image != null)
            CachedNetworkImage(
              imageUrl: banner.image!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),

          // Text overlay for image_text type
          if (banner.type == 'image_text' && (banner.title != null || banner.description != null))
            _buildTextOverlay(banner, languageCode),
        ],
      ),
    );
  }

  Widget _buildTextOverlay(BannerModel banner, String languageCode) {
    final title = banner.getTitle(languageCode);
    final description = banner.getDescription(languageCode);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (title != null && description != null) const SizedBox(height: 8),
            if (description != null)
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

