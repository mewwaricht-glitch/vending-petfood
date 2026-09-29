import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CategoryTab extends StatelessWidget {
  final String category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryTab({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppColors.apples : Colors.grey,
          ),
          child: Text(category),
        ),
      ),
    );
  }
}
