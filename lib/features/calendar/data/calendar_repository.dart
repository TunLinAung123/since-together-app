import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getEvents(String coupleId) async {
    return await _client
        .from('events')
        .select()
        .eq('couple_id', coupleId)
        .order('event_date', ascending: true);
  }

  Future<void> addEvent({
    required String coupleId,
    required String title,
    required DateTime date,
    String? description,
  }) async {
    await _client.from('events').insert({
      'couple_id': coupleId,
      'title': title,
      'description': description,
      'event_date': date.toIso8601String().split('T').first,
      'created_by': _client.auth.currentUser!.id,
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _client.from('events').delete().eq('id', eventId);
  }
}
