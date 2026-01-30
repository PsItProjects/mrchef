import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:mrsheaf/core/services/fcm_service.dart';
import 'package:mrsheaf/core/services/realtime_chat_service.dart';
import 'package:mrsheaf/core/services/onboarding_service.dart';
import 'package:mrsheaf/core/services/guest_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
  final themeService = ThemeService();
  await themeService.onInit();
  Get.put(themeService, permanent: true);

  final languageService = LanguageService();
  await languageService.onInit();
  Get.put(languageService, permanent: true);

  // Initialize OnboardingService
  await Get.putAsync(() => OnboardingService().init());

  // Initialize GuestService
  await Get.putAsync(() => GuestService().init());

  final appService = AppService();
  await appService.onInit();
  Get.put(appService, permanent: true);

  // Initialize ApiClient
  Get.put(ApiClient.instance, permanent: true);

  // Initialize FavoritesController early
  Get.put(FavoritesController(), permanent: true);

  // Initialize FCM Service
  await Get.putAsync(() => FCMService().init());

  // Initialize Realtime Chat Service
  await Get.putAsync(() => RealtimeChatService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService.instance;
    final initialLocale = languageService.currentLanguage == 'ar'
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');

    return GetMaterialApp(
      title: 'MrSheaf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      translations: AppTranslations(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      builder: (context, child) {
        final isArabic = (Get.locale?.languageCode ?? 'en') == 'ar';
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
