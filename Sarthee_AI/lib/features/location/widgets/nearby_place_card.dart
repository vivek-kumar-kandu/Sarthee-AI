import 'package:flutter/material.dart';

import '../models/nearby_place.dart';

class NearbyPlaceCard extends StatelessWidget {
  const NearbyPlaceCard({required this.place, super.key});

  final NearbyPlace place;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: place.imageUrl != null && place.imageUrl!.isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(place.imageUrl!))
            : const CircleAvatar(child: Icon(Icons.place_rounded)),
        title: Text(place.name),
        subtitle: Text(
          '${place.category}${place.distance != null ? ' • ${place.distance!.toStringAsFixed(1)} km' : ''}',
        ),
        trailing: place.rating != null
            ? Text(place.rating!.toStringAsFixed(1))
            : null,
      ),
    );
  }
}
