import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:since_together/core/constants/app_colors.dart';
import 'package:since_together/features/couple/providers/couple_provider.dart';
import 'package:since_together/features/memories/presentation/widgets/photo_grid.dart';
import 'package:since_together/features/memories/providers/memories_provider.dart';

class MemoriesPage extends ConsumerStatefulWidget {
  const MemoriesPage({super.key});

  @override
  ConsumerState<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends ConsumerState<MemoriesPage> {
  bool _uploading = false;

  Future<void> _pickAndUpload(String coupleId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() => _uploading = true);

    try {
      await ref
          .read(memoriesRepositoryProvider)
          .uploadPhoto(coupleId: coupleId, file: File(picked.path));
      ref.invalidate(photosProvider(coupleId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupleIdAsync = ref.watch(coupleIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '📸 Memories',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: coupleIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (coupleId) {
          if (coupleId == null) return const SizedBox();
          final photosAsync = ref.watch(photosProvider(coupleId));

          return photosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (photos) => photos.isEmpty
                ? _EmptyState(onUpload: () => _pickAndUpload(coupleId))
                : PhotoGrid(
                    photos: photos,
                    repo: ref.read(memoriesRepositoryProvider),
                  ),
          );
        },
      ),
      floatingActionButton: coupleIdAsync.maybeWhen(
        data: (coupleId) => coupleId == null
            ? null
            : FloatingActionButton(
                onPressed: _uploading ? null : () => _pickAndUpload(coupleId),
                backgroundColor: AppColors.primary,
                child: _uploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.white,
                      ),
              ),
        orElse: () => null,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onUpload;

  const _EmptyState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📷', style: TextStyle(fontSize: 64)),

          const SizedBox(height: 16),

          const Text(
            'No memories yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Add your first photo together',
            style: TextStyle(color: AppColors.textMuted),
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Add Photo'),
          ),
        ],
      ),
    );
  }
}
