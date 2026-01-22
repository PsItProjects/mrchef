import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/services/merchant_profile_service.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/merchant/pages/image_crop_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_settings_screen.dart';
import '../../../core/services/toast_service.dart';

class EditPersonalProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? profileData;

  const EditPersonalProfileScreen({Key? key, this.profileData}) : super(key: key);

  @override
  State<EditPersonalProfileScreen> createState() => _EditPersonalProfileScreenState();
}

class _EditPersonalProfileScreenState extends State<EditPersonalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = Get.find<MerchantProfileService>();
  final _imagePicker = ImagePicker();

  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _emailController;

  File? _selectedAvatar;
  File? _selectedCover;
  String? _currentAvatarUrl;
  String? _currentCoverUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize empty controllers
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _emailController = TextEditingController();

    // Load profile data
    _loadProfileData();
  }

  /// Load profile data from API
  Future<void> _loadProfileData({bool forceRefresh = false}) async {
    try {
      print('📝 EditProfile: Loading profile data...');

      // If profileData was passed and not forcing refresh, use it
      if (widget.profileData != null && !forceRefresh) {
        _setProfileData(widget.profileData!);
        return;
      }

      // Load from cache/API
      final data = await _profileService.getProfile(forceRefresh: forceRefresh);
      if (data != null) {
        _setProfileData(data);
      } else {
        print('❌ EditProfile: Failed to load profile data');
      }
    } catch (e) {
      print('❌ EditProfile: Error loading profile: $e');
    }
  }

  /// Set profile data to controllers
  void _setProfileData(Map<String, dynamic> data) {
    final merchant = data['merchant'];
    final restaurant = merchant?['restaurant'];
    final name = merchant?['name'];

    print('✅ EditProfile: Setting profile data');
    print('   name: $name');
    print('   email: ${merchant?['email']}');

    // Set text controllers
    final nameAr = name?['ar'] ?? name?['current'] ?? '';
    final nameEn = name?['en'] ?? name?['current'] ?? '';
    final email = merchant?['email'] ?? '';

    setState(() {
      _nameArController.text = nameAr;
      _nameEnController.text = nameEn;
      _emailController.text = email;
      _currentAvatarUrl = merchant?['avatar'];
      _currentCoverUrl = merchant?['cover']; // Merchant cover, not restaurant cover
    });

    print('✅ EditProfile: Data set successfully');
    print('   nameAr: "$nameAr"');
    print('   nameEn: "$nameEn"');
    print('   email: "$email"');
    print('   avatar: ${merchant?['avatar']}');
    print('   cover: ${merchant?['cover']}');
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Pick avatar image
  Future<void> _pickAvatar(ImageSource source) async {
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
        final tempFile = File('${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(croppedImage);
        setState(() => _selectedAvatar = tempFile);
      }
    } catch (e) {
      ToastService.showError(TranslationHelper.tr('image_upload_failed'));
    }
  }

  /// Pick cover image
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
      ToastService.showError(TranslationHelper.tr('image_upload_failed'));
    }
  }

  /// Show avatar picker bottom sheet
  void _showAvatarPicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: Text(TranslationHelper.tr('camera')),
              onTap: () {
                Get.back();
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: Text(TranslationHelper.tr('gallery')),
              onTap: () {
                Get.back();
                _pickAvatar(ImageSource.gallery);
              },
            ),
            if (_currentAvatarUrl != null || _selectedAvatar != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(TranslationHelper.tr('remove_photo')),
                onTap: () {
                  Get.back();
                  setState(() {
                    _selectedAvatar = null;
                    _currentAvatarUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Show cover picker bottom sheet
  void _showCoverPicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: Text(TranslationHelper.tr('camera')),
              onTap: () {
                Get.back();
                _pickCover(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: Text(TranslationHelper.tr('gallery')),
              onTap: () {
                Get.back();
                _pickCover(ImageSource.gallery);
              },
            ),
            if (_currentCoverUrl != null || _selectedCover != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(TranslationHelper.tr('remove_photo')),
                onTap: () {
                  Get.back();
                  setState(() {
                    _selectedCover = null;
                    _currentCoverUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Save changes
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload avatar if changed
      if (_selectedAvatar != null) {
        await _profileService.updateAvatar(_selectedAvatar!);
      }

      // Upload merchant cover if changed
      if (_selectedCover != null) {
        await _profileService.updateMerchantCover(_selectedCover!);
      }

      // Update personal info
      print('📝 Saving personal info: nameAr=${_nameArController.text}, nameEn=${_nameEnController.text}, email=${_emailController.text}');
      await _profileService.updatePersonalInfo(
        nameAr: _nameArController.text,
        nameEn: _nameEnController.text,
        email: _emailController.text,
      );

      // Reload profile data to get updated avatar and cover URLs (force refresh from API)
      print('🔄 Reloading profile data after save...');
      await _loadProfileData(forceRefresh: true);

      // Show success message
      ToastService.showSuccess('profile_updated_successfully'.tr);

      // Wait for toast to show
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to Settings screen (replace all previous screens)
      Get.offUntil(
        GetPageRoute(
          page: () => const MerchantSettingsScreen(),
        ),
        (route) => route.isFirst,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDarkColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          TranslationHelper.tr('edit_profile'),
          style: const TextStyle(
            color: AppColors.textDarkColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover Image Section
            _buildCoverSection(),

            // Avatar Section (overlapping)
            Transform.translate(
              offset: const Offset(0, -60),
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 20),
                  _buildFormSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build cover section (Facebook style)
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
                    TranslationHelper.tr('add_cover_photo'),
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
                        TranslationHelper.tr('edit_cover'),
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

  /// Build avatar section (overlapping cover)
  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar circle with shadow
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
              backgroundImage: _selectedAvatar != null
                  ? FileImage(_selectedAvatar!) as ImageProvider
                  : _currentAvatarUrl != null
                      ? NetworkImage(_currentAvatarUrl!) as ImageProvider
                      : null,
              child: _selectedAvatar == null && _currentAvatarUrl == null
                  ? Text(
                      _nameEnController.text.isNotEmpty ? _nameEnController.text[0].toUpperCase() : '?',
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
                  onTap: _showAvatarPicker,
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

  /// Build form section
  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  TranslationHelper.tr('merchant_personal_info'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Name in Arabic
            _buildTextField(
              controller: _nameArController,
              label: TranslationHelper.tr('name_ar'),
              icon: Icons.person,
              validator: (value) => value?.isEmpty ?? true ? TranslationHelper.tr('field_required') : null,
            ),
            const SizedBox(height: 16),

            // Name in English
            _buildTextField(
              controller: _nameEnController,
              label: TranslationHelper.tr('name_en'),
              icon: Icons.person_outline,
              validator: (value) => value?.isEmpty ?? true ? TranslationHelper.tr('field_required') : null,
            ),
            const SizedBox(height: 16),

            // Email
            _buildTextField(
              controller: _emailController,
              label: TranslationHelper.tr('email'),
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return TranslationHelper.tr('field_required');
                if (!GetUtils.isEmail(value!)) return TranslationHelper.tr('invalid_email');
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56, // زيادة الارتفاع
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          TranslationHelper.tr('save_changes'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  /// Build text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
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
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}

