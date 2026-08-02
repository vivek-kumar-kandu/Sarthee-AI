import 'package:flutter/material.dart';

import '../models/location_model.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({required this.location, super.key});

  final LocationModel location;

  @override
  Widget build(BuildContext context) {
    final city = location.city ?? 'Unknown city';
    final country = location.country ?? 'Unknown country';

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.location_on_rounded)),
        title: Text(city),
        subtitle: Text(country),
        trailing: Text(location.timestamp != null ? 'Updated' : 'Cached'),
      ),
    );
  }
}
