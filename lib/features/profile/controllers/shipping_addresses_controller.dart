import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';
import 'package:mrsheaf/features/profile/pages/add_edit_address_screen.dart';
import 'package:mrsheaf/features/profile/services/address_service.dart';
import '../../../core/services/toast_service.dart';

class ShippingAddressesController extends GetxController {
  // All addresses
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = false.obs;
  final AddressService _addressService = AddressService();

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  /// Load addresses from API
  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      final fetchedAddresses = await _addressService.getAddresses();
      addresses.value = fetchedAddresses;
    } catch (e) {
      ToastService.showError('Failed to load addresses: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Address actions
  void addNewAddress() {
    Get.to(() => const AddEditAddressScreen());
  }

  void editAddress(AddressModel address) {
    Get.to(() => AddEditAddressScreen(address: address));
  }

  void deleteAddress(AddressModel address) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Address',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this ${address.typeDisplayName.toLowerCase()} address?',
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF5E5E5E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performDeleteAddress(address);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFFEB5757),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAddress(AddressModel address) async {
    if (address.id == null) return;

    try {
      await _addressService.deleteAddress(address.id!);
      addresses.removeWhere((a) => a.id == address.id);
      ToastService.showSuccess('Address has been deleted successfully');
    } catch (e) {
      ToastService.showError('Failed to delete address: ${e.toString()}');
    }
  }

  Future<void> setDefaultAddress(AddressModel address) async {
    if (address.id == null) return;

    try {
      await _addressService.setDefaultAddress(address.id!);

      // Update local state
      for (int i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isDefault: false);
      }

      final index = addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        addresses[index] = addresses[index].copyWith(isDefault: true);
      }

      ToastService.showSuccess('${address.typeDisplayName} address set as default');
    } catch (e) {
      ToastService.showError('Failed to set default address: ${e.toString()}');
    }
  }

  Future<void> saveAddress(AddressModel address) async {
    try {
      if (address.id != null) {
        // Update existing address
        final updatedAddress = await _addressService.updateAddress(address.id!, address);
        final existingIndex = addresses.indexWhere((a) => a.id == address.id);
        if (existingIndex != -1) {
          addresses[existingIndex] = updatedAddress;
        }
        ToastService.showSuccess('Address has been updated successfully');
      } else {
        // Add new address
        final newAddress = await _addressService.addAddress(address);
        addresses.add(newAddress);
        ToastService.showSuccess('New address has been added successfully');
      }

      // Go back with result to indicate success
      Get.back(result: true);
    } catch (e) {
      ToastService.showError('Failed to save address: ${e.toString()}');
    }
  }

  // Getters for UI
  bool get hasAddresses => addresses.isNotEmpty;

  int get totalAddresses => addresses.length;

  AddressModel? get defaultAddress =>
      addresses.firstWhereOrNull((a) => a.isDefault);
}
