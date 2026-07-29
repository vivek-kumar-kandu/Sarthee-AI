import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nearby_place.dart';
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
    final nearbyPlaces = ref.watch(nearbyPlacesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Location Intelligence')),
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

              if (state.status == LocationStatus.success &&
                  state.location != null) {
                return ListView(
                  children: <Widget>[
                    LocationCard(location: state.location!),
                    const SizedBox(height: 12),
                    if (nearbyPlaces.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (nearbyPlaces.hasError)
                      Text('Unable to load nearby places.')
                    else if (nearbyPlaces.valueOrNull?.isNotEmpty ?? false)
                      ...nearbyPlaces.valueOrNull!.map(
                        (place) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: NearbyPlaceCard(place: place),
                        ),
                      )
                    else
                      const NearbyPlaceCard(
                        place: NearbyPlace(
                          id: 'demo',
                          name: 'Explore cultural highlights',
                          category: 'Culture',
                          latitude: 0,
                          longitude: 0,
                        ),
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
