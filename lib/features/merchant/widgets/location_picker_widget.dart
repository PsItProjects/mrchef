import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/toast_service.dart';

/// Shows a bottom sheet modal for location selection
/// Returns a Map with 'latitude' and 'longitude' keys when location is selected
Future<Map<String, double>?> showLocationPickerBottomSheet({
  required BuildContext context,
  double? initialLatitude,
  double? initialLongitude,
}) {
  return showModalBottomSheet<Map<String, double>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: false, // Disable default drag - we'll handle it manually
    builder: (context) => LocationPickerWidget(
      initialLatitude: initialLatitude,
      initialLongitude: initialLongitude,
    ),
  );
}

class LocationPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerWidget({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
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
      ToastService.showError('please_enter_search_query'.tr);
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
        ToastService.showError('location_not_found'.tr);
      }
    } catch (e) {
      setState(() => _isSearching = false);
      ToastService.showError('search_failed'.tr);
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      // Return the selected location as a Map
      Navigator.of(context).pop({
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      });
    } else {
      ToastService.showError('location_not_selected'.tr);
    }
  }

  /// Move camera to user's current location
  Future<void> _goToMyLocation() async {
    if (_mapController != null && _selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  /// Zoom in on the map
  Future<void> _zoomIn() async {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  /// Zoom out on the map
  Future<void> _zoomOut() async {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  /// Build a custom map control button with Marvel/Iron Man theme
  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9, // 90% of screen height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle - only this area can dismiss the bottom sheet
          GestureDetector(
            onVerticalDragUpdate: (details) {
              // If dragging down, dismiss the bottom sheet
              if (details.delta.dy > 5) {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textDarkColor),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'select_location_on_map'.tr,
                    style: const TextStyle(
                      color: AppColors.textDarkColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _confirmLocation,
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(
                    'confirm'.tr,
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textDarkColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(100, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Map content
          Expanded(
            child: _isLoading
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
                  myLocationButtonEnabled: false, // We'll use custom button
                  zoomControlsEnabled: false, // We'll use custom buttons
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

                // Custom Map Controls - Right Side
                Positioned(
                  right: 16,
                  top: 100,
                  child: Column(
                    children: [
                      // Zoom In Button
                      _buildMapControlButton(
                        icon: Icons.add,
                        onPressed: _zoomIn,
                      ),
                      const SizedBox(height: 8),
                      // Zoom Out Button
                      _buildMapControlButton(
                        icon: Icons.remove,
                        onPressed: _zoomOut,
                      ),
                      const SizedBox(height: 16),
                      // My Location Button
                      _buildMapControlButton(
                        icon: Icons.my_location,
                        onPressed: _goToMyLocation,
                      ),
                    ],
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

