import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/features/location/data/location_repository.dart';

final locationsRepoProvider = Provider((ref) => LocationRepository());

final locatoinsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, coupleId) {
      return ref.read(locationsRepoProvider).locationsStream(coupleId);
    });
