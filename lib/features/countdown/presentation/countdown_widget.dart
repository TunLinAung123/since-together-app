import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/core/constants/app_colors.dart';
import 'package:since_together/features/countdown/providers/countdown_provider.dart';

class CountdownWidget extends ConsumerWidget {
  const CountdownWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysTog = ref.watch(daysTogether);
    final daysUntil = ref.watch(daysUntilAnniversary);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('💕', style: TextStyle(fontSize: 32)),

          const SizedBox(height: 8),

          if (daysTog != null) ...[
            Text(
              '$daysTog',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              'days together',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],

          if (daysUntil != null) ...[
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🎉 Anniversary in $daysUntil days',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
