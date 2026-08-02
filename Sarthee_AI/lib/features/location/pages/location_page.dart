import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/provenance_badge_widget.dart';
import '../providers/location_provider.dart';
import '../providers/nearby_places_provider.dart';
import '../widgets/location_card.dart';
import '../widgets/nearby_place_card.dart';
import '../widgets/permission_view.dart';

class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  @override
  void initState() {
    super.initState();

    Future<void>.microtask(() {
      ref.read(locationProvider.notifier).loadCurrentLocation();
    });

    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (next.status == LocationStatus.success && next.location != null) {
        ref
            .read(nearbyPlacesProvider.notifier)
            .loadNearbyPlaces(location: next.location);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationProvider);
    final nearbyState = ref.watch(nearbyPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (state.location != null) {
                ref
                    .read(nearbyPlacesProvider.notifier)
                    .loadNearbyPlaces(location: state.location);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (context) {
              if (state.status == LocationStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == LocationStatus.permissionDenied) {
                return const PermissionView();
              }

              if (state.status == LocationStatus.success && state.location != null) {
                return ListView(
                  children: <Widget>[
                    LocationCard(location: state.location!),
                    const SizedBox(height: 16),
                    nearbyState.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Unable to load nearby places: $err',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(nearbyPlacesProvider.notifier)
                                    .loadNearbyPlaces(location: state.location);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                      data: (response) {
                        final places = response.data ?? [];
                        final provenance = response.meta.provenance;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (provenance != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nearby POIs (${places.length})',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    ProvenanceBadgeWidget(provenance: provenance),
                                  ],
                                ),
                              ),
                            ],
                            if (places.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text('No points of interest found nearby.'),
                                ),
                              )
                            else
                              ...places.map(
                                (place) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: NearbyPlaceCard(place: place),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              }

              if (state.error != null) {
                return Center(child: Text(state.error!.message));
              }

              return const PermissionView();
            },
          ),
        ),
      ),
    );
  }
}
