import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/cart/services/cart_service.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';
import 'package:mrsheaf/features/profile/services/address_service.dart';

class CheckoutController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;
  final AddressService _addressService = AddressService();
  final CartService _cartService = CartService();
  
  // Cart controller reference
  late CartController cartController;
  
  // Addresses
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxBool isLoadingAddresses = true.obs;
  
  // Order creation
  final RxBool isCreatingOrder = false.obs;
  
  // Add address form controllers
  final formKey = GlobalKey<FormState>();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final RxBool isDefault = false.obs;
  final RxBool isSavingAddress = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    cartController = Get.find<CartController>();
    loadAddresses();
  }
  
  @override
  void onClose() {
    cityController.dispose();
    stateController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    super.onClose();
  }

  Future<void> loadAddresses() async {
    try {
      isLoadingAddresses.value = true;
      final loadedAddresses = await _addressService.getAddresses();
      addresses.value = loadedAddresses;
      
      // Auto-select default address or first address
      if (addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhereOrNull((a) => a.isDefault);
        selectedAddress.value = defaultAddress ?? addresses.first;
        print('📍 Selected address: ${selectedAddress.value?.addressLine1}');
      }
    } catch (e) {
      print('❌ Error loading addresses: $e');
      ToastService.showError('failed_to_load_addresses'.tr);
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  /// Show add address bottom sheet modal
  void showAddAddressModal() {
    // Reset form
    _resetForm();
    
    Get.bottomSheet(
      _buildAddAddressModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }

  void _resetForm() {
    cityController.clear();
    stateController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    isDefault.value = false;
  }

  Widget _buildAddAddressModal() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF262626),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'add_new_address'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF262626),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City field
                    _buildInputField(
                      label: 'city'.tr,
                      controller: cityController,
                      validator: _validateCity,
                      placeholder: 'enter_city'.tr,
                      icon: Icons.location_city_outlined,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // State/Province field
                    _buildInputField(
                      label: 'state_province'.tr,
                      controller: stateController,
                      placeholder: 'enter_state'.tr,
                      icon: Icons.map_outlined,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Address Line 1 field
                    _buildInputField(
                      label: 'address_line_1'.tr,
                      controller: addressLine1Controller,
                      validator: _validateAddressLine1,
                      placeholder: 'enter_address'.tr,
                      icon: Icons.home_outlined,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Address Line 2 field
                    _buildInputField(
                      label: 'address_line_2'.tr,
                      controller: addressLine2Controller,
                      placeholder: 'apartment_suite'.tr,
                      icon: Icons.apartment_outlined,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Make Default toggle
                    _buildDefaultToggle(),
                    
                    const SizedBox(height: 24),
                    
                    // Save button
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isSavingAddress.value ? null : _saveNewAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isSavingAddress.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'save_address'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    )),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    required String placeholder,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF262626),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Input field
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF262626),
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.grey[500],
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE3E3E3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE3E3E3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_outline,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'make_default'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF262626),
                ),
              ),
            ],
          ),
          Obx(() => Switch(
            value: isDefault.value,
            onChanged: (value) => isDefault.value = value,
            activeColor: AppColors.primaryColor,
            activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
          )),
        ],
      ),
    );
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'city_required'.tr;
    }
    return null;
  }

  String? _validateAddressLine1(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'address_required'.tr;
    }
    return null;
  }

  Future<void> _saveNewAddress() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isSavingAddress.value = true;

    try {
      // Create address model
      final address = AddressModel(
        type: AddressType.home,
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        country: 'Saudi arabia',
        isDefault: isDefault.value,
      );

      // Save address via service
      final savedAddress = await _addressService.addAddress(address);
      
      // Close modal
      Get.back();
      
      // Show success message
      ToastService.showSuccess('address_saved'.tr);
      
      // Reload addresses and select the new one
      await loadAddresses();
      
      // Select the newly added address
      final newAddress = addresses.firstWhereOrNull((a) => a.id == savedAddress.id);
      if (newAddress != null) {
        selectedAddress.value = newAddress;
      }
      
      print('📍 Returned from add address, reloaded ${addresses.length} addresses');
      
    } catch (e) {
      print('❌ Error saving address: $e');
      ToastService.showError('failed_to_save_address'.tr);
    } finally {
      isSavingAddress.value = false;
    }
  }

  /// Legacy method - now shows modal instead of navigating
  void addNewAddress() {
    showAddAddressModal();
  }

  Future<void> createOrder() async {
    if (selectedAddress.value == null) {
      ToastService.showError('please_select_address'.tr);
      return;
    }

    if (cartController.cartItems.isEmpty) {
      ToastService.showError('cart_is_empty'.tr);
      return;
    }

    isCreatingOrder.value = true;

    try {
      // Use initiateOrderChat which creates the order and sends message to restaurant
      final result = await _cartService.initiateOrderChat(
        addressId: selectedAddress.value!.id,
      );

      ToastService.showSuccess('order_created_success'.tr);
      
      // Clear cart
      await cartController.clearCart();
      
      // Get conversation data to navigate to chat
      final conversationData = result['conversation'];
      
      if (conversationData != null) {
        // Parse conversation model from response
        final conversation = ConversationModel.fromJson(conversationData);
        
        // Navigate to chat conversation with full conversation data
        Get.offAllNamed('/chat', arguments: {
          'conversationId': conversation.id,
          'conversation': conversation,
        });
      } else {
        // Navigate to orders or home
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      ToastService.showError(errorMessage.isNotEmpty ? errorMessage : 'failed_to_create_order'.tr);
    } finally {
      isCreatingOrder.value = false;
    }
  }
}
