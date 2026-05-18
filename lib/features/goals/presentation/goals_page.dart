import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/core/constants/app_colors.dart';
import 'package:since_together/features/couple/providers/couple_provider.dart';
import 'package:since_together/features/goals/presentation/widgets/goals_card.dart';
import 'package:since_together/features/goals/providers/goals_provider.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  final _titleCtrl = TextEditingController();

  void _showAddDialog(String coupleId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'New Goal 🎯',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: _titleCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Visit Japan together',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleCtrl.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleCtrl.text.trim().isEmpty) return;
              await ref
                  .read(goalsRepoProvider)
                  .addGoal(coupleId: coupleId, title: _titleCtrl.text.trim());
              _titleCtrl.clear();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coupleIdAsync = ref.watch(coupleIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '🎯 Our Goals',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: coupleIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (coupleId) {
          if (coupleId == null) return const SizedBox();
          final goalsAsync = ref.watch(goalsStreamProvider(coupleId));

          return goalsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (goals) {
              final done = goals.where((g) => g['is_completed']).length;
              final total = goals.length;

              return Column(
                children: [
                  if (total > 0)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$done / $total completed',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                '${total == 0 ? 0 : ((done / total) * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : done / total,
                              backgroundColor: AppColors.secondary.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: goals.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🎯', style: TextStyle(fontSize: 48)),
                                SizedBox(height: 12),
                                Text(
                                  'No goals yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add your first goal together',
                                  style: TextStyle(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: goals.length,
                            itemBuilder: (_, i) => GoalsCard(
                              goal: goals[i],
                              onToggle: () => ref
                                  .read(goalsRepoProvider)
                                  .toggleGoal(
                                    goals[i]['id'],
                                    goals[i]['is_completed'],
                                  ),
                              onDelete: () => ref
                                  .read(goalsRepoProvider)
                                  .deleteGoal(goals[i]['id']),
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: coupleIdAsync.maybeWhen(
        data: (coupleId) => coupleId == null
            ? null
            : FloatingActionButton(
                onPressed: () => _showAddDialog(coupleId),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
        orElse: () => null,
      ),
    );
  }
}
