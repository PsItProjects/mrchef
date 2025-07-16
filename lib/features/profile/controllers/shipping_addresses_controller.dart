import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';
import 'package:mrsheaf/features/profile/pages/add_edit_address_screen.dart';

class ShippingAddressesController extends GetxController {
  // All addresses
  final RxList<AddressModel> addresses = <AddressModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // _initializeSampleData(); // Temporarily disabled to test empty state
  }

  void _initializeSampleData() {
    // Add sample addresses
    addresses.addAll([
      AddressModel(
        id: 1,
        type: AddressType.home,
        addressLine1: '25 rue Robert Latouche',
        city: 'Nice',
        postalCode: '06200',
        state: 'Côte D\'azur',
        country: 'France',
        isDefault: true,
      ),
      AddressModel(
        id: 2,
        type: AddressType.work,
        addressLine1: '25 rue Robert Latouche',
        city: 'Nice',
        postalCode: '06200',
        state: 'Côte D\'azur',
        country: 'France',
        isDefault: false,
      ),
    ]);
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

  void _performDeleteAddress(AddressModel address) {
    addresses.removeWhere((a) => a.id == address.id);
    Get.snackbar(
      'Address Deleted',
      'Address has been deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setDefaultAddress(AddressModel address) {
    // Remove default from all addresses
    for (int i = 0; i < addresses.length; i++) {
      addresses[i] = addresses[i].copyWith(isDefault: false);
    }
    
    // Set the selected address as default
    final index = addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      addresses[index] = addresses[index].copyWith(isDefault: true);
    }
    
    Get.snackbar(
      'Default Address Updated',
      '${address.typeDisplayName} address set as default',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveAddress(AddressModel address) {
    final existingIndex = addresses.indexWhere((a) => a.id == address.id);
    
    if (existingIndex != -1) {
      // Update existing address
      addresses[existingIndex] = address;
      Get.snackbar(
        'Address Updated',
        'Address has been updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Add new address
      final newAddress = address.copyWith(id: _generateNewId());
      addresses.add(newAddress);
      Get.snackbar(
        'Address Added',
        'New address has been added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    
    Get.back();
  }

  int _generateNewId() {
    if (addresses.isEmpty) return 1;
    return addresses.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // Add sample data for testing
  void addSampleData() {
    _initializeSampleData();
  }

  // Clear all addresses for testing empty state
  void clearAllAddresses() {
    addresses.clear();
  }

  // Getters for UI
  bool get hasAddresses => addresses.isNotEmpty;
  
  int get totalAddresses => addresses.length;
  
  AddressModel? get defaultAddress => addresses.firstWhereOrNull((a) => a.isDefault);
}
