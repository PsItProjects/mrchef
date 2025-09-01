import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/widgets/app_search_bar.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';

class SearchBarWidget extends GetView<HomeController> {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      hintText: 'Search products',
      onTap: controller.onSearchTap,
    );
  }
}
