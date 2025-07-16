import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isLogout;

  const ProfileMenuItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 380,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Menu item content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isLogout 
                          ? const Color(0xFFEB5757) 
                          : const Color(0xFF262626),
                    ),
                  ),
                  
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow or logout icon
            Container(
              width: 24,
              height: 24,
              child: Icon(
                isLogout ? Icons.logout : Icons.arrow_forward_ios,
                size: isLogout ? 20 : 16,
                color: isLogout 
                    ? const Color(0xFFEB5757) 
                    : const Color(0xFF262626),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
