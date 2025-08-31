import 'package:flutter/material.dart';

class SettingsMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool hasArrow;
  final bool hasToggle;
  final bool? toggleValue;
  final Function(bool)? onToggleChanged;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool isLoading;

  const SettingsMenuItem({
    super.key,
    required this.title,
    this.subtitle,
    this.hasArrow = false,
    this.hasToggle = false,
    this.toggleValue,
    this.onToggleChanged,
    this.onTap,
    this.showDivider = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top divider (except for first item)
        if (showDivider && title != 'Dark Mode')
          Container(
            height: 1,
            color: const Color(0xFFE3E3E3),
          ),
        
        // Menu item content
        GestureDetector(
          onTap: hasToggle ? null : onTap,
          child: Container(
            width: 428,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF262626),
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
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Right side content
                if (hasToggle)
                  _buildToggleSwitch()
                else if (hasArrow)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF262626),
                  )
                else if (subtitle != null)
                  const SizedBox(width: 24), // Placeholder for alignment
              ],
            ),
          ),
        ),
        
        // Bottom divider (for last item)
        if (!showDivider)
          Container(
            height: 1,
            color: const Color(0xFFE3E3E3),
          ),
      ],
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      width: 24,
      height: 24,
      child: Switch(
        value: toggleValue ?? false,
        onChanged: onToggleChanged,
        activeColor: const Color(0xFFE3E3E3),
        activeTrackColor: const Color(0xFFB7B7B7),
        inactiveThumbColor: const Color(0xFFE3E3E3),
        inactiveTrackColor: const Color(0xFFB7B7B7),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
