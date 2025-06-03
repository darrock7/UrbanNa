import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urbanna/screens/login_screen.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  final String name;
  final String email;

  const ProfileView({super.key, required this.name, required this.email});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late String _name;
  late String _email;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _email = widget.email;
  }

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profilePictureUrl != null
                  ? NetworkImage(_profilePictureUrl!)
                  : null,
              child: _profilePictureUrl == null
                  ? Text(
                      _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(_name),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(_email),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileView(
                    name: _name,
                    email: _email,
                    profilePictureUrl: _profilePictureUrl ?? '',
                  ),
                ),
              );

              if (updated != null && updated is Map) {
                setState(() {
                  _name = updated['name'] ?? _name;
                  _profilePictureUrl = updated['imagePath'];
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!')),
                );
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
