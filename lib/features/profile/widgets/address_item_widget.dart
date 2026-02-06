import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';

class AddressItemWidget extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const AddressItemWidget({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(color: AppColors.primaryColor.withOpacity(0.5), width: 1.5)
            : Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: type badge + default + edit
            Row(
              children: [
                // Type badge with icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getTypeBadgeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getTypeIcon(), size: 14, color: _getTypeBadgeColor()),
                      const SizedBox(width: 4),
                      Text(
                        address.typeDisplayName,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: _getTypeBadgeColor(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Default badge
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: AppColors.primaryColor),
                        const SizedBox(width: 3),
                        Text(
                          'default_address'.tr,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: AppColors.primaryColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Edit and delete buttons
                _buildIconButton(
                  icon: Icons.edit_outlined,
                  onTap: onEdit,
                  color: const Color(0xFF5E5E5E),
                ),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: Icons.delete_outline,
                  onTap: onDelete,
                  color: const Color(0xFFEB5757),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Address text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address.fullAddress,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Color(0xFF5E5E5E),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeBadgeColor() {
    switch (address.type) {
      case AddressType.home:
        return const Color(0xFF4CAF50);
      case AddressType.work:
        return const Color(0xFF2196F3);
      case AddressType.other:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getTypeIcon() {
    switch (address.type) {
      case AddressType.home:
        return Icons.home_rounded;
      case AddressType.work:
        return Icons.work_rounded;
      case AddressType.other:
        return Icons.place_rounded;
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
