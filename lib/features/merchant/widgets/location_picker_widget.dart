import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/theme/app_theme.dart';

class LocationPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude) onLocationSelected;

  const LocationPickerWidget({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _selectedAddress;

  // Default location (Riyadh, Saudi Arabia)
  static const LatLng _defaultLocation = LatLng(24.7136, 46.6753);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      if (kDebugMode) {
        print('🗺️ Initializing location picker...');
      }

      // Check if initial location is provided
      if (widget.initialLatitude != null && widget.initialLongitude != null) {
        final initialLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
        if (kDebugMode) {
          print('📍 Using provided location: $initialLocation');
        }
        setState(() {
          _selectedLocation = initialLocation;
          _isLoading = false;
        });
        return;
      }

      // Use default location (Riyadh, Saudi Arabia) as starting point
      if (kDebugMode) {
        print('📍 Using default location (Riyadh, Saudi Arabia): $_defaultLocation');
      }
      setState(() {
        _selectedLocation = _defaultLocation;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing location: $e');
        print('📍 Using default location (Riyadh)');
      }
      setState(() {
        _selectedLocation = _defaultLocation;
        _isLoading = false;
      });
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _selectedAddress = null;
    });
    _getAddressFromLatLng(location);
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address: $e');
      }
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_enter_search_query'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = LatLng(locations[0].latitude, locations[0].longitude);
        setState(() {
          _selectedLocation = location;
          _isSearching = false;
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: location, zoom: 15),
          ),
        );
        _getAddressFromLatLng(location);
      } else {
        setState(() => _isSearching = false);
        Get.snackbar(
          'error'.tr,
          'location_not_found'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _isSearching = false);
      Get.snackbar(
        'error'.tr,
        'search_failed'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      widget.onLocationSelected(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );
      Get.back();
    } else {
      Get.snackbar(
        'error'.tr,
        'location_not_selected'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDarkColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'select_location_on_map'.tr,
          style: const TextStyle(
            color: AppColors.textDarkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _confirmLocation,
            icon: const Icon(Icons.check, color: AppColors.textDarkColor),
            label: Text(
              'confirm_location'.tr,
              style: const TextStyle(
                color: AppColors.textDarkColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? _defaultLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (kDebugMode) {
                      print('🗺️ Map created successfully');
                      print('📍 Initial location: ${_selectedLocation ?? _defaultLocation}');
                    }
                  },
                  onTap: _onMapTapped,
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: _selectedLocation!,
                            draggable: true,
                            onDragEnd: (newPosition) {
                              setState(() {
                                _selectedLocation = newPosition;
                                _selectedAddress = null;
                              });
                              _getAddressFromLatLng(newPosition);
                            },
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                          ),
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  mapType: MapType.normal,
                  minMaxZoomPreference: const MinMaxZoomPreference(5, 20),
                ),
                // Search Bar
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'search_location'.tr,
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.arrow_forward, color: AppColors.primaryColor),
                                onPressed: _searchLocation,
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (_) => _searchLocation(),
                    ),
                  ),
                ),
                // Location Info Card
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'selected_location'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDarkColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_selectedAddress != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _selectedAddress!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textDarkColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (_selectedLocation != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${'latitude'.tr}: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${'longitude'.tr}: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

