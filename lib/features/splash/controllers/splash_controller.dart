import 'dart:async';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/services/app_service.dart';

class SplashController extends GetxController {
  final AppService _appService = Get.find<AppService>();

  @override
  void onInit() {
    super.onInit();
    print('🎬 SplashController.onInit() - AppService found, isInitialized: ${_appService.isInitialized.value}');
    _startSplashScreen();
  }

  void _startSplashScreen() {
    print('🎬 _startSplashScreen() - Starting 2 second timer');
    // Wait for app initialization and minimum splash time
    Timer(const Duration(seconds: 2), () async {
      print('🎬 Timer completed - Checking if app is initialized...');
      // Wait for app service to be initialized
      int waitCount = 0;
      while (!_appService.isInitialized.value) {
        waitCount++;
        if (waitCount % 10 == 0) {
          print('🎬 Still waiting for initialization... (${waitCount * 100}ms)');
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }

      print('🎬 App initialized! Navigating to: ${_appService.initialRoute.value}');
      // Navigate to the determined initial route
      Get.offAllNamed(_appService.initialRoute.value);
    });
  }
}
