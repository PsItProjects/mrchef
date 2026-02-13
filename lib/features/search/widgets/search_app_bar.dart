import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/search/controllers/search_controller.dart' as search;

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({super.key});

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final controller = Get.find<search.SearchController>();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/arrow_left.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.darkTextColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Search input field
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isFocused
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isFocused
                        ? AppColors.primaryColor.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: _isFocused ? 16 : 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: _isFocused
                        ? AppColors.primaryColor
                        : AppColors.primaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.searchTextController,
                      focusNode: _focusNode,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      cursorColor: AppColors.primaryColor,
                      decoration: InputDecoration(
                        hintText: 'search_hint'.tr,
                        hintStyle: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.darkTextColor,
                      ),
                      onChanged: (value) {
                        controller.updateSearchQuery(value);
                      },
                      onSubmitted: (value) {
                        controller.hideAutocomplete();
                        if (value.trim().isNotEmpty) {
                          controller.search();
                        }
                      },
                      onTap: () {
                        // re-show autocomplete if there is text
                        if (controller.searchQuery.value.isNotEmpty &&
                            controller.autocompleteSuggestions.isNotEmpty) {
                          controller.showAutocomplete.value = true;
                        }
                      },
                    ),
                  ),

                  // Clear button
                  Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return GestureDetector(
                        onTap: controller.clearSearch,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.grey[500],
                            size: 16,
                          ),
                        ),
                      );
                    }
                    return const SizedBox(width: 14);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Autocomplete suggestions dropdown overlay
class AutocompleteOverlay extends GetView<search.SearchController> {
  const AutocompleteOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showAutocomplete.value) {
        return const SizedBox.shrink();
      }

      if (controller.isLoadingAutocomplete.value &&
          controller.autocompleteSuggestions.isEmpty) {
        return _buildContainer(
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        );
      }

      if (controller.autocompleteSuggestions.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildContainer(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: controller.autocompleteSuggestions.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: Colors.grey[100],
            indent: 52,
          ),
          itemBuilder: (context, index) {
            final suggestion = controller.autocompleteSuggestions[index];
            return _buildSuggestionItem(suggestion);
          },
        ),
      );
    });
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion) {
    final text = (suggestion['text'] ?? suggestion['name'] ?? '') as String;
    final type = (suggestion['type'] ?? '') as String;

    IconData icon;
    Color iconColor;
    String typeLabel;

    switch (type) {
      case 'product':
        icon = Icons.fastfood_rounded;
        iconColor = const Color(0xFFFF6B35);
        typeLabel = 'product_suggestion'.tr;
        break;
      case 'restaurant':
        icon = Icons.store_rounded;
        iconColor = AppColors.secondaryColor;
        typeLabel = 'restaurant_suggestion'.tr;
        break;
      case 'category':
        icon = Icons.category_rounded;
        iconColor = const Color(0xFF4CAF50);
        typeLabel = 'category_suggestion'.tr;
        break;
      case 'cuisine':
        icon = Icons.public_rounded;
        iconColor = const Color(0xFF2196F3);
        typeLabel = 'cuisine_suggestion'.tr;
        break;
      default:
        icon = Icons.search_rounded;
        iconColor = Colors.grey;
        typeLabel = '';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectSuggestion(suggestion),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.darkTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (typeLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        typeLabel,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.north_west_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

