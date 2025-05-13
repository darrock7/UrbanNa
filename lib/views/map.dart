import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbanna/providers/report_provider.dart';
import 'package:provider/provider.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = Provider.of<ReportProvider>(context, listen: false).loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Map View')),
          body: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(47.6062, -122.3321),
              initialZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.urbanna',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              MarkerLayer(
                markers: reportProvider.reports.map((report) {
                  final parts = report.location.split(',');
                  final lat = double.tryParse(parts[0]) ?? 0.0;
                  final lng = double.tryParse(parts[1]) ?? 0.0;
                  return Marker(
                    point: LatLng(lat, lng),
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
