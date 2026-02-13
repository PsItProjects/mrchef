import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

/// A reusable searchable bottom sheet for selecting from a list of items.
/// Used for food nationality, governorate, and similar lookup selections.
class SearchableSelectBottomSheet extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<Map<String, dynamic>> items;
  final int? selectedId;
  final Future<List<Map<String, dynamic>>> Function(String query)? onSearch;
  final IconData icon;

  const SearchableSelectBottomSheet({
    super.key,
    required this.title,
    required this.searchHint,
    required this.items,
    this.selectedId,
    this.onSearch,
    this.icon = Icons.flag_rounded,
  });

  @override
  State<SearchableSelectBottomSheet> createState() => _SearchableSelectBottomSheetState();
}

class _SearchableSelectBottomSheetState extends State<SearchableSelectBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() {
          _filteredItems = widget.items;
          _isSearching = false;
        });
        return;
      }

      if (widget.onSearch != null) {
        setState(() => _isSearching = true);
        final results = await widget.onSearch!(query);
        if (mounted) {
          setState(() {
            _filteredItems = results;
            _isSearching = false;
          });
        }
      } else {
        // Local filtering
        final lowerQuery = query.toLowerCase();
        setState(() {
          _filteredItems = widget.items.where((item) {
            final name = item['name'];
            if (name is Map) {
              return (name['en']?.toString().toLowerCase().contains(lowerQuery) ?? false) ||
                  (name['ar']?.toString().toLowerCase().contains(lowerQuery) ?? false) ||
                  (name['current']?.toString().toLowerCase().contains(lowerQuery) ?? false);
            }
            return name.toString().toLowerCase().contains(lowerQuery);
          }).toList();
        });
      }
    });
  }

  String _getItemName(Map<String, dynamic> item) {
    final name = item['name'];
    if (name is Map) {
      final lang = Get.locale?.languageCode ?? 'en';
      return name['current'] ?? name[lang] ?? name['en'] ?? name['ar'] ?? '';
    }
    return name?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: AppColors.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDarkColor,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close_rounded, color: AppColors.textMediumColor, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: TextStyle(color: AppColors.hintTextColor, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryColor, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        child: Icon(Icons.clear_rounded, color: AppColors.textMediumColor, size: 20),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
                ),
                filled: true,
                fillColor: AppColors.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const Divider(height: 1),

          // Items list
          Flexible(
            child: _isSearching
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'no_results_found'.tr,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textMediumColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredItems.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: 64,
                          color: Colors.grey.shade100,
                        ),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final itemId = item['id'] as int;
                          final isSelected = widget.selectedId == itemId;
                          final itemName = _getItemName(item);
                          final icon = item['icon'];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor.withOpacity(0.15)
                                    : AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: AppColors.primaryColor, width: 1.5)
                                    : null,
                              ),
                              child: icon != null && icon.toString().isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        icon.toString(),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          widget.icon,
                                          color: isSelected ? AppColors.primaryColor : AppColors.textMediumColor,
                                          size: 22,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      widget.icon,
                                      color: isSelected ? AppColors.primaryColor : AppColors.textMediumColor,
                                      size: 22,
                                    ),
                            ),
                            title: Text(
                              itemName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.secondaryColor : AppColors.textDarkColor,
                              ),
                            ),
                            trailing: isSelected
                                ? Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.check_rounded, color: AppColors.secondaryColor, size: 18),
                                  )
                                : null,
                            onTap: () => Get.back(result: item),
                          );
                        },
                      ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

/// Helper function to show the searchable select bottom sheet
Future<Map<String, dynamic>?> showSearchableSelectBottomSheet({
  required String title,
  required String searchHint,
  required List<Map<String, dynamic>> items,
  int? selectedId,
  Future<List<Map<String, dynamic>>> Function(String query)? onSearch,
  IconData icon = Icons.flag_rounded,
}) async {
  return await Get.bottomSheet<Map<String, dynamic>>(
    SearchableSelectBottomSheet(
      title: title,
      searchHint: searchHint,
      items: items,
      selectedId: selectedId,
      onSearch: onSearch,
      icon: icon,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
  );
}
