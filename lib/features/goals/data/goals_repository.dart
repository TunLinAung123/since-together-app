import 'package:supabase_flutter/supabase_flutter.dart';

class GoalsRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getGoals(String coupleId) async {
    return await _client
        .from('goals')
        .select()
        .eq('couple_id', coupleId)
        .order('created_at', ascending: true);
  }

  Future<void> addGoal({
    required String coupleId,
    required String title,
  }) async {
    await _client.from('goals').insert({
      'couple_id': coupleId,
      'title': title,
      'created_by': _client.auth.currentUser!.id,
    });
  }

  Future<void> toggleGoal(String goalId, bool current) async {
    await _client
        .from('goals')
        .update({
          'is_completed': !current,
          'completed_at': !current
              ? DateTime.now().toIso8601String().split('T').first
              : null,
        })
        .eq('id', goalId);
  }

  Future<void> deleteGoal(String goalId) async {
    await _client.from('goals').delete().eq('id', goalId);
  }

  Stream<List<Map<String, dynamic>>> goalsStream(String coupleId) async* {
    yield await getGoals(coupleId);
    await for (final _
        in _client
            .from('goals')
            .stream(primaryKey: ['id'])
            .eq('couple_id', coupleId)) {
      yield await getGoals(coupleId);
    }
  }
}
