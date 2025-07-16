import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';
import 'package:mrsheaf/features/profile/controllers/shipping_addresses_controller.dart';

class AddEditAddressController extends GetxController {
  final AddressModel? existingAddress;

  AddEditAddressController({this.existingAddress});

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

  void saveAddress() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    // Create address model
    final address = AddressModel(
      id: existingAddress?.id ?? 0, // Will be set by controller if new
      type: selectedType.value,
      addressLine1: addressLine1Controller.text.trim(),
      addressLine2: addressLine2Controller.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: 'France', // Default country
      isDefault: isDefault.value,
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      final shippingController = Get.find<ShippingAddressesController>();
      shippingController.saveAddress(address);
      isLoading.value = false;
    });
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
  
  String get typeDisplayName => selectedType.value.toString().split('.').last.toUpperCase();
}
