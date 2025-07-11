import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbanna/models/report.dart';

class SubmitAlertView extends StatefulWidget {
  const SubmitAlertView({super.key});

  @override
  State<SubmitAlertView> createState() => _SubmitAlertViewState();
}

class _SubmitAlertViewState extends State<SubmitAlertView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Construction';
  String _selectedSeverity = 'Medium';
  File? _image;
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  double _currentZoom = 15.0;
  static const double _minZoom = 3.0;
  static const double _maxZoom = 18.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedLocation = const LatLng(47.6062, -122.3321);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submitAlert() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
      }
      return;
    }

    String? imageUrl;
    if (_image != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('report_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_image!);
      imageUrl = await storageRef.getDownloadURL();
    }

final location = _selectedLocation != null
    ? "${_selectedLocation!.latitude},${_selectedLocation!.longitude}"
    : "0.0,0.0";


    final newReport = Report(
      userId: currentUser.uid,
      title: _titleController.text.trim(),
      type: _selectedType,
      description: _descriptionController.text.trim(),
      location: location,
      severity: _selectedSeverity,
      imageUrl: imageUrl,
    );


  final reportsRef = FirebaseFirestore.instance.collection('reports');
  final docRef = await reportsRef.add(newReport.toMap());

  final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
  await userDoc.update({
    'reportIds': FieldValue.arrayUnion([docRef.id])
  });


    if (context.mounted) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully!')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }

    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedType = 'Construction';
      _selectedSeverity = 'Medium';
      _image = null;
    });
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 4,
      top: 5,
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 16,
                icon: const Icon(Icons.add),
                onPressed: () {
                  final newZoom = (_currentZoom + 1).clamp(_minZoom, _maxZoom);
                  _mapController.move(_mapController.camera.center, newZoom);
                  setState(() => _currentZoom = newZoom);
                },
              ),
              SizedBox(
                height: 80,
                width: 20,
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
                  ),
                ),
              ),
              IconButton(
                iconSize: 16,
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final newZoom = (_currentZoom - 1).clamp(_minZoom, _maxZoom);
                  _mapController.move(_mapController.camera.center, newZoom);
                  setState(() => _currentZoom = newZoom);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Alert")),
      body: _selectedLocation == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: ['Construction', 'Hazard']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedSeverity,
                  items: ['Low', 'Medium', 'High']
                      .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSeverity = val!),
                  decoration: const InputDecoration(labelText: 'Severity'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_image!, height: 120),
                            )
                          : const Text("No image selected."),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Upload Photo"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.1),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedLocation!,
                          initialZoom: _currentZoom,
                          onTap: (_, point) => setState(() => _selectedLocation = point),
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
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
                              )
                            ],
                          )
                        ],
                      ),
                      _buildZoomControls(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitAlert,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Submit Alert"),
                )
              ],
            ),
    );
  }
}
