import 'package:get/get.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';

class MerchantDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  // Observable variables
  var isLoading = false.obs;
  var merchantName = ''.obs;
  var merchantEmail = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadMerchantData();
  }
  
  void _loadMerchantData() {
    try {
      final user = _authService.currentUser.value;
      if (user != null) {
        merchantName.value = user.fullName ?? user.nameAr ?? user.nameEn ?? 'التاجر';
        merchantEmail.value = user.email ?? '';
      }
    } catch (e) {
      print('Error loading merchant data: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.logout();
      Get.snackbar(
        'تم تسجيل الخروج',
        'تم تسجيل الخروج بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الخروج',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void navigateToProducts() {
    Get.snackbar(
      'قريباً',
      'صفحة إدارة المنتجات قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void navigateToOrders() {
    Get.snackbar(
      'قريباً',
      'صفحة الطلبات قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void navigateToReports() {
    Get.snackbar(
      'قريباً',
      'صفحة التقارير قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void navigateToSettings() {
    Get.snackbar(
      'قريباً',
      'صفحة الإعدادات قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
