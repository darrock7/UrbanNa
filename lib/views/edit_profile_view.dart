import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class EditProfileView extends StatefulWidget {
  final String name;
  final String email;
  final String profilePictureUrl;

  const EditProfileView({
    super.key,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  String? _profilePictureUrl;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _profilePictureUrl = widget.profilePictureUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickNewProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      setState(() {
        _profilePictureUrl = url;
        _localImagePath = picked.path;
      });
    }
  }

  void _submit() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    await userDoc.update({
      'name': _nameController.text.trim(),
      'profilePictureUrl': _profilePictureUrl,
    });

    if (context.mounted) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'imagePath': _localImagePath,
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserReportsById() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final List<dynamic> ids = userDoc.data()?['reportIds'] ?? [];

    if (ids.isEmpty) return [];

    final List<Map<String, dynamic>> reports = [];

    for (final id in ids) {
      final doc = await FirebaseFirestore.instance.collection('reports').doc(id).get();
      if (doc.exists) {
        reports.add(doc.data()!..['id'] = doc.id);
      }
    }

    return reports;
  }

  void _deleteReport(String reportId) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'reportIds': FieldValue.arrayRemove([reportId])
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profilePictureUrl != null
                        ? NetworkImage(_profilePictureUrl!)
                        : null,
                  ),
                  TextButton(
                    onPressed: _pickNewProfilePicture,
                    child: const Text('Change Profile Picture'),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            const Text('Your Reports:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder(
                future: _fetchUserReportsById(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final reports = snapshot.data!;
                  if (reports.isEmpty) return const Text('No reports found.');
                  return ListView(
                    children: reports.map((data) {
                      final timestamp = (data['timestamp'] as Timestamp).toDate();
                      final formattedDate = DateFormat.yMMMd().format(timestamp);
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(data['title'] ?? 'Untitled'),
                          subtitle: Text('${data['severity']} | $formattedDate'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReport(data['id']),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
