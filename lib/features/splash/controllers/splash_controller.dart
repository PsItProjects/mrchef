import 'dart:async';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startSplashScreen();
  }

  void _startSplashScreen() {
    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    });
  }
}
