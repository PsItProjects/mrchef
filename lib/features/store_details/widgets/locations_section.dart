import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class LocationsSection extends GetView<StoreDetailsController> {
  const LocationsSection({super.key});

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
                      color: Color(0xFF262626),
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
                    'location'.tr,
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
            
            // Map and locations
            Expanded(
              child: Stack(
                children: [
                  // Map background (placeholder)
                  Container(
                    width: double.infinity,
                    height: 788,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      image: DecorationImage(
                        image: AssetImage('assets/images/map_background.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  // Location markers and info cards
                  Obx(() => Stack(
                    children: [
                      // First location
                      if (controller.locations.isNotEmpty)
                        _buildLocationMarker(
                          controller.locations[0],
                          const Offset(118, 139),
                        ),
                      
                      // Second location
                      if (controller.locations.length > 1)
                        _buildLocationMarker(
                          controller.locations[1],
                          const Offset(40, 544),
                        ),
                    ],
                  )),
                ],
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
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMarker(Map<String, dynamic> location, Offset position) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Column(
        children: [
          // Location pin
          Container(
            width: 60,
            height: 72,
            child: Stack(
              children: [
                // Pin background
                Container(
                  width: 60,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEA0A2B),
                  ),
                  child: CustomPaint(
                    painter: LocationPinPainter(),
                  ),
                ),
                
                // Store image inside pin
                Positioned(
                  left: 3.54,
                  top: 3.54,
                  child: Container(
                    width: 52.94,
                    height: 52.94,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/store_profile.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Address card
          GestureDetector(
            onTap: () => controller.openLocation(location),
            child: Container(
              width: 197,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                location['address'],
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEA0A2B)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create a location pin shape
    path.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, size.height * 0.4),
      radius: size.width * 0.4,
    ));
    
    // Add the bottom point of the pin
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
