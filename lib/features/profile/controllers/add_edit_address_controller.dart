import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  final labelController = TextEditingController();

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
    labelController.dispose();
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
      labelController.text = existingAddress!.label;
    }
  }

  void toggleDefault(bool value) {
    isDefault.value = value;
  }

  void changeAddressType(AddressType type) {
    selectedType.value = type;
    if (type != AddressType.other) {
      labelController.clear();
    }
  }

  /// Whether custom label input should be shown
  bool get showLabelInput => selectedType.value == AddressType.other;

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    final address = AddressModel(
      id: existingAddress?.id,
      type: selectedType.value,
      label: selectedType.value == AddressType.other
          ? labelController.text.trim()
          : '',
      addressLine1: addressLine1Controller.text.trim(),
      addressLine2: addressLine2Controller.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: 'Saudi arabia',
      isDefault: isDefault.value,
    );

    try {
      if (address.id != null) {
        await _addressService.updateAddress(address.id!, address);
      } else {
        await _addressService.addAddress(address);
      }

      // Refresh the addresses list
      if (Get.isRegistered<ShippingAddressesController>()) {
        final shippingController = Get.find<ShippingAddressesController>();
        await shippingController.loadAddresses();
      }

      isLoading.value = false;

      // Navigate back after current frame completes
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<AddEditAddressController>()) {
          Get.back(result: true);
          ToastService.showSuccess('address_saved'.tr);
        }
      });
    } catch (e) {
      ToastService.showError('${'error_saving_address'.tr}: ${e.toString()}');
      isLoading.value = false;
    }
  }

  // Form validation
  String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'city_required'.tr;
    }
    return null;
  }

  String? validateAddressLine1(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'address_required'.tr;
    }
    return null;
  }

  String? validateLabel(String? value) {
    if (selectedType.value == AddressType.other &&
        (value == null || value.trim().isEmpty)) {
      return 'label_required'.tr;
    }
    return null;
  }

  // Getters for UI
  bool get isEditing => existingAddress != null;
  String get screenTitle => isEditing ? 'edit_address'.tr : 'add_address'.tr;
}
