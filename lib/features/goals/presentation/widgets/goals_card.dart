import 'package:flutter/material.dart';
import 'package:since_together/core/constants/app_colors.dart';

class GoalsCard extends StatelessWidget {
  const GoalsCard({
    super.key,
    required this.goal,
    required this.onToggle,
    required this.onDelete,
  });

  final Map<String, dynamic> goal;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCompleted = goal['is_completed'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isCompleted ? AppColors.primary : AppColors.secondary,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          goal['title'],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.textMuted,
          ),
        ),
        subtitle: isCompleted && goal['completed_at'] != null
            ? Text(
                '✅ Completed',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              )
            : null,
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline,
            size: 18,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
