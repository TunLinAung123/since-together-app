import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/features/memories/data/memories_repository.dart';

final memoriesRepositoryProvider = Provider((ref) => MemoriesRepository());

final photosProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      coupleId,
    ) async {
      return ref.read(memoriesRepositoryProvider).getPhotos(coupleId);
    });
