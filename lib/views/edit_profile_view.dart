import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    await userDoc.update({
      'name': _nameController.text.trim(),
    });

    if (context.mounted) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
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
                      final upvotes = data['upvotes'] ?? 0;
                      final downvotes = data['downvotes'] ?? 0;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['title'] ?? 'Untitled'),
                                    const SizedBox(height: 4),
                                    Text('${data['severity']} | $formattedDate'),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.thumb_up, color: Colors.green, size: 20),
                                      const SizedBox(width: 4),
                                      Text('$upvotes'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.thumb_down, color: Colors.red, size: 20),
                                      const SizedBox(width: 4),
                                      Text('$downvotes'),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteReport(data['id']),
                              ),
                            ],
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
