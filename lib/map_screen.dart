import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pharmacies/models/pharmacy.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    List<Pharmacy> pharmacies = args['pharmacies'];
    Position? position = args['position'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(
            position?.latitude ?? pharmacies.first.latitude,
            position?.longitude ?? pharmacies.first.longitude,
          ),
          zoom: 8,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              if (position != null)
                Marker(
                  point: LatLng(position.latitude, position.longitude),
                  builder: (context) => const Icon(Icons.place_outlined),
                ),
              ...pharmacies
                  .map((pharmacy) => Marker(
                        point: LatLng(pharmacy.latitude, pharmacy.longitude),
                        builder: (context) => IconButton(
                          tooltip: pharmacy.name,
                          onPressed: () => MapsLauncher.launchCoordinates(
                              pharmacy.latitude, pharmacy.longitude),
                          icon: const Icon(Icons.place),
                        ),
                      ))
                  .toList(),
            ],
          )
        ],
      ),
    );
  }
}
