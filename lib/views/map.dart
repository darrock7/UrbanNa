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
  final MapController _mapController = MapController();
  double _currentZoom = 12.0;
  static const double _minZoom = 3.0;
  static const double _maxZoom = 18.0;

  @override
  void initState() {
    super.initState();
    _loadFuture = Provider.of<ReportProvider>(context, listen: false).loadReports();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(47.6062, -122.3321),
                  initialZoom: _currentZoom,
                  onMapEvent: (event) {
                    if (event is MapEventMove && event.source != MapEventSource.mapController) {
                      setState(() {
                        _currentZoom = _mapController.camera.zoom;
                      });
                    }
                  },
                  minZoom: _minZoom,
                  maxZoom: _maxZoom,
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
              Positioned(
                left: 16,
                bottom: 16,
                child: Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final newZoom = (_currentZoom + 1).clamp(_minZoom, _maxZoom);
                            _mapController.move(_mapController.camera.center, newZoom);
                            setState(() {
                              _currentZoom = newZoom;
                            });
                          },
                        ),
                        SizedBox(
                          height: 150,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                tickMarkShape: SliderTickMarkShape.noTickMark,
                                trackHeight: 1.5,
                              ), 
                              child: Slider(
                                value: _currentZoom,
                                min: _minZoom,
                                max: _maxZoom,
                                divisions: (_maxZoom - _minZoom).toInt(),
                                label: _currentZoom.toStringAsFixed(1),
                                onChanged: (value) {
                                  setState(() {
                                    _currentZoom = value;
                                    _mapController.move(_mapController.camera.center, value);
                                  });
                                },
                              ),
                            )
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final newZoom = (_currentZoom - 1).clamp(_minZoom, _maxZoom);
                            _mapController.move(_mapController.camera.center, newZoom);
                            setState(() {
                              _currentZoom = newZoom;
                            });
                          },
                        ),
                      ],
                    )
                  ),
                )
              )
            ],
          )
        );
      },
    );
  }
}
