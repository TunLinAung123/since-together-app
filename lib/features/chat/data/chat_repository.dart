import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMessages(String coupleId) async {
    return await _client
        .from('messages')
        .select('*, sender:profiles!sender_id(display_name, avatar_url)')
        .eq('couple_id', coupleId)
        .order('created_at', ascending: true);
  }

  Future<void> sendMessage({
    required String coupleId,
    required String content,
  }) async {
    await _client.from('messages').insert({
      'couple_id': coupleId,
      'sender_id': _client.auth.currentUser!.id,
      'content': content,
    });
  }

  Stream<List<Map<String, dynamic>>> messagesStream(String coupleId) async* {
    yield await getMessages(coupleId);

    await for (final _
        in _client
            .from('messages')
            .stream(primaryKey: ['id'])
            .eq('couple_id', coupleId)) {
      yield await getMessages(coupleId);
    }

    // return _client
    //     .from('messages')
    //     .stream(primaryKey: ['id'])
    //     .eq('couple_id', coupleId)
    //     .order('created_at', ascending: true)
    //     .map((rows) => rows);
  }
}
