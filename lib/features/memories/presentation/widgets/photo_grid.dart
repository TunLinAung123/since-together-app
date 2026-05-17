import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/features/couple/providers/couple_provider.dart';
import 'package:since_together/features/memories/data/memories_repository.dart';
import 'package:since_together/features/memories/presentation/widgets/photo_viewer.dart';
import 'package:since_together/features/memories/providers/memories_provider.dart';

class PhotoGrid extends ConsumerWidget {
  final List<Map<String, dynamic>> photos;
  final MemoriesRepository repo;

  const PhotoGrid({super.key, required this.photos, required this.repo});

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> photo,
    String coupleId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Photo?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('This photo will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await repo.deletePhoto(photo['id'], photo['storage_path']);
                ref.invalidate(photosProvider(coupleId));
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleIdAsync = ref.watch(coupleIdProvider);

    return coupleIdAsync.maybeWhen(
      data: (coupleId) {
        if (coupleId == null) return const SizedBox();

        return GridView.builder(
          padding: const EdgeInsets.all(4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          itemCount: photos.length,
          itemBuilder: (_, i) {
            final photo = photos[i];
            final url = repo.getPhotoUrl(photo['storage_path']);

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PhotoViewer(photos: photos, initialIndex: i, repo: repo),
                ),
              ),
              onLongPress: () =>
                  _showDeleteDialog(context, ref, photo, coupleId),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: Colors.grey[200]),
                    errorWidget: (_, _, _) => const Icon(Icons.broken_image),
                  ),

                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      orElse: () => const SizedBox(),
    );
  }
}
