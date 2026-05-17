import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoupleRepository {
  final _client = Supabase.instance.client;

  Future<String?> getMyInviteCode() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('couples')
        .select('invite_code')
        .eq('user1_id', userId)
        .maybeSingle();
    return data?['invite_code'];
  }

  Future<String> createInviteCode() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('couples')
        .insert({'user1_id': userId})
        .select('invite_code')
        .single();

    return data['invite_code'];
  }

  Future<void> joinWithCode(String code) async {
    final userId = _client.auth.currentUser!.id;

    final couple = await _client
        .from('couples')
        .select()
        .eq('invite_code', code.toLowerCase())
        .isFilter('user2_id', null)
        .maybeSingle();

    if (couple == null) throw Exception('Invalid or already used code');

    await _client
        .from('couples')
        .update({'user2_id': userId})
        .eq('id', couple['id']);
  }

  Future<Map<String, dynamic>?> getMyCouple() async {
    final userId = _client.auth.currentUser!.id;
    return await _client
        .from('couples')
        .select('*, user1:profiles!user1_id(*), user2:profiles!user2_id(*)')
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .not('user2_id', 'is', null)
        .maybeSingle();
  }

  Future<void> setAnniversaryDate(String coupleId, DateTime date) async {
    try {
      await _client
          .from('couples')
          .update({'anniversary_date': date.toIso8601String().split('T').first})
          .eq('id', coupleId);
      debugPrint('Anniversary updated: $coupleId');
    } catch (e) {
      debugPrint('Anniversary update error: $e');
      rethrow;
    }
  }
}
