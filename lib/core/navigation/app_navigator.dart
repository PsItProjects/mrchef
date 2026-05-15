import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppNavigator {
  const AppNavigator._();

  static void back<T>({T? result}) {
    if (_pop(Get.key?.currentState, result)) {
      return;
    }

    final context = Get.context;
    if (context == null) {
      return;
    }

    try {
      _pop(Navigator.of(context, rootNavigator: true), result);
    } catch (_) {}
  }

  static bool _pop<T>(NavigatorState? navigator, T? result) {
    if (navigator == null) {
      return false;
    }

    try {
      if (!navigator.canPop()) {
        return false;
      }
      navigator.pop<T>(result);
      return true;
    } catch (_) {
      return false;
    }
  }
}