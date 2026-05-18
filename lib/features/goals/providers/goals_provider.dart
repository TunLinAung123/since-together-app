import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/features/goals/data/goals_repository.dart';

final goalsRepoProvider = Provider((ref) => GoalsRepository());

final goalsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, coupleId) {
      final repo = ref.watch(goalsRepoProvider);
      return repo.goalsStream(coupleId);
    });
