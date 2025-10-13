import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/services/merchant_settings_service.dart';

class RestaurantInfoScreen extends StatefulWidget {
  const RestaurantInfoScreen({super.key});

  @override
  State<RestaurantInfoScreen> createState() => _RestaurantInfoScreenState();
}

class _RestaurantInfoScreenState extends State<RestaurantInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _settingsService = MerchantSettingsService.instance;
  
  // Controllers
  late TextEditingController _nameEnController;
  late TextEditingController _nameArController;
  late TextEditingController _businessNameEnController;
  late TextEditingController _businessNameArController;
  late TextEditingController _descriptionEnController;
  late TextEditingController _descriptionArController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _areaController;
  late TextEditingController _deliveryFeeController;
  late TextEditingController _minimumOrderController;
  late TextEditingController _deliveryRadiusController;
  late TextEditingController _preparationTimeController;
  
  String _selectedBusinessType = 'restaurant';
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadRestaurantInfo();
  }
  
  void _initializeControllers() {
    _nameEnController = TextEditingController();
    _nameArController = TextEditingController();
    _businessNameEnController = TextEditingController();
    _businessNameArController = TextEditingController();
    _descriptionEnController = TextEditingController();
    _descriptionArController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _cityController = TextEditingController();
    _areaController = TextEditingController();
    _deliveryFeeController = TextEditingController();
    _minimumOrderController = TextEditingController();
    _deliveryRadiusController = TextEditingController();
    _preparationTimeController = TextEditingController();
  }
  
  void _loadRestaurantInfo() {
    final restaurant = _settingsService.restaurantInfo.value;

    // Only load if we have restaurant data
    if (restaurant.nameEn != null || restaurant.nameAr != null) {
      _nameEnController.text = restaurant.nameEn ?? '';
      _nameArController.text = restaurant.nameAr ?? '';
      _businessNameEnController.text = restaurant.businessNameEn ?? '';
      _businessNameArController.text = restaurant.businessNameAr ?? '';
      _descriptionEnController.text = restaurant.descriptionEn ?? '';
      _descriptionArController.text = restaurant.descriptionAr ?? '';
      _phoneController.text = restaurant.phone ?? '';
      _emailController.text = restaurant.email ?? '';
      _cityController.text = restaurant.city ?? '';
      _areaController.text = restaurant.area ?? '';
      _deliveryFeeController.text = restaurant.deliveryFee?.toString() ?? '';
      _minimumOrderController.text = restaurant.minimumOrder?.toString() ?? '';
      _deliveryRadiusController.text = restaurant.deliveryRadius?.toString() ?? '';
      _preparationTimeController.text = restaurant.preparationTime?.toString() ?? '';
      _selectedBusinessType = restaurant.businessType ?? 'restaurant';
    } else {
      // Set default values if no restaurant data
      _selectedBusinessType = 'restaurant';
    }
  }
  
  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _businessNameEnController.dispose();
    _businessNameArController.dispose();
    _descriptionEnController.dispose();
    _descriptionArController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _deliveryFeeController.dispose();
    _minimumOrderController.dispose();
    _deliveryRadiusController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom Header (like user screens)
          Container(
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Title
                Text(
                  'restaurant_info'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

                // Placeholder for symmetry
                Container(width: 40, height: 40),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
        if (_settingsService.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }
        
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('basic_info'.tr),
                const SizedBox(height: 16),
                _buildBasicInfoSection(),
                
                const SizedBox(height: 32),
                _buildSectionTitle('business_details'.tr),
                const SizedBox(height: 16),
                _buildBusinessDetailsSection(),
                
                const SizedBox(height: 32),
                _buildSectionTitle('delivery_settings'.tr),
                const SizedBox(height: 16),
                _buildDeliverySettingsSection(),
                
                const SizedBox(height: 40),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Color(0xFF262626),
      ),
    );
  }
  
  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameEnController,
            label: 'restaurant_name_en'.tr,
            hint: 'Enter restaurant name in English',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Restaurant name in English is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameArController,
            label: 'restaurant_name_ar'.tr,
            hint: 'أدخل اسم المطعم بالعربية',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'اسم المطعم بالعربية مطلوب';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessNameEnController,
            label: 'business_name_en'.tr,
            hint: 'Enter business name in English',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessNameArController,
            label: 'business_name_ar'.tr,
            hint: 'أدخل اسم النشاط التجاري بالعربية',
          ),
          const SizedBox(height: 16),
          _buildBusinessTypeDropdown(),
        ],
      ),
    );
  }
  
  Widget _buildBusinessDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _descriptionEnController,
            label: 'description_en'.tr,
            hint: 'Enter restaurant description in English',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionArController,
            label: 'description_ar'.tr,
            hint: 'أدخل وصف المطعم بالعربية',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'phone'.tr,
            hint: '+966 50 123 4567',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'email'.tr,
            hint: 'restaurant@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'city'.tr,
                  hint: 'الرياض',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _areaController,
                  label: 'area'.tr,
                  hint: 'الملز',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeliverySettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _deliveryFeeController,
                  label: 'delivery_fee'.tr,
                  hint: '15.00',
                  keyboardType: TextInputType.number,
                  suffix: 'ر.س',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _minimumOrderController,
                  label: 'minimum_order'.tr,
                  hint: '50.00',
                  keyboardType: TextInputType.number,
                  suffix: 'ر.س',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _deliveryRadiusController,
                  label: 'delivery_radius'.tr,
                  hint: '10',
                  keyboardType: TextInputType.number,
                  suffix: 'كم',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _preparationTimeController,
                  label: 'preparation_time'.tr,
                  hint: '30',
                  keyboardType: TextInputType.number,
                  suffix: 'دقيقة',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF262626),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            hintStyle: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            color: Color(0xFF262626),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBusinessTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'business_type'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF262626),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final types = _settingsService.businessTypes;
          if (types.isEmpty) {
            return Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: types.map<DropdownMenuItem<String>>((type) {
              final value = type['value'] as String;
              final labelAr = type['label_ar'] as String;
              return DropdownMenuItem(
                value: value,
                child: Text(labelAr),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBusinessType = value!;
              });
            },
          );
        }),
      ],
    );
  }
  
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveRestaurantInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'save_changes'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Future<void> _saveRestaurantInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final success = await _settingsService.updateRestaurantInfo(
      nameEn: _nameEnController.text.trim(),
      nameAr: _nameArController.text.trim(),
      businessNameEn: _businessNameEnController.text.trim(),
      businessNameAr: _businessNameArController.text.trim(),
      descriptionEn: _descriptionEnController.text.trim(),
      descriptionAr: _descriptionArController.text.trim(),
      businessType: _selectedBusinessType,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      city: _cityController.text.trim(),
      area: _areaController.text.trim(),
      deliveryFee: double.tryParse(_deliveryFeeController.text.trim()),
      minimumOrder: double.tryParse(_minimumOrderController.text.trim()),
      deliveryRadius: int.tryParse(_deliveryRadiusController.text.trim()),
      preparationTime: int.tryParse(_preparationTimeController.text.trim()),
    );
    
    if (success) {
      Get.back();
    }
  }
}
