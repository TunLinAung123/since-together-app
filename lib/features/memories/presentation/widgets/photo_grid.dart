import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:since_together/features/memories/data/memories_repository.dart';
import 'package:since_together/features/memories/presentation/widgets/photo_viewer.dart';

class PhotoGrid extends StatelessWidget {
  final List<Map<String, dynamic>> photos;
  final MemoriesRepository repo;

  const PhotoGrid({super.key, required this.photos, required this.repo});

  @override
  Widget build(BuildContext context) {
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
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: Colors.grey[200]),
            errorWidget: (_, _, _) => const Icon(Icons.broken_image),
          ),
        );
      },
    );
  }
}
