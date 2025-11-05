import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mrsheaf/core/localization/app_translations.dart';
import 'package:mrsheaf/core/routes/app_pages.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/services/app_service.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/services/theme_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Google Maps renderer for Android
  if (Platform.isAndroid) {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await Get.putAsync(() => ThemeService().onInit().then((_) => ThemeService()));
  await Get.putAsync(() => LanguageService().onInit().then((_) => LanguageService()));
  await Get.putAsync(() => AppService().onInit().then((_) => AppService()));

  // Initialize ApiClient
  Get.put(ApiClient.instance, permanent: true);

  // Initialize FavoritesController early
  Get.put(FavoritesController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService.instance;

    return Obx(() {
      final isArabic = languageService.currentLanguage == 'ar';
      final locale = isArabic
          ? const Locale('ar', 'SA')
          : const Locale('en', 'US');

      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Listener(
          onPointerUp: (_) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              currentFocus.focusedChild?.unfocus();
            }
          },
          child: GetMaterialApp(
            title: 'MrSheaf',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: locale,
            fallbackLocale: const Locale('en', 'US'),
            translations: AppTranslations(),
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
          ),
        ),
      );


    });
  }
}
