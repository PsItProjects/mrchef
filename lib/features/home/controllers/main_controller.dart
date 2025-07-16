import 'package:get/get.dart';

class MainController extends GetxController {
  // Current selected tab index
  final RxInt currentIndex = 0.obs;
  
  // Tab names for reference
  final List<String> tabNames = [
    'Home',
    'Categories', 
    'Cart',
    'Favorite',
    'Profile'
  ];
  
  // Method to change tab
  void changeTab(int index) {
    currentIndex.value = index;
  }
  
  // Get current tab name
  String get currentTabName => tabNames[currentIndex.value];
}
