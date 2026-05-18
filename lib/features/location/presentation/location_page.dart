import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/location_provider.dart';
import '../../couple/providers/couple_provider.dart';
import '../../../core/constants/app_colors.dart';

class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  final _mapController = MapController();
  bool _sharing = false;

  Future<void> _shareLocation(String coupleId) async {
    setState(() => _sharing = true);
    try {
      final repo = ref.read(locationsRepoProvider);
      final pos = await repo.getCurrentPosition();
      await repo.updateMyLocation(
        coupleId: coupleId,
        lat: pos.latitude,
        lng: pos.longitude,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('📍 Location shared!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupleIdAsync = ref.watch(coupleIdProvider);
    final myId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '📍 Location',
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
          final locAsync = ref.watch(locatoinsStreamProvider(coupleId));

          return locAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (locations) {
              // Center map မှာ ထားဖို့ position ရှာပါ
              final center = locations.isNotEmpty
                  ? LatLng(
                      locations.first['latitude'],
                      locations.first['longitude'],
                    )
                  : const LatLng(16.8661, 96.1951); // Yangon default

              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(initialCenter: center, initialZoom: 14),
                    children: [
                      // OpenStreetMap tile
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.together.app',
                      ),

                      // Markers
                      MarkerLayer(
                        markers: locations.map((loc) {
                          final isMe = loc['user_id'] == myId;
                          return Marker(
                            point: LatLng(loc['latitude'], loc['longitude']),
                            width: 60,
                            height: 60,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.primary
                                        : Colors.purple,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isMe ? 'Me' : '💕',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.location_pin,
                                  color: isMe
                                      ? AppColors.primary
                                      : Colors.purple,
                                  size: 28,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // Share button
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _sharing
                            ? null
                            : () => _shareLocation(coupleId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: _sharing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.my_location,
                                color: Colors.white,
                              ),
                        label: Text(
                          _sharing ? 'Sharing...' : 'Share My Location',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
