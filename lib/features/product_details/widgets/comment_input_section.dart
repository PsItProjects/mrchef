import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class CommentInputSection extends GetView<ProductDetailsController> {
  const CommentInputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'add_comment'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Comment input field
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE3E3E3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'write_your_comment_here'.tr,
                  hintStyle: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF262626),
                ),
                onChanged: (value) {
                  controller.updateComment(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
