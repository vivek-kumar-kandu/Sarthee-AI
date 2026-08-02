import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/location_provider.dart';

class PermissionView extends ConsumerWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.location_on_rounded, size: 64),
            const SizedBox(height: 16),
            Text(
              'Enable location access',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Sarthee AI uses your location to offer smarter travel guidance and recommendations.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await ref
                    .read(locationProvider.notifier)
                    .requestLocationPermission();
              },
              icon: const Icon(Icons.location_searching_rounded),
              label: const Text('Enable location'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                await ref.read(locationProvider.notifier).loadCurrentLocation();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
