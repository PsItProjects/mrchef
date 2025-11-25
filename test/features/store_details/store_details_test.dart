import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';
import 'package:mrsheaf/features/store_details/pages/store_details_screen.dart';
import 'package:mrsheaf/features/store_details/bindings/store_details_binding.dart';

void main() {
  group('Store Details Feature Tests', () {
    late StoreDetailsController controller;

    setUp(() {
      Get.testMode = true;
      controller = StoreDetailsController();
      Get.put(controller);
    });

    tearDown(() {
      Get.reset();
    });

    group('StoreDetailsController', () {
      test('should initialize with default values', () {
        expect(controller.storeName.value, 'Master Chef');
        expect(controller.storeLocation.value, 'Lagos, Nigeria');
        expect(controller.storeRating.value, 4.8);
        expect(controller.isBottomSheetVisible.value, false);
      });

      test('should show and hide bottom sheet', () {
        controller.showStoreInfoBottomSheet();
        expect(controller.isBottomSheetVisible.value, true);

        controller.hideStoreInfoBottomSheet();
        expect(controller.isBottomSheetVisible.value, false);
      });

      test('should have correct working hours data', () {
        expect(controller.workingHours.length, 7);
        
        // Check Friday is off
        final friday = controller.workingHours.firstWhere(
          (day) => day['day'] == 'Friday'
        );
        expect(friday['isOff'], true);
        
        // Check Saturday has working hours
        final saturday = controller.workingHours.firstWhere(
          (day) => day['day'] == 'Saturday'
        );
        expect(saturday['isOff'], false);
        expect(saturday['startTime'], '09:00 AM');
        expect(saturday['endTime'], '09:00 PM');
      });

      test('should have contact information', () {
        expect(controller.contactInfo['phone'], '+971 764 6553');
        expect(controller.contactInfo['email'], 'jolly@mail.com');
        expect(controller.contactInfo['whatsapp'], '+971 764 6553');
        expect(controller.contactInfo['facebook'], 'facebook.com/jolly');
      });

      test('should have store products', () {
        expect(controller.storeProducts.length, 6);
        
        final firstProduct = controller.storeProducts.first;
        expect(firstProduct['name'], 'Special beef burger');
        expect(firstProduct['price'], 16);
        expect(firstProduct['isFavorite'], false);
      });

      test('should toggle product favorite status', () {
        final productId = controller.storeProducts.first['id'];
        expect(controller.storeProducts.first['isFavorite'], false);
        
        controller.toggleProductFavorite(productId);
        expect(controller.storeProducts.first['isFavorite'], true);
        
        controller.toggleProductFavorite(productId);
        expect(controller.storeProducts.first['isFavorite'], false);
      });
    });

    group('StoreDetailsBinding', () {
      test('should register StoreDetailsController', () {
        final binding = StoreDetailsBinding();
        binding.dependencies();
        
        expect(Get.isRegistered<StoreDetailsController>(), true);
      });
    });

    group('Store Details Widget Tests', () {
      testWidgets('should render store details screen', (WidgetTester tester) async {
        // Initialize GetX
        Get.testMode = true;
        Get.put(StoreDetailsController());

        await tester.pumpWidget(
          GetMaterialApp(
            home: const StoreDetailsScreen(),
          ),
        );

        // Verify the screen renders without errors
        expect(find.byType(StoreDetailsScreen), findsOneWidget);
      });

      testWidgets('should show bottom sheet when more button is tapped', (WidgetTester tester) async {
        Get.testMode = true;
        final controller = Get.put(StoreDetailsController());

        await tester.pumpWidget(
          GetMaterialApp(
            home: const StoreDetailsScreen(),
          ),
        );

        // Initially bottom sheet should not be visible
        expect(controller.isBottomSheetVisible.value, false);

        // Find and tap the more button
        final moreButton = find.byType(GestureDetector).last;
        await tester.tap(moreButton);
        await tester.pump();

        // Bottom sheet should now be visible
        expect(controller.isBottomSheetVisible.value, true);
      });
    });
  });
}
