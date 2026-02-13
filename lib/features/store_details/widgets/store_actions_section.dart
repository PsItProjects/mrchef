import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class StoreActionsSection extends GetView<StoreDetailsController> {
  const StoreActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          // Message button (primary)
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => controller.sendMessage(),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text(
                  'message'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textDarkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // More / Info button
          SizedBox(
            width: 48,
            height: 48,
            child: OutlinedButton(
              onPressed: () => controller.showStoreInfoBottomSheet(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(
                Icons.more_horiz,
                color: AppColors.textDarkColor,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
