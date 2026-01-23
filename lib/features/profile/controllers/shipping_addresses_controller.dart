import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';
import 'package:mrsheaf/features/profile/pages/add_edit_address_screen.dart';
import 'package:mrsheaf/features/profile/services/address_service.dart';
import '../../../core/services/toast_service.dart';

class ShippingAddressesController extends GetxController {
  // All addresses
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxList<AddressModel> _allAddresses = <AddressModel>[].obs;
  final RxBool isLoading = false.obs;
  final AddressService _addressService = AddressService();
  
  // Search functionality
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

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
      _allAddresses.value = fetchedAddresses;
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
        title: Text(
          'delete_address'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        content: Text(
          '${'are_you_sure_delete'.tr} ${address.typeDisplayName.toLowerCase()} ${'address'.tr}?',
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
            child: Text(
              'cancel'.tr,
              style: const TextStyle(
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
            child: Text(
              'delete'.tr,
              style: const TextStyle(
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
      ToastService.showSuccess('address_deleted'.tr);
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
        ToastService.showSuccess('address_updated'.tr);
      } else {
        // Add new address
        final newAddress = await _addressService.addAddress(address);
        addresses.add(newAddress);
        ToastService.showSuccess('address_added'.tr);
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
  
  // Search functionality
  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      // Clear search when closing
      updateSearchQuery('');
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _filterAddresses();
  }

  void _filterAddresses() {
    if (searchQuery.value.isEmpty) {
      // Show all addresses
      addresses.value = List.from(_allAddresses);
    } else {
      final query = searchQuery.value.toLowerCase();

      // Filter addresses by type name and address details
      addresses.value = _allAddresses.where((address) {
        final typeMatch = address.typeDisplayName.toLowerCase().contains(query);
        final addressLine1Match = address.addressLine1.toLowerCase().contains(query);
        final addressLine2Match = address.addressLine2?.toLowerCase().contains(query) ?? false;
        final cityMatch = address.city.toLowerCase().contains(query);

        return typeMatch || addressLine1Match || addressLine2Match || cityMatch;
      }).toList();
    }
  }
}
