import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbanna/providers/report_provider.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: FutureBuilder(
        future: reportProvider.loadReports(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(47.6062, -122.3321), // Seattle, WA
              initialZoom: 10.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.urbanna',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              // MarkerLayer to display the reports ongoing reports on the map 
              MarkerLayer(
                markers: reportProvider.reports.map((report) {
                  final locationSplit = report.location.split(',');
                  final latitude = double.tryParse(locationSplit[0]) ?? 0.0;
                  final longitude = double.tryParse(locationSplit[1]) ?? 0.0;
                  final reportLocation = LatLng(latitude, longitude);
                  return Marker(
                    point: reportLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
