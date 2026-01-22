import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';
import 'package:mrsheaf/features/profile/controllers/shipping_addresses_controller.dart';
import 'package:mrsheaf/features/profile/services/address_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';

class AddEditAddressController extends GetxController {
  final AddressModel? existingAddress;
  final bool fromCheckout;
  final AddressService _addressService = AddressService();

  AddEditAddressController({this.existingAddress, this.fromCheckout = false});

  // Form controllers
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();

  // Form validation
  final formKey = GlobalKey<FormState>();

  // Loading state
  final RxBool isLoading = false.obs;

  // Address type and default setting
  final Rx<AddressType> selectedType = AddressType.home.obs;
  final RxBool isDefault = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExistingAddress();
  }

  @override
  void onClose() {
    cityController.dispose();
    stateController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    super.onClose();
  }

  void _loadExistingAddress() {
    if (existingAddress != null) {
      cityController.text = existingAddress!.city;
      stateController.text = existingAddress!.state;
      addressLine1Controller.text = existingAddress!.addressLine1;
      addressLine2Controller.text = existingAddress!.addressLine2;
      selectedType.value = existingAddress!.type;
      isDefault.value = existingAddress!.isDefault;
    }
  }

  void toggleDefault(bool value) {
    isDefault.value = value;
  }

  void changeAddressType(AddressType type) {
    selectedType.value = type;
  }

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    // Create address model
    final address = AddressModel(
      id: existingAddress?.id, // null for new address
      type: selectedType.value,
      addressLine1: addressLine1Controller.text.trim(),
      addressLine2: addressLine2Controller.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: 'Saudi arabia', // Default country
      isDefault: isDefault.value,
    );

    try {
      // If coming from checkout, use service directly
      if (fromCheckout) {
        if (address.id != null) {
          await _addressService.updateAddress(address.id!, address);
          ToastService.showSuccess('address_saved'.tr);
        } else {
          await _addressService.addAddress(address);
          ToastService.showSuccess('address_saved'.tr);
        }
        // Go back with result
        Get.back(result: true);
      } else {
        // Coming from profile - use ShippingAddressesController if available
        if (Get.isRegistered<ShippingAddressesController>()) {
          final shippingController = Get.find<ShippingAddressesController>();
          await shippingController.saveAddress(address);
        } else {
          // Fallback to direct service
          if (address.id != null) {
            await _addressService.updateAddress(address.id!, address);
            ToastService.showSuccess('address_saved'.tr);
          } else {
            await _addressService.addAddress(address);
            ToastService.showSuccess('address_saved'.tr);
          }
          Get.back(result: true);
        }
      }
    } catch (e) {
      ToastService.showError('Failed to save address: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Form validation methods
  String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }
    return null;
  }

  String? validateAddressLine1(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address Line 1 is required';
    }
    return null;
  }

  // Getters for UI
  bool get isEditing => existingAddress != null;

  String get screenTitle => isEditing ? 'Edit Address' : 'Add Address';

  String get typeDisplayName =>
      selectedType.value.toString().split('.').last.toUpperCase();
}
