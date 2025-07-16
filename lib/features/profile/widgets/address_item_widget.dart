import 'package:flutter/material.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header section with type and edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Address type and default indicator
                Row(
                  children: [
                    Text(
                      address.typeDisplayName,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF262626),
                      ),
                    ),
                    
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '(Default)',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Edit button
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 24,
                    height: 24,
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF262626),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Divider line
            Container(
              height: 1,
              color: const Color(0xFFE3E3E3),
            ),
            
            const SizedBox(height: 16),
            
            // Address details section
            Row(
              children: [
                // Location icon
                Container(
                  width: 20,
                  height: 20,
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Color(0xFF5E5E5E),
                  ),
                ),
                
                const SizedBox(width: 4),
                
                // Address text
                Expanded(
                  child: Text(
                    address.fullAddress,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF5E5E5E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
