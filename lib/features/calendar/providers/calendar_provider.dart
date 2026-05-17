import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/features/calendar/data/calendar_repository.dart';

final calendarRepoProvider = Provider((ref) => CalendarRepository());

final eventsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      coupleId,
    ) async {
      return ref.read(calendarRepoProvider).getEvents(coupleId);
    });
