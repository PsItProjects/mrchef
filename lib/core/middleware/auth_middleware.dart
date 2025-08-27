import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // If user is not authenticated, redirect to login
    if (!authService.isAuthenticated) {
      return const RouteSettings(name: '/login');
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
      return const RouteSettings(name: '/home');
    }
    
    return null;
  }
}
