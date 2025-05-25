import 'package:flutter/material.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';

class BasicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double height;
  const BasicButton({
    required this.onPressed,
    required this.title,
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(height)),
      child: Text(title, style: TextStyle(color: AppColors.lightBackground)),
    );
  }
}
