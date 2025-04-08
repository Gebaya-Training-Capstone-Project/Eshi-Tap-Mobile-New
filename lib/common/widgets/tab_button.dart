import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColor.primaryColor : AppColor.placeholder;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Minimize the Column's height
        children: [
          Icon(icon, color: color, size: 20), // Reduced from 24 to 20
          const SizedBox(height: 2), // Reduced from 4 to 2
          Text(
            title,
            style: TextStyle(color: color, fontSize: 10), // Reduced from 12 to 10
          ),
        ],
      ),
    );
  }
}