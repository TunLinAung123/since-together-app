import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationRepository {
  final _client = Supabase.instance.client;

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> updateMyLocation({
    required String coupleId,
    required double lat,
    required double lng,
  }) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('locations').upsert({
      'couple_id': coupleId,
      'user_id': userId,
      'latitude': lat,
      'longitude': lng,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'couple_id, user_id');
  }

  Stream<List<Map<String, dynamic>>> locationsStream(String coupleId) {
    return _client
        .from('locations')
        .stream(primaryKey: ['id'])
        .eq('couple_id', coupleId);
  }
}
