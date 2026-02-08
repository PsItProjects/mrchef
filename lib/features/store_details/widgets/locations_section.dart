import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import '../../../core/services/toast_service.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationsSection extends GetView<StoreDetailsController> {
  const LocationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF262626)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'location'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Show loading indicator while fetching data
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        // Show empty state if no location data
        if (controller.locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_off,
                  size: 64,
                  color: AppColors.textMediumColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'no_location_available'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: AppColors.textMediumColor,
                  ),
                ),
              ],
            ),
          );
        }

        final location = controller.locations[0];
        final latitude = location['latitude'] as double?;
        final longitude = location['longitude'] as double?;
        final address = location['address'] as String? ?? '';

        // If no coordinates, show error
        if (latitude == null || longitude == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_off,
                  size: 64,
                  color: AppColors.textMediumColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'invalid_location_data'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: AppColors.textMediumColor,
                  ),
                ),
              ],
            ),
          );
        }

        final LatLng storeLocation = LatLng(latitude, longitude);

        return Column(
          children: [
            // Google Map
            Expanded(
              flex: 3,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: storeLocation,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('store_location'),
                    position: storeLocation,
                    infoWindow: InfoWindow(
                      title: controller.storeName.value,
                      snippet: address,
                    ),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: false, // Disable double-tap zoom
                scrollGesturesEnabled: true, // Allow drag/pan
                rotateGesturesEnabled: false, // Disable rotation
                tiltGesturesEnabled: false, // Disable tilt
                mapType: MapType.normal,
              ),
            ),

            // Address Card
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'store_address'.tr,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF262626),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Address Text
                    Text(
                      address,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),

                    const Spacer(),

                    // Open in Maps Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _openInMaps(latitude, longitude),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.directions,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'open_in_maps'.tr,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Open location in Google Maps or Apple Maps
  Future<void> _openInMaps(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ToastService.showError('could_not_open_maps'.tr);
    }
  }
}

