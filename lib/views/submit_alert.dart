import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:urbanna/models/report.dart';
import 'package:urbanna/providers/report_provider.dart';

class SubmitAlertView extends StatefulWidget {
  const SubmitAlertView({super.key});

  @override
  State<SubmitAlertView> createState() => _SubmitAlertViewState();
}

class _SubmitAlertViewState extends State<SubmitAlertView> {
  final _descriptionController = TextEditingController();
  String _selectedType = 'Construction';
  String _selectedSeverity = 'Medium';
  File? _image;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

void _submitAlert() async {
  final location = _selectedLocation != null
      ? "${_selectedLocation!.latitude},${_selectedLocation!.longitude}"
      : "0.0,0.0";

  final newReport = Report(
    category: 'Report',
    type: _selectedType,
    description: _descriptionController.text.trim(),
    location: location,
  );

  await Provider.of<ReportProvider>(context, listen: false).addReport(newReport);

  // Optional: feedback and reset
  if (context.mounted) {
    
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert submitted successfully!')),
    );

    // ignore: use_build_context_synchronously
    Navigator.pop(context); 
  }

  _descriptionController.clear();
  setState(() {
    _selectedType = 'Construction';
    _selectedSeverity = 'Medium';
    _image = null;
  });
}


  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Alert")),
      body: _selectedLocation == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Type
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: ['Construction', 'Hazard']
                      .map((type) => DropdownMenuItem(
                          value: type, child: Text(type)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 12),

                // Severity
                DropdownButtonFormField<String>(
                  value: _selectedSeverity,
                  items: ['Low', 'Medium', 'High']
                      .map((level) => DropdownMenuItem(
                          value: level, child: Text(level)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSeverity = val!),
                  decoration: const InputDecoration(labelText: 'Severity'),
                ),
                const SizedBox(height: 12),

                // Description
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Image Upload
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

                // Map Location Picker
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
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _selectedLocation!,
                      initialZoom: 10,
                      onTap: (_, point) =>
                          setState(() => _selectedLocation = point),
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
                            child: const Icon(Icons.location_pin,
                                color: Colors.blue, size: 40),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
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
