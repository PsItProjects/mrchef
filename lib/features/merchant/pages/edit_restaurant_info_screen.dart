import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/services/merchant_profile_service.dart';
import 'package:mrsheaf/features/merchant/pages/image_crop_screen.dart';
import 'package:mrsheaf/features/merchant/widgets/location_picker_widget.dart';

class EditRestaurantInfoScreen extends StatefulWidget {
  const EditRestaurantInfoScreen({Key? key}) : super(key: key);

  @override
  State<EditRestaurantInfoScreen> createState() => _EditRestaurantInfoScreenState();
}

class _EditRestaurantInfoScreenState extends State<EditRestaurantInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = Get.find<MerchantProfileService>();
  final _imagePicker = ImagePicker();

  // Text Controllers
  late TextEditingController _businessNameArController;
  late TextEditingController _businessNameEnController;
  late TextEditingController _descriptionArController;
  late TextEditingController _descriptionEnController;
  late TextEditingController _addressArController;
  late TextEditingController _addressEnController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _areaController;

  // Image files
  File? _selectedLogo;
  File? _selectedCover;
  String? _currentLogoUrl;
  String? _currentCoverUrl;

  // Business type
  String? _selectedBusinessType;
  final List<String> _businessTypes = [
    'restaurant',
    'cafe',
    'bakery',
    'fastfood',
    'pizza',
    'seafood',
    'dessert',
    'juice',
    'grocery',
    'pharmacy',
  ];

  // Country code
  String _selectedCountryCode = '+966';
  final List<String> _countryCodes = ['+966']; // Saudi Arabia only for now

  // Location (latitude & longitude)
  double? _latitude;
  double? _longitude;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadRestaurantData();
  }

  void _initializeControllers() {
    _businessNameArController = TextEditingController();
    _businessNameEnController = TextEditingController();
    _descriptionArController = TextEditingController();
    _descriptionEnController = TextEditingController();
    _addressArController = TextEditingController();
    _addressEnController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _cityController = TextEditingController();
    _areaController = TextEditingController();
  }

  Future<void> _loadRestaurantData({bool forceRefresh = false}) async {
    try {
      print('📝 Loading restaurant data...');
      final data = await _profileService.getProfile();

      if (data != null) {
        final merchant = data['merchant'];
        final restaurant = merchant?['restaurant'];

        if (restaurant != null) {
          setState(() {
            // Business name - handle both String and Map
            final businessName = restaurant['business_name'];
            if (businessName is Map) {
              _businessNameArController.text = businessName['ar'] ?? businessName['current'] ?? '';
              _businessNameEnController.text = businessName['en'] ?? businessName['current'] ?? '';
            } else if (businessName is String) {
              _businessNameArController.text = businessName;
              _businessNameEnController.text = businessName;
            }

            // Description - handle both String and Map
            final description = restaurant['description'];
            if (description is Map) {
              _descriptionArController.text = description['ar'] ?? description['current'] ?? '';
              _descriptionEnController.text = description['en'] ?? description['current'] ?? '';
            } else if (description is String) {
              _descriptionArController.text = description;
              _descriptionEnController.text = description;
            }

            // Address - handle both String and Map
            final address = restaurant['address'];
            if (address is Map) {
              _addressArController.text = address['ar'] ?? address['current'] ?? '';
              _addressEnController.text = address['en'] ?? address['current'] ?? '';
            } else if (address is String) {
              _addressArController.text = address;
              _addressEnController.text = address;
            }

            // Contact info
            _phoneController.text = restaurant['phone']?.toString() ?? '';
            _emailController.text = restaurant['email']?.toString() ?? '';
            _cityController.text = restaurant['city']?.toString() ?? '';
            _areaController.text = restaurant['area']?.toString() ?? '';

            // Business type
            _selectedBusinessType = restaurant['type']?.toString();

            // Location
            _latitude = restaurant['latitude'] != null
                ? double.tryParse(restaurant['latitude'].toString())
                : null;
            _longitude = restaurant['longitude'] != null
                ? double.tryParse(restaurant['longitude'].toString())
                : null;

            // Images
            _currentLogoUrl = restaurant['logo']?.toString();
            _currentCoverUrl = restaurant['cover_image']?.toString();
          });

          print('✅ Restaurant data loaded successfully');
          print('   Business Name AR: ${_businessNameArController.text}');
          print('   Business Name EN: ${_businessNameEnController.text}');
          print('   Logo: $_currentLogoUrl');
          print('   Cover: $_currentCoverUrl');
        }
      }
    } catch (e) {
      print('❌ Error loading restaurant data: $e');
    }
  }

  @override
  void dispose() {
    _businessNameArController.dispose();
    _businessNameEnController.dispose();
    _descriptionArController.dispose();
    _descriptionEnController.dispose();
    _addressArController.dispose();
    _addressEnController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  /// Pick logo image (circular crop)
  Future<void> _pickLogo(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source, imageQuality: 100);
      if (image == null) return;

      final Uint8List imageBytes = await image.readAsBytes();
      final Uint8List? croppedImage = await Get.to<Uint8List>(
        () => ImageCropScreen(imageData: imageBytes),
        transition: Transition.cupertino,
      );

      if (croppedImage != null) {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/logo_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(croppedImage);
        setState(() => _selectedLogo = tempFile);
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'image_upload_failed'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pick cover image (rectangular)
  Future<void> _pickCover(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source, imageQuality: 100);
      if (image == null) return;

      final Uint8List imageBytes = await image.readAsBytes();
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/cover_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);
      setState(() => _selectedCover = tempFile);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'image_upload_failed'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show logo picker dialog
  void _showLogoPicker() {
    Get.dialog(
      AlertDialog(
        title: Text('select_image_source'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                _pickLogo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                _pickLogo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show cover picker dialog
  void _showCoverPicker() {
    Get.dialog(
      AlertDialog(
        title: Text('select_image_source'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                _pickCover(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                _pickCover(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Open location picker
  void _openLocationPicker() {
    Get.to(() => LocationPickerWidget(
      initialLatitude: _latitude,
      initialLongitude: _longitude,
      onLocationSelected: (latitude, longitude) {
        setState(() {
          _latitude = latitude;
          _longitude = longitude;
        });
      },
    ));
  }

  /// Save changes
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload logo if changed
      if (_selectedLogo != null) {
        final logoSuccess = await _profileService.uploadRestaurantLogo(_selectedLogo!);
        if (!logoSuccess) {
          Get.snackbar('error'.tr, 'logo_upload_failed'.tr, backgroundColor: Colors.red, colorText: Colors.white);
          setState(() => _isLoading = false);
          return;
        }
      }

      // Upload cover if changed
      if (_selectedCover != null) {
        final coverSuccess = await _profileService.uploadRestaurantCover(_selectedCover!);
        if (!coverSuccess) {
          Get.snackbar('error'.tr, 'cover_upload_failed'.tr, backgroundColor: Colors.red, colorText: Colors.white);
          setState(() => _isLoading = false);
          return;
        }
      }

      // Update restaurant info
      final success = await _profileService.updateRestaurantInfo(
        businessNameEn: _businessNameEnController.text.trim(),
        businessNameAr: _businessNameArController.text.trim(),
        descriptionEn: _descriptionEnController.text.trim(),
        descriptionAr: _descriptionArController.text.trim(),
        addressEn: _addressEnController.text.trim(),
        addressAr: _addressArController.text.trim(),
        businessType: _selectedBusinessType,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );

      setState(() => _isLoading = false);

      if (success) {
        Get.snackbar(
          'success'.tr,
          'restaurant_info_updated_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: true);
      } else {
        Get.snackbar(
          'error'.tr,
          'restaurant_info_update_failed'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('error'.tr, e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildCoverSection(),
                      Transform.translate(
                        offset: const Offset(0, -60),
                        child: Column(
                          children: [
                            _buildLogoSection(),
                            const SizedBox(height: 24),
                            _buildBasicInfoSection(),
                            _buildContactInfoSection(),
                            _buildLocationSection(),
                            _buildBusinessDetailsSection(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textDarkColor),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'restaurant_info'.tr,
        style: const TextStyle(
          color: AppColors.textDarkColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCoverSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.greyColor,
        image: _selectedCover != null
            ? DecorationImage(image: FileImage(_selectedCover!), fit: BoxFit.cover)
            : _currentCoverUrl != null
                ? DecorationImage(image: NetworkImage(_currentCoverUrl!), fit: BoxFit.cover)
                : null,
      ),
      child: Stack(
        children: [
          // Placeholder icon when no cover
          if (_selectedCover == null && _currentCoverUrl == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'add_cover_photo'.tr,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Edit cover button
          Positioned(
            bottom: 16,
            right: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
              child: InkWell(
                onTap: _showCoverPicker,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt, size: 18, color: AppColors.textDarkColor),
                      const SizedBox(width: 6),
                      Text(
                        'edit_cover'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDarkColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build logo section (overlapping cover)
  Widget _buildLogoSection() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Logo circle with shadow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 58,
              backgroundColor: AppColors.greyColor,
              backgroundImage: _selectedLogo != null
                  ? FileImage(_selectedLogo!) as ImageProvider
                  : _currentLogoUrl != null
                      ? NetworkImage(_currentLogoUrl!) as ImageProvider
                      : null,
              child: _selectedLogo == null && _currentLogoUrl == null
                  ? Text(
                      _businessNameEnController.text.isNotEmpty
                          ? _businessNameEnController.text[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        color: AppColors.textDarkColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),

          // Edit button (yellow circle with camera icon)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _showLogoPicker,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.textDarkColor,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'basic_information'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessNameEnController,
            label: 'business_name_en'.tr,
            hint: 'business_name_en'.tr,
            icon: Icons.business,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _businessNameArController,
            label: 'business_name_ar'.tr,
            hint: 'business_name_ar'.tr,
            icon: Icons.business,
          ),
          const SizedBox(height: 12),
          _buildBusinessTypeDropdown(),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'contact_info'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildPhoneField(),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: 'email'.tr,
            hint: 'email'.tr,
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'location'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressEnController,
            label: 'address_en'.tr,
            hint: 'address_en'.tr,
            icon: Icons.location_on,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _addressArController,
            label: 'address_ar'.tr,
            hint: 'address_ar'.tr,
            icon: Icons.location_on,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'city'.tr,
                  hint: 'city'.tr,
                  icon: Icons.location_city,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _areaController,
                  label: 'area'.tr,
                  hint: 'area'.tr,
                  icon: Icons.map,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Google Map Location Picker
          InkWell(
            onTap: _openLocationPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.greyColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: AppColors.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'select_location_on_map'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDarkColor,
                          ),
                        ),
                        if (_latitude != null && _longitude != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${'latitude'.tr}: ${_latitude!.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${'longitude'.tr}: ${_longitude!.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          Text(
                            'tap_to_select_location'.tr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'business_details'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionEnController,
            label: 'description_en'.tr,
            hint: 'description_en'.tr,
            icon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _descriptionArController,
            label: 'description_ar'.tr,
            hint: 'description_ar'.tr,
            icon: Icons.description,
            maxLines: 3,
          ),
        ],
      ),
    );
  }



  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  /// Build phone field with country code dropdown
  Widget _buildPhoneField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Code (Read-only)
        SizedBox(
          width: 90,
          child: TextFormField(
            initialValue: _selectedCountryCode,
            readOnly: true,
            enabled: false,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textDarkColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.greyColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.greyColor),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.greyColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              filled: true,
              fillColor: AppColors.surfaceColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Phone Number TextField
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'phone_number'.tr,
              hintText: 'enter_phone_number'.tr,
              prefixIcon: const Icon(Icons.phone, color: AppColors.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.greyColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.greyColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null; // Optional field
              }
              // Remove any spaces or special characters
              final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
              // Must be exactly 9 digits for Saudi Arabia
              if (cleanValue.length != 9) {
                return 'phone_validation_error'.tr;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBusinessType,
      decoration: InputDecoration(
        labelText: 'business_type'.tr,
        prefixIcon: const Icon(Icons.category, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
      items: _businessTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(_getBusinessTypeLabel(type)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedBusinessType = value);
      },
    );
  }

  String _getBusinessTypeLabel(String type) {
    final labels = {
      'restaurant': Get.locale?.languageCode == 'ar' ? 'مطعم' : 'Restaurant',
      'cafe': Get.locale?.languageCode == 'ar' ? 'مقهى' : 'Cafe',
      'bakery': Get.locale?.languageCode == 'ar' ? 'مخبز' : 'Bakery',
      'fastfood': Get.locale?.languageCode == 'ar' ? 'وجبات سريعة' : 'Fast Food',
      'pizza': Get.locale?.languageCode == 'ar' ? 'بيتزا' : 'Pizza',
      'seafood': Get.locale?.languageCode == 'ar' ? 'مأكولات بحرية' : 'Seafood',
      'dessert': Get.locale?.languageCode == 'ar' ? 'حلويات' : 'Dessert',
      'juice': Get.locale?.languageCode == 'ar' ? 'عصائر' : 'Juice',
      'grocery': Get.locale?.languageCode == 'ar' ? 'بقالة' : 'Grocery',
      'pharmacy': Get.locale?.languageCode == 'ar' ? 'صيدلية' : 'Pharmacy',
    };
    return labels[type] ?? type;
  }

  Widget _buildSaveButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.textDarkColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDarkColor),
                  ),
                )
              : Text(
                  'save_changes'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

