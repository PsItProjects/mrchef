import 'dart:async';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/services/app_service.dart';

class SplashController extends GetxController {
  final AppService _appService = Get.find<AppService>();

  @override
  void onInit() {
    super.onInit();
    _startSplashScreen();
  }

  void _startSplashScreen() {
    // Wait for app initialization and minimum splash time
    Timer(const Duration(seconds: 2), () async {
      // Wait for app service to be initialized
      while (!_appService.isInitialized.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Navigate to the determined initial route
      Get.offAllNamed(_appService.initialRoute.value);
    });
  }
}
