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

  Color _severityLevel(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.black;
    }
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
                    userAgentPackageName: 'com.urbanna.app',
                    retinaMode: RetinaMode.isHighDensity(context),
                  ),
                  MarkerLayer(
                    markers: reportProvider.reports.map((report) {
                      final parts = report.location.split(',');
                      final lat = double.tryParse(parts[0]) ?? 0.0;
                      final lng = double.tryParse(parts[1]) ?? 0.0;

                      return Marker(
                        width: 50,
                        height: 50,
                        point: LatLng(lat, lng),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(report.type),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      report.description,
                                      style: TextStyle(
                                        color: _severityLevel(report.severity),
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Severity: ${report.severity}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Reported: ${report.timestamp.toString().split('.')[0]}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Exit'),
                                  ),
                                  // Only show delete if current user owns the report
                                  if (report.userId == reportProvider.currentUserId)
                                    TextButton(
                                      onPressed: () async {
                                        // Use Firestore ID if available, fall back to SQLite ID
                                        if (report.firestoreId != null) {
                                          await reportProvider.deleteFirestoreReport(report.firestoreId!);
                                        } else if (report.id != null) {
                                          await reportProvider.deleteReport(report.id!);
                                        }
                                        
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                        setState(() {}); // Trigger UI update
                                      },
                                      child: const Text('Delete'),
                                    ),
                                ],
                              ),
                            );
                          },
                          child: Icon(
                            Icons.location_pin, 
                            color: report.userId == reportProvider.currentUserId 
                                ? Colors.blue // User's own reports
                                : Colors.red,  // Others' reports
                            size: 40
                          ),
                        ),
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

