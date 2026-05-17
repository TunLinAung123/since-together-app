import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/features/couple/providers/couple_provider.dart';

final daysTogether = Provider<int?>((ref) {
  final coupleAsync = ref.watch(coupleProvider);
  return coupleAsync.whenOrNull(
    data: (couple) {
      if (couple == null) return null;
      final since = couple['anniversary_date'] != null
          ? DateTime.parse(couple['anniversary_date'])
          : DateTime.parse(couple['created_at']);
      return DateTime.now().difference(since).inDays;
    },
  );
});

final daysUntilAnniversary = Provider<int?>((ref) {
  final coupleAsync = ref.watch(coupleProvider);
  return coupleAsync.whenOrNull(
    data: (couple) {
      if (couple?['anniversary_date'] == null) return null;
      final ann = DateTime.parse(couple!['anniversary_date']);
      final now = DateTime.now();

      var next = DateTime(now.year, ann.month, ann.day);
      if (next.isBefore(now)) next = DateTime(now.year + 1, ann.month, ann.day);
      return next.difference(now).inDays;
    },
  );
});
