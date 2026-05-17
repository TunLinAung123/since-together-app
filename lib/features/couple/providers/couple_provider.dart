import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/couple_repository.dart';

final coupleRepositoryProvider = Provider((ref) => CoupleRepository());

final coupleProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final repo = ref.read(coupleRepositoryProvider);
  return repo.getMyCouple();
});

final coupleIdProvider = FutureProvider<String?>((ref) async {
  final couple = await ref.watch(coupleProvider.future);
  return couple?['id'];
});
