import 'package:flutter/material.dart';
import 'package:since_together/core/constants/app_colors.dart';

class CountdownCard extends StatelessWidget {
  const CountdownCard({super.key, this.daysTog, this.daysUntil, this.couple});

  final int? daysTog;
  final int? daysUntil;
  final Map<String, dynamic>? couple;

  @override
  Widget build(BuildContext context) {
    final annDate = couple?['anniversary_date'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${daysTog ?? '--'}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'days together',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 0.5,
                height: 60,
                color: AppColors.secondary.withValues(alpha: 0.5),
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${daysUntil ?? '--'}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'until anniversary',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (annDate != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Anniversary on $annDate',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
              label: const Text(
                'Set anniversary date',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
