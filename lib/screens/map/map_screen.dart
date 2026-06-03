import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const store = LatLng(10.72967, 106.72198);
    return GoogleMap(
      initialCameraPosition: const CameraPosition(target: store, zoom: 15),
      markers: const {
        Marker(
          markerId: MarkerId('sneaker_store'),
          position: store,
          infoWindow: InfoWindow(
            title: 'Sneaker Store',
            snippet: '123 Nguyễn Văn Linh, Q7, TP.HCM',
          ),
        ),
      },
    );
  }
}
