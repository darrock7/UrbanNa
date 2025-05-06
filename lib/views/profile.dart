import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  final String name;
  final String email;

  const ProfileView({super.key, required this.name, required this.email});
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Name: $name'),
        Text('Email: $email'),
      ],
    );
  }
}