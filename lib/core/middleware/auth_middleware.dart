import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/services/auth_service.dart';
import '../routes/app_routes.dart';
import '../services/guest_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Allow guest mode to access the main home shell (/home) for browsing.
    try {
      final guestService = Get.find<GuestService>();
      if (guestService.isGuestMode && route == AppRoutes.HOME) {
        return null;
      }
    } catch (_) {
      // GuestService may not be registered yet in some edge cases.
    }
    
    // If user is not authenticated, redirect to login
    if (!authService.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    
    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // If user is already authenticated, redirect to home
    if (authService.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.HOME);
    }
    
    return null;
  }
}
