import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/features/chat/data/chat_repository.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

final messagesStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, coupleId) {
      final repo = ref.read(chatRepositoryProvider);
      return repo.messagesStream(coupleId);
    });
