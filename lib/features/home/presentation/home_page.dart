import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/core/constants/app_colors.dart';
import 'package:since_together/features/chat/presentation/chat_page.dart';
import 'package:since_together/features/countdown/providers/countdown_provider.dart';
import 'package:since_together/features/couple/providers/couple_provider.dart';
import 'package:since_together/features/home/presentation/widgets/countdown_card.dart';
import 'package:since_together/features/home/presentation/widgets/feature_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(coupleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: coupleAsync.when(
          data: (couple) => HomeBody(couple: couple),
          error: (e, _) => Center(child: Text('$e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class HomeBody extends ConsumerWidget {
  final Map<String, dynamic>? couple;

  const HomeBody({super.key, required this.couple});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysTog = ref.watch(daysTogether);
    final daysUntil = ref.watch(daysUntilAnniversary);

    final user1Name = couple?['user1']?['display_name'] ?? 'Unknown';
    final user2Name = couple?['user2']?['display_name'] ?? 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good evening ...',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),

          Text(
            '$user1Name & $user2Name 💕',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),

          CountdownCard(daysTog: daysTog, daysUntil: daysUntil, couple: couple),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              FeatureCard(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Our Chat',
                subTitle: 'Send a message',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                ),
              ),
              FeatureCard(
                icon: Icons.photo_library_outlined,
                label: 'Memories',
                subTitle: 'Coming soon',
                onTap: () {},
              ),
              FeatureCard(
                icon: Icons.calendar_month_outlined,
                label: 'Calendar',
                subTitle: 'Coming soon',
                onTap: () {},
              ),
              FeatureCard(
                icon: Icons.favorite_border_rounded,
                label: 'Goals',
                subTitle: 'Coming soon',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
