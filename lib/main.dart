import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_pages.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/services/app_service.dart';
import 'package:mrsheaf/core/services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await Get.putAsync(() => LanguageService().onInit().then((_) => LanguageService()));
  await Get.putAsync(() => AppService().onInit().then((_) => AppService()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService.instance;

    return Obx(() {
      final locale = languageService.currentLanguage == 'ar'
          ? const Locale('ar', 'SA')
          : const Locale('en', 'US');

      return GetMaterialApp(
        title: 'MrSheaf',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: locale,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      );
    });
  }
}
