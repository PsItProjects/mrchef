import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/cart/services/cart_service.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';
import 'package:mrsheaf/features/profile/services/address_service.dart';

import '../../profile/pages/add_edit_address_screen.dart';

class CheckoutController extends GetxController {
  final CartService _cartService = CartService();
  final AddressService _addressService = AddressService();
  final CartController cartController = Get.find<CartController>();

  // Addresses
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  
  // Loading states
  final RxBool isLoadingAddresses = false.obs;
  final RxBool isCreatingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  /// Load addresses from API
  Future<void> loadAddresses() async {
    try {
      isLoadingAddresses.value = true;
      final fetchedAddresses = await _addressService.getAddresses();
      addresses.value = fetchedAddresses;
      
      // Select default address if available
      if (fetchedAddresses.isNotEmpty) {
        final defaultAddr = fetchedAddresses.firstWhereOrNull((a) => a.isDefault);
        selectedAddress.value = defaultAddr ?? fetchedAddresses.first;
      }
    } catch (e) {
      ToastService.showError('Failed to load addresses: ${e.toString()}');
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  /// Select an address
  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  /// Create order (initiate chat)
  Future<void> createOrder() async {
    if (selectedAddress.value == null) {
      ToastService.showWarning('please_select_delivery_address'.tr);
      return;
    }

    try {
      isCreatingOrder.value = true;

      // Initiate order chat with restaurant
      final chatData = await _cartService.initiateOrderChat(
        addressId: selectedAddress.value!.id,
      );

      // Get conversation ID
      final conversationId = chatData['conversation']['id'];

      // Clear cart locally
      await cartController.clearCart(showNotification: false);

      // Navigate to chat screen
      Get.offNamed('/chat/$conversationId', arguments: chatData['conversation']);

    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ToastService.showError(errorMessage);
    } finally {
      isCreatingOrder.value = false;
    }
  }

  /// Go to add address screen
  void addNewAddress() async {
    Get.to(() => const AddEditAddressScreen());

    // await Get.toNamed(AppRoutes.ADD_EDIT_ADDRESS);
    // Reload addresses after returning
    loadAddresses();
  }
}
