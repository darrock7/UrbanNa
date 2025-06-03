import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:urbanna/models/report.dart';
import 'package:urbanna/providers/report_provider.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  double _currentZoom = 12.0;
  static const double _minZoom = 3.0;
  static const double _maxZoom = 18.0;

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
                if (event is MapEventMove &&
                    event.source != MapEventSource.mapController) {
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
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.urbanna.app',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              StreamBuilder<List<Report>>(
                stream: reportProvider.getReportsStream(),
                builder: (context, snapshot) {
                  final reports = snapshot.data ?? [];
                  return MarkerLayer(
                    markers: reports.map((report) {
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
                              builder: (dialogContext) {
                                final isAuthor = report.userId == reportProvider.currentUserId;

                                return AlertDialog(
                                  insetPadding: const EdgeInsets.all(20),
                                  contentPadding: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          report.title,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.of(dialogContext).pop(),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report.description,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 12),
                                      if (isAuthor)
                                        const Text(
                                          'You cannot vote on your own report.',
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      else
                                        FutureBuilder<String?>(
                                          future: reportProvider.getUserVoteStatus(
                                            report.id!,
                                            reportProvider.currentUserId!,
                                          ),
                                          builder: (context, snapshot) {
                                            final voteStatus = snapshot.data;

                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.thumb_up,
                                                        color: voteStatus == 'up'
                                                            ? Colors.green
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: voteStatus == null
                                                          ? () async {
                                                              await reportProvider
                                                                  .upvoteReport(
                                                                      report.id!,
                                                                      reportProvider
                                                                          .currentUserId!);
                                                              setState(() {});
                                                            }
                                                          : null,
                                                    ),
                                                    Text('${report.upvotes}'),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.thumb_down,
                                                        color: voteStatus == 'down'
                                                            ? Colors.red
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: voteStatus == null
                                                          ? () async {
                                                              await reportProvider
                                                                  .downvoteReport(
                                                                      report.id!,
                                                                      reportProvider
                                                                          .currentUserId!);
                                                              setState(() {});
                                                            }
                                                          : null,
                                                    ),
                                                    Text('${report.downvotes}'),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.location_pin,
                            color: _severityLevel(report.severity),
                            size: 40,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
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
                        final newZoom =
                            (_currentZoom + 1).clamp(_minZoom, _maxZoom);
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
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10),
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
                                _mapController.move(
                                    _mapController.camera.center, value);
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        final newZoom =
                            (_currentZoom - 1).clamp(_minZoom, _maxZoom);
                        _mapController.move(_mapController.camera.center, newZoom);
                        setState(() {
                          _currentZoom = newZoom;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
