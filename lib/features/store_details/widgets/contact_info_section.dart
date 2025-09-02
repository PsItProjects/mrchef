import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class ContactInfoSection extends GetView<StoreDetailsController> {
  const ContactInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:30',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: 0.14,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  Container(width: 46, height: 17), // Placeholder for status icons
                ],
              ),
            ),
            
            // Header
            Container(
              width: 380,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      'assets/icons/arrow_left.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF262626),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  
                  Text(
                    'contact_information'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF262626),
                    ),
                  ),
                  
                  SvgPicture.asset(
                    'assets/icons/more.svg',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ),
            
            // Contact options
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // Phone contact
                    _buildContactCard(
                      icon: 'assets/icons/phone.svg',
                      title: 'phone_number'.tr,
                      subtitle: controller.contactInfo['phone'],
                      onTap: () => controller.callStore(),
                    ),

                    const SizedBox(height: 16),

                    // Email contact
                    _buildContactCard(
                      icon: 'assets/icons/email.svg',
                      title: 'email'.tr,
                      subtitle: controller.contactInfo['email'],
                      onTap: () => controller.emailStore(),
                    ),

                    const SizedBox(height: 16),

                    // WhatsApp contact
                    _buildContactCard(
                      icon: 'assets/icons/whatsapp.svg',
                      title: 'whatsapp'.tr,
                      subtitle: controller.contactInfo['whatsapp'],
                      onTap: () => controller.openWhatsApp(),
                      isWhatsApp: true,
                    ),

                    const SizedBox(height: 16),

                    // Facebook contact
                    _buildContactCard(
                      icon: 'assets/icons/facebook.svg',
                      title: 'facebook'.tr,
                      subtitle: controller.contactInfo['facebook'],
                      onTap: () => controller.openFacebook(),
                      isFacebook: true,
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom navigation
            Container(
              height: 28,
              child: Container(
                width: 72,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 178),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isWhatsApp = false,
    bool isFacebook = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE3E3E3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 18,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 24,
              height: 24,
              child: isWhatsApp
                  ? _buildWhatsAppIcon()
                  : isFacebook
                      ? _buildFacebookIcon()
                      : SvgPicture.asset(
                          icon,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF212121),
                            BlendMode.srcIn,
                          ),
                        ),
            ),
            
            const SizedBox(width: 8),
            
            // Contact info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF262626),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppIcon() {
    return Container(
      width: 24,
      height: 24.19,
      child: Stack(
        children: [
          // WhatsApp background gradient
          Container(
            width: 24,
            height: 24.11,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF60D669),
                  Color(0xFF1FAF38),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // WhatsApp logo
          Positioned(
            left: 5.98,
            top: 6.43,
            child: Container(
              width: 12.14,
              height: 11.26,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacebookIcon() {
    return Container(
      width: 24,
      height: 24,
      child: Stack(
        children: [
          // Facebook background
          Container(
            width: 24,
            height: 23.85,
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // Facebook logo
          Positioned(
            left: 7.08,
            top: 4.69,
            child: Container(
              width: 10.27,
              height: 19.31,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
