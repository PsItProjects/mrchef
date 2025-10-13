import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';

class ImageCropScreen extends StatefulWidget {
  final Uint8List imageData;
  final bool isCircular;

  const ImageCropScreen({
    super.key,
    required this.imageData,
    this.isCircular = true, // Default to circular for avatars
  });

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final _cropController = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          TranslationHelper.tr('crop_image'),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_isCropping)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => _cropController.crop(),
              child: Text(
                TranslationHelper.tr('done'),
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Cropping area
          Expanded(
            child: Container(
              color: Colors.black,
              child: Crop(
                image: widget.imageData,
                controller: _cropController,
                onCropped: (result) {
                  // Handle crop result
                  if (result is CropSuccess) {
                    setState(() => _isCropping = false);
                    Get.back(result: result.croppedImage);
                  } else if (result is CropFailure) {
                    setState(() => _isCropping = false);
                    Get.snackbar(
                      TranslationHelper.tr('error'),
                      TranslationHelper.tr('crop_failed'),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                aspectRatio: 1.0, // Square crop for profile picture
                baseColor: Colors.black,
                maskColor: Colors.black.withValues(alpha: 0.8),
                // Circular crop UI
                withCircleUi: widget.isCircular,
                // Status callback
                onStatusChanged: (status) {
                  if (status == CropStatus.cropping) {
                    setState(() => _isCropping = true);
                  }
                },
                // Custom corner handles - larger and more visible
                cornerDotBuilder: (size, edgeAlignment) {
                  return Container(
                    width: size * 1.5, // Make handles 50% larger
                    height: size * 1.5,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
                // Enable interactive mode for better UX
                interactive: true,
                // Allow moving the crop area
                fixCropRect: false,
                clipBehavior: Clip.hardEdge,
              ),
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            color: Colors.black,
            child: Column(
              children: [
                // Main instruction
                Text(
                  widget.isCircular
                      ? TranslationHelper.tr('crop_circle_instructions')
                      : TranslationHelper.tr('crop_instructions'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Interactive hints
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Pinch to zoom
                    _buildHintItem(
                      icon: Icons.zoom_out_map,
                      text: TranslationHelper.tr('pinch_to_zoom'),
                    ),
                    // Drag to move
                    _buildHintItem(
                      icon: Icons.pan_tool_outlined,
                      text: TranslationHelper.tr('drag_to_move'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build hint item for instructions
  Widget _buildHintItem({required IconData icon, required String text}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    // CropController doesn't need disposal
    super.dispose();
  }
}

