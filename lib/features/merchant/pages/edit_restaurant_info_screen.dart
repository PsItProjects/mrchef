import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/services/merchant_profile_service.dart';
import 'package:mrsheaf/features/merchant/pages/image_crop_screen.dart';
import 'package:mrsheaf/features/merchant/widgets/location_picker_widget.dart';
import '../../../core/services/toast_service.dart';

class EditRestaurantInfoScreen extends StatefulWidget {
  const EditRestaurantInfoScreen({Key? key}) : super(key: key);

  @override
  State<EditRestaurantInfoScreen> createState() =>
      _EditRestaurantInfoScreenState();
}

class _EditRestaurantInfoScreenState extends State<EditRestaurantInfoScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final MerchantProfileService _profileService = MerchantProfileService();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers
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
  late TextEditingController _deliveryFeeController;
  late TextEditingController _serviceFeeController;

  // Delivery fee type
  String _selectedDeliveryFeeType = 'negotiable';

  // Image state
  File? _selectedLogo;
  File? _selectedCover;
  String? _currentLogoUrl;
  String? _currentCoverUrl;

  // Business type
  final List<String> _businessTypes = [
    'restaurant', 'cafe', 'bakery', 'fastfood', 'pizza',
    'seafood', 'dessert', 'juice', 'grocery', 'pharmacy',
  ];
  String? _selectedBusinessType;
  final String _selectedCountryCode = '+966';

  // Location
  double? _latitude;
  double? _longitude;

  bool _isLoading = false;
  int _activeTab = 0;

  // Tab controller
  late TabController _tabController;
  final List<_TabItem> _tabs = [
    _TabItem(key: 'basic_info', icon: Icons.storefront_rounded),
    _TabItem(key: 'contact_info', icon: Icons.contact_phone_rounded),
    _TabItem(key: 'location', icon: Icons.place_rounded),
    _TabItem(key: 'fees_and_pricing', icon: Icons.payments_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeTab = _tabController.index);
      }
    });
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
    _deliveryFeeController = TextEditingController();
    _serviceFeeController = TextEditingController();
  }

  Future<void> _loadRestaurantData({bool forceRefresh = false}) async {
    try {
      final data = await _profileService.getProfile();
      if (data != null) {
        final merchant = data['merchant'];
        final restaurant = merchant?['restaurant'];
        if (restaurant != null) {
          setState(() {
            final businessName = restaurant['business_name'];
            if (businessName is Map) {
              _businessNameArController.text =
                  businessName['ar'] ?? businessName['current'] ?? '';
              _businessNameEnController.text =
                  businessName['en'] ?? businessName['current'] ?? '';
            } else if (businessName is String) {
              _businessNameArController.text = businessName;
              _businessNameEnController.text = businessName;
            }

            final description = restaurant['description'];
            if (description is Map) {
              _descriptionArController.text =
                  description['ar'] ?? description['current'] ?? '';
              _descriptionEnController.text =
                  description['en'] ?? description['current'] ?? '';
            } else if (description is String) {
              _descriptionArController.text = description;
              _descriptionEnController.text = description;
            }

            final address = restaurant['address'];
            if (address is Map) {
              _addressArController.text =
                  address['ar'] ?? address['current'] ?? '';
              _addressEnController.text =
                  address['en'] ?? address['current'] ?? '';
            } else if (address is String) {
              _addressArController.text = address;
              _addressEnController.text = address;
            }

            _phoneController.text = restaurant['phone']?.toString() ?? '';
            _emailController.text = restaurant['email']?.toString() ?? '';
            _cityController.text = restaurant['city']?.toString() ?? '';
            _areaController.text = restaurant['area']?.toString() ?? '';
            _selectedBusinessType = restaurant['type']?.toString();

            _latitude = restaurant['latitude'] != null
                ? double.tryParse(restaurant['latitude'].toString())
                : null;
            _longitude = restaurant['longitude'] != null
                ? double.tryParse(restaurant['longitude'].toString())
                : null;

            _currentLogoUrl = restaurant['logo']?.toString();
            _currentCoverUrl = restaurant['cover_image']?.toString();

            _selectedDeliveryFeeType =
                restaurant['delivery_fee_type']?.toString() ?? 'negotiable';
            _deliveryFeeController.text =
                restaurant['delivery_fee']?.toString() ?? '';
            _serviceFeeController.text =
                restaurant['service_fee']?.toString() ?? '';
          });
        }
      }
    } catch (e) {
      print('❌ Error loading restaurant data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    _deliveryFeeController.dispose();
    _serviceFeeController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  IMAGE PICKERS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _pickLogo(ImageSource source) async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: source, imageQuality: 100);
      if (image == null) return;
      final Uint8List imageBytes = await image.readAsBytes();
      final Uint8List? croppedImage = await Get.to<Uint8List>(
        () => ImageCropScreen(imageData: imageBytes),
        transition: Transition.cupertino,
      );
      if (croppedImage != null) {
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/logo_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(croppedImage);
        setState(() => _selectedLogo = tempFile);
      }
    } catch (e) {
      ToastService.showError('image_upload_failed'.tr);
    }
  }

  Future<void> _pickCover(ImageSource source) async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: source, imageQuality: 100);
      if (image == null) return;
      final Uint8List imageBytes = await image.readAsBytes();
      final tempDir = Directory.systemTemp;
      final tempFile = File(
          '${tempDir.path}/cover_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);
      setState(() => _selectedCover = tempFile);
    } catch (e) {
      ToastService.showError('image_upload_failed'.tr);
    }
  }

  void _showImagePicker({required bool isLogo}) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'select_image_source'.tr,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _imageSourceBtn(
                    icon: Icons.camera_alt_rounded,
                    label: 'camera'.tr,
                    onTap: () {
                      Get.back();
                      isLogo
                          ? _pickLogo(ImageSource.camera)
                          : _pickCover(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _imageSourceBtn(
                    icon: Icons.photo_library_rounded,
                    label: 'gallery'.tr,
                    onTap: () {
                      Get.back();
                      isLogo
                          ? _pickLogo(ImageSource.gallery)
                          : _pickCover(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceBtn(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFFF7F8FC),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.25),
                      AppColors.primaryColor.withOpacity(0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(icon, size: 26, color: AppColors.secondaryColor),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LOCATION
  // ═══════════════════════════════════════════════════════════════

  Future<void> _openLocationPicker() async {
    final result = await showLocationPickerBottomSheet(
      context: context,
      initialLatitude: _latitude,
      initialLongitude: _longitude,
    );
    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  SAVE
  // ═══════════════════════════════════════════════════════════════

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_selectedLogo != null) {
        final ok =
            await _profileService.uploadRestaurantLogo(_selectedLogo!);
        if (!ok) {
          ToastService.showError('logo_upload_failed'.tr);
          setState(() => _isLoading = false);
          return;
        }
      }
      if (_selectedCover != null) {
        final ok =
            await _profileService.uploadRestaurantCover(_selectedCover!);
        if (!ok) {
          ToastService.showError('cover_upload_failed'.tr);
          setState(() => _isLoading = false);
          return;
        }
      }

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
        deliveryFeeType: _selectedDeliveryFeeType,
        deliveryFee: _selectedDeliveryFeeType == 'fixed'
            ? double.tryParse(_deliveryFeeController.text.trim())
            : (_selectedDeliveryFeeType == 'free' ? 0.0 : null),
        serviceFee: double.tryParse(_serviceFeeController.text.trim()),
      );
      setState(() => _isLoading = false);
      if (success) {
        ToastService.showSuccess('restaurant_info_updated_successfully'.tr);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: true);
      } else {
        ToastService.showError('restaurant_info_update_failed'.tr);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ToastService.showError(e.toString());
    }
  }

  // ─── helper: display business name based on locale ───
  String get _displayName {
    final isAr = Get.locale?.languageCode == 'ar';
    final name = isAr
        ? _businessNameArController.text
        : _businessNameEnController.text;
    return name.isNotEmpty ? name : 'restaurant_info'.tr;
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: Column(
        children: [
          // ── IMMERSIVE HEADER (cover + logo + name + tabs) ──
          _buildHeroHeader(context),

          // ── TAB CONTENT ──
          Expanded(
            child: Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicInfoTab(),
                  _buildContactInfoTab(),
                  _buildLocationTab(),
                  _buildFeesTab(),
                ],
              ),
            ),
          ),

          // ── SAVE BUTTON ──
          _buildSaveButton(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HERO HEADER
  //  Cover → Logo (centered, overlapping) → Name + Type → Tabs
  //  Everything inside one white-backed container with smooth curve
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    const double coverH = 180;
    const double logoR = 52; // radius
    const double logoD = logoR * 2; // diameter
    const double logoOverlap = logoR; // half hangs below cover

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── COVER + LOGO STACK ──
          SizedBox(
            height: coverH + topPad + logoOverlap + 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // cover image
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: coverH + topPad,
                  child: GestureDetector(
                    onTap: () => _showImagePicker(isLogo: false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        image: _selectedCover != null
                            ? DecorationImage(
                                image: FileImage(_selectedCover!),
                                fit: BoxFit.cover)
                            : _currentCoverUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_currentCoverUrl!),
                                    fit: BoxFit.cover)
                                : null,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.4, 1.0],
                            colors: [
                              Colors.black.withOpacity(0.50),
                              Colors.transparent,
                              Colors.black.withOpacity(0.40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // top bar — back + edit-cover
                Positioned(
                  top: topPad + 4,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      _frostedButton(
                          Icons.arrow_back_rounded, () => Get.back()),
                      const Spacer(),
                      _frostedButton(Icons.camera_alt_rounded,
                          () => _showImagePicker(isLogo: false)),
                    ],
                  ),
                ),

                // logo — centred, overlapping
                Positioned(
                  top: coverH + topPad - logoR,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _showImagePicker(isLogo: true),
                      child: Container(
                        width: logoD,
                        height: logoD,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryColor
                                  .withOpacity(0.18),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: logoR,
                              backgroundColor: const Color(0xFFF4F5F9),
                              backgroundImage: _selectedLogo != null
                                  ? FileImage(_selectedLogo!)
                                      as ImageProvider
                                  : _currentLogoUrl != null
                                      ? NetworkImage(_currentLogoUrl!)
                                          as ImageProvider
                                      : null,
                              child: (_selectedLogo == null &&
                                      _currentLogoUrl == null)
                                  ? Icon(Icons.restaurant_rounded,
                                      size: 34,
                                      color: Colors.grey[350])
                                  : null,
                            ),
                            // camera badge
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withOpacity(0.12),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: AppColors.textDarkColor,
                                    size: 13),
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
          ),

          // ── RESTAURANT NAME + TYPE ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Column(
              children: [
                Text(
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDarkColor,
                    letterSpacing: -0.3,
                  ),
                ),
                if (_selectedBusinessType != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getBusinessTypeLabel(_selectedBusinessType!),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            AppColors.secondaryColor.withOpacity(0.75),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── PILL TAB BAR ──
          _buildPillTabBar(),

          const SizedBox(height: 2),
        ],
      ),
    );
  }

  // ── Frosted glass back / camera button ──
  Widget _frostedButton(IconData icon, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withOpacity(0.15),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Icon(icon, color: Colors.white, size: 21),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PILL TAB BAR
  //  Horizontally scrollable pills with icon + label
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPillTabBar() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = _activeTab == i;
          return GestureDetector(
            onTap: () => _tabController.animateTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.secondaryColor
                    : const Color(0xFFF0F1F6),
                borderRadius: BorderRadius.circular(24),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color:
                              AppColors.secondaryColor.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    _tabs[i].icon,
                    size: 16,
                    color: active
                        ? AppColors.primaryColor
                        : Colors.grey[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tabs[i].key.tr,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 1 — BASIC INFO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBasicInfoTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        _sectionCard(
          icon: Icons.storefront_rounded,
          title: 'basic_information'.tr,
          children: [
            _field(
                controller: _businessNameEnController,
                label: 'business_name_en'.tr,
                icon: Icons.badge_outlined),
            _field(
                controller: _businessNameArController,
                label: 'business_name_ar'.tr,
                icon: Icons.badge_outlined),
            _buildBusinessTypeDropdown(),
          ],
        ),
        const SizedBox(height: 14),
        _sectionCard(
          icon: Icons.article_rounded,
          title: 'business_details'.tr,
          children: [
            _field(
                controller: _descriptionEnController,
                label: 'description_en'.tr,
                icon: Icons.notes_rounded,
                maxLines: 3),
            _field(
                controller: _descriptionArController,
                label: 'description_ar'.tr,
                icon: Icons.notes_rounded,
                maxLines: 3),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 2 — CONTACT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildContactInfoTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        _sectionCard(
          icon: Icons.contact_phone_rounded,
          title: 'contact_info'.tr,
          children: [
            _buildPhoneField(),
            _field(
                controller: _emailController,
                label: 'email'.tr,
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 3 — LOCATION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLocationTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        _sectionCard(
          icon: Icons.place_rounded,
          title: 'location'.tr,
          children: [
            _field(
                controller: _addressEnController,
                label: 'address_en'.tr,
                icon: Icons.pin_drop_outlined,
                maxLines: 2),
            _field(
                controller: _addressArController,
                label: 'address_ar'.tr,
                icon: Icons.pin_drop_outlined,
                maxLines: 2),
            Row(
              children: [
                Expanded(
                    child: _field(
                        controller: _cityController,
                        label: 'city'.tr,
                        icon: Icons.location_city_outlined,
                        bottomSpacing: false)),
                const SizedBox(width: 10),
                Expanded(
                    child: _field(
                        controller: _areaController,
                        label: 'area'.tr,
                        icon: Icons.map_outlined,
                        bottomSpacing: false)),
              ],
            ),
            const SizedBox(height: 14),
            _buildMapPickerTile(),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TAB 4 — FEES & PRICING
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFeesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        // ── Delivery Fee Type Section ──
        _sectionCard(
          icon: Icons.delivery_dining_rounded,
          title: 'delivery_fee_type'.tr,
          children: [
            _deliveryFeeTypeOption(
              value: 'negotiable',
              label: 'delivery_fee_negotiable'.tr,
              icon: Icons.handshake_rounded,
              description: Get.locale?.languageCode == 'ar'
                  ? 'سيتم الاتفاق على رسوم التوصيل مع العميل عند قبول الطلب'
                  : 'Delivery fee will be agreed with customer when accepting the order',
            ),
            const SizedBox(height: 8),
            _deliveryFeeTypeOption(
              value: 'free',
              label: 'delivery_fee_free'.tr,
              icon: Icons.card_giftcard_rounded,
              description: Get.locale?.languageCode == 'ar'
                  ? 'التوصيل مجاني لجميع الطلبات'
                  : 'Free delivery for all orders',
            ),
            const SizedBox(height: 8),
            _deliveryFeeTypeOption(
              value: 'fixed',
              label: 'delivery_fee_fixed'.tr,
              icon: Icons.price_check_rounded,
              description: Get.locale?.languageCode == 'ar'
                  ? 'مبلغ ثابت يُطبق على جميع الطلبات'
                  : 'A fixed amount applied to all orders',
            ),
            // Fixed fee input — only visible when type is 'fixed'
            if (_selectedDeliveryFeeType == 'fixed') ...[
              const SizedBox(height: 14),
              _feeField(
                controller: _deliveryFeeController,
                label: 'delivery_fee'.tr,
                hint: 'enter_delivery_fee'.tr,
                icon: Icons.delivery_dining_rounded,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        // ── Service Fee Section ──
        _sectionCard(
          icon: Icons.miscellaneous_services_rounded,
          title: 'service_fee'.tr,
          children: [
            _feeField(
              controller: _serviceFeeController,
              label: 'service_fee'.tr,
              hint: 'enter_service_fee'.tr,
              icon: Icons.miscellaneous_services_rounded,
            ),
            // Tip banner
            _tipBanner(
              Get.locale?.languageCode == 'ar'
                  ? 'رسوم الخدمة اختيارية وستظهر للعميل عند الطلب. اتركها فارغة لعدم تطبيق رسوم.'
                  : 'Service fee is optional and will be shown to customers. Leave empty for no fees.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _deliveryFeeTypeOption({
    required String value,
    required String label,
    required IconData icon,
    required String description,
  }) {
    final isSelected = _selectedDeliveryFeeType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedDeliveryFeeType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.secondaryColor
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.secondaryColor
                          : AppColors.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.06),
            AppColors.primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.primaryColor.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline_rounded,
                size: 14,
                color: AppColors.secondaryColor.withOpacity(0.7)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.secondaryColor.withOpacity(0.60),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SECTION CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.secondaryColor.withOpacity(0.10),
                        AppColors.primaryColor.withOpacity(0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      size: 19, color: AppColors.secondaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDarkColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.grey.withOpacity(0.12),
                Colors.transparent,
              ]),
            ),
          ),
          // Children
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TEXT FIELD
  // ═══════════════════════════════════════════════════════════════

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool bottomSpacing = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing ? 12 : 0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(
            fontSize: 14.5, color: AppColors.textDarkColor),
        decoration: _inputDecor(label: label, icon: icon),
        validator: validator,
      ),
    );
  }

  InputDecoration _inputDecor({
    required String label,
    required IconData icon,
    String? hint,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      labelStyle: TextStyle(color: Colors.grey[450], fontSize: 13.5),
      hintStyle: TextStyle(color: Colors.grey[350], fontSize: 13.5),
      suffixStyle: TextStyle(
        color: AppColors.secondaryColor.withOpacity(0.5),
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon,
            color: AppColors.secondaryColor.withOpacity(0.5),
            size: 19),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 46),
      filled: true,
      fillColor: const Color(0xFFF7F8FC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primaryColor, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 2)),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  FEE FIELD
  // ═══════════════════════════════════════════════════════════════

  Widget _feeField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
        ],
        style: const TextStyle(
          fontSize: 14.5,
          color: AppColors.textDarkColor,
          fontWeight: FontWeight.w600,
        ),
        decoration:
            _inputDecor(label: label, hint: hint, icon: icon, suffix: 'sar'.tr),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PHONE FIELD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '+966',
              style: TextStyle(
                fontSize: 14.5,
                color: AppColors.textDarkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                  fontSize: 14.5, color: AppColors.textDarkColor),
              decoration: _inputDecor(
                label: 'phone_number'.tr,
                icon: Icons.phone_outlined,
                hint: 'enter_phone_number'.tr,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                if (v.replaceAll(RegExp(r'[^\d]'), '').length != 9) {
                  return 'phone_validation_error'.tr;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUSINESS TYPE DROPDOWN
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBusinessTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBusinessType,
      isExpanded: true,
      style: const TextStyle(
          fontSize: 14.5, color: AppColors.textDarkColor),
      decoration:
          _inputDecor(label: 'business_type'.tr, icon: Icons.category_outlined),
      items: _businessTypes
          .map((type) => DropdownMenuItem(
              value: type, child: Text(_getBusinessTypeLabel(type))))
          .toList(),
      onChanged: (v) => setState(() => _selectedBusinessType = v),
    );
  }

  String _getBusinessTypeLabel(String type) {
    final labels = {
      'restaurant':
          Get.locale?.languageCode == 'ar' ? 'مطعم' : 'Restaurant',
      'cafe': Get.locale?.languageCode == 'ar' ? 'مقهى' : 'Cafe',
      'bakery': Get.locale?.languageCode == 'ar' ? 'مخبز' : 'Bakery',
      'fastfood':
          Get.locale?.languageCode == 'ar' ? 'وجبات سريعة' : 'Fast Food',
      'pizza': Get.locale?.languageCode == 'ar' ? 'بيتزا' : 'Pizza',
      'seafood':
          Get.locale?.languageCode == 'ar' ? 'مأكولات بحرية' : 'Seafood',
      'dessert':
          Get.locale?.languageCode == 'ar' ? 'حلويات' : 'Dessert',
      'juice': Get.locale?.languageCode == 'ar' ? 'عصائر' : 'Juice',
      'grocery': Get.locale?.languageCode == 'ar' ? 'بقالة' : 'Grocery',
      'pharmacy':
          Get.locale?.languageCode == 'ar' ? 'صيدلية' : 'Pharmacy',
    };
    return labels[type] ?? type;
  }

  // ═══════════════════════════════════════════════════════════════
  //  MAP PICKER TILE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMapPickerTile() {
    final bool has = _latitude != null && _longitude != null;
    return Material(
      color: has ? const Color(0xFFF0FAF4) : const Color(0xFFF7F8FC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _openLocationPicker,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: has
                    ? Colors.green.withOpacity(0.25)
                    : Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: has
                      ? Colors.green.withOpacity(0.12)
                      : AppColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  has
                      ? Icons.check_circle_rounded
                      : Icons.add_location_alt_rounded,
                  color: has ? Colors.green : AppColors.secondaryColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'select_location_on_map'.tr,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: has
                            ? Colors.green[700]
                            : AppColors.textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      has
                          ? '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
                          : 'tap_to_select_location'.tr,
                      style: TextStyle(
                          fontSize: 11.5, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey[400], size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SAVE BUTTON
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSaveButton() {
    final bot = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bot + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.textDarkColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textDarkColor),
                  ),
                )
              : Text(
                  'save_changes'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB ITEM MODEL
// ═══════════════════════════════════════════════════════════════

class _TabItem {
  final String key;
  final IconData icon;
  const _TabItem({required this.key, required this.icon});
}

