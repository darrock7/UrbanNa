import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera); // or gallery
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void _submitAlert() {
    final description = _descriptionController.text;
    // TODO: Replace this print with an API POST call
    print("Submitting alert:\n"
        "Type: $_selectedType\n"
        "Severity: $_selectedSeverity\n"
        "Description: $description\n"
        "Image: ${_image?.path}");

    // Clear form (optional)
    _descriptionController.clear();
    setState(() {
      _selectedType = 'Construction';
      _selectedSeverity = 'Medium';
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Alert")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: ['Construction', 'Hazard'].map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) => setState(() => _selectedType = value!),
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedSeverity,
            items: ['Low', 'Medium', 'High'].map((level) {
              return DropdownMenuItem(value: level, child: Text(level));
            }).toList(),
            onChanged: (value) => setState(() => _selectedSeverity = value!),
            decoration: const InputDecoration(labelText: 'Severity'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _image != null
              ? Image.file(_image!, height: 100)
              : const Text("No image selected."),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text("Upload Photo"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitAlert,
            child: const Text("Submit Alert"),
          )
        ]),
      ),
    );
  }
}
