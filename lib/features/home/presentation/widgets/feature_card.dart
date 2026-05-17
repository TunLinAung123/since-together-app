import 'package:flutter/material.dart';
import 'package:since_together/core/constants/app_colors.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subTitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
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
