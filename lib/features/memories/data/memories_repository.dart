import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class MemoriesRepository {
  final _client = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<List<Map<String, dynamic>>> getPhotos(String coupleId) async {
    return await _client
        .from('photos')
        .select('*, uploaded_by_profile:profiles!uploaded_by(display_name)')
        .eq('couple_id', coupleId)
        .order('created_at', ascending: false);
  }

  Future<void> uploadPhoto({
    required String coupleId,
    required File file,
    String? caption,
    DateTime? takenAt,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final fileName = '$coupleId/${_uuid.v4()}.jpg';

    // Storage upload
    await _client.storage
        .from('photos')
        .update(
          fileName,
          file,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    // DB record save
    await _client.from('photos').insert({
      'couple_id': coupleId,
      'uploaded_by': userId,
      'storage_path': fileName,
      'caption': caption,
      'taken_at': takenAt?.toIso8601String().split('T').first,
    });
  }

  String getPhotoUrl(String path) {
    return _client.storage.from('photos').getPublicUrl(path);
  }

  Future<void> deletePhoto(String photoId, String storagePath) async {
    await _client.storage.from('photos').remove([storagePath]);
    await _client.from('photos').delete().eq('id', photoId);
  }
}
